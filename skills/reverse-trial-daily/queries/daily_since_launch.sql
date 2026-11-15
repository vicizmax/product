-- One row per day from a week before launch (2026-09-24) to today, with comparisons pre-computed.
-- Totals = free + old_trial + new_trial (excl. system cancels). People = distinct email, flag-on time only
-- (from 2026-10-01 11:15 UTC). *_to_cutoff = cut at the latest subscription's time of day (fair for today).
-- Reverse trial = 1MIL900K trial with end behavior pause/cancel (set at creation), so it stays put when a card is added.
WITH latest AS (SELECT max(created) AS ts FROM subscriptions),
sf AS (
  SELECT s.id, s.customer_id, s.created, s.trial_start, s.status, s.canceled_at, s.schedule_id,
    s.trial_settings_end_behavior_missing_payment_method AS end_behavior,
    bool_or(pr.name LIKE 'SonarCloud Free%') AS is_free,
    bool_or(pr.name LIKE '%1MIL900K%') AS is_1m9
  FROM subscriptions s
  JOIN subscription_items si ON s.id = si.subscription_id
  JOIN prices p ON si.price_id = p.id
  JOIN products pr ON p.product_id = pr.id
  WHERE s.created >= timestamp '2026-09-01 00:00:00'
  GROUP BY 1,2,3,4,5,6,7,8
),
c AS (
  SELECT sf.*, date(sf.created) AS d, coalesce(lower(cu.email), sf.customer_id) AS person,
    CASE
      WHEN is_free THEN 'free'
      WHEN is_1m9 AND trial_start IS NOT NULL AND end_behavior IN ('pause','cancel') THEN 'new_trial'
      WHEN trial_start IS NOT NULL THEN 'old_trial'
      ELSE 'other'
    END AS bucket,
    (sf.status = 'canceled' AND date_diff('second', sf.created, sf.canceled_at) <= 10) AS instant_cancel,
    (sf.status = 'canceled' AND date_diff('second', sf.created, sf.canceled_at) > 10) AS late_cancel,
    (hour(sf.created)*60+minute(sf.created)) < (SELECT hour(ts)*60+minute(ts) FROM latest) AS before_cutoff,
    sf.created >= timestamp '2026-10-01 11:15:00' AS in_clean
  FROM sf JOIN customers cu ON cu.id = sf.customer_id
),
daily AS (
  SELECT d,
    COUNT_IF(bucket='free') AS free,
    COUNT_IF(bucket='old_trial') AS old_trial,
    COUNT_IF(bucket='new_trial' AND NOT instant_cancel) AS new_trial,
    COUNT_IF(bucket IN ('free','old_trial') OR (bucket='new_trial' AND NOT instant_cancel)) AS total,
    COUNT_IF(before_cutoff AND (bucket IN ('free','old_trial') OR (bucket='new_trial' AND NOT instant_cancel))) AS total_to_cutoff,
    COUNT(DISTINCT CASE WHEN in_clean AND bucket IN ('free','old_trial') THEN person END) AS control_people,
    COUNT(DISTINCT CASE WHEN in_clean AND bucket='free' THEN person END) AS free_people,
    COUNT(DISTINCT CASE WHEN in_clean AND bucket='new_trial' AND NOT instant_cancel THEN person END) AS variant_people,
    COUNT_IF(bucket='new_trial' AND instant_cancel) AS system_cancels,
    COUNT_IF(bucket='new_trial' AND late_cancel) AS late_cancels,
    COUNT_IF(bucket='new_trial' AND status='trialing' AND schedule_id IS NOT NULL) AS sched_to_free,
    COUNT_IF(bucket='new_trial' AND status='paused') AS paused,
    COUNT_IF(bucket='new_trial' AND status='active') AS converted
  FROM c WHERE bucket <> 'other' GROUP BY d
),
base AS (
  SELECT day_of_week(d) <= 5 AS is_weekday, avg(total) AS avg_total, avg(total_to_cutoff) AS avg_to_cutoff
  FROM daily WHERE d BETWEEN date '2026-09-17' AND date '2026-09-30' GROUP BY 1
)
SELECT x.d AS day, date_format(cast(x.d AS timestamp), '%a') AS wd,
  date_diff('day', date '2026-10-01', x.d) AS day_n,
  (x.d = date(l.ts)) AS is_partial,
  x.free, x.old_trial, x.new_trial, x.total,
  w1.total AS total_1w_ago, w2.total AS total_2w_ago,
  round(100.0 * (x.total - (w1.total + w2.total) / 2.0) / ((w1.total + w2.total) / 2.0), 1) AS pct_vs_same_weekday,
  round(100.0 * (x.total - b.avg_total) / b.avg_total, 1) AS pct_vs_baseline,
  round(100.0 * (x.total_to_cutoff - b.avg_to_cutoff) / b.avg_to_cutoff, 1) AS pct_to_cutoff_vs_baseline,
  x.total_to_cutoff, w1.total_to_cutoff AS to_cutoff_1w_ago, w2.total_to_cutoff AS to_cutoff_2w_ago,
  round(100.0 * (x.total_to_cutoff - (w1.total_to_cutoff + w2.total_to_cutoff) / 2.0) / ((w1.total_to_cutoff + w2.total_to_cutoff) / 2.0), 1) AS pct_to_cutoff_vs_same_weekday,
  x.control_people, x.free_people, x.variant_people,
  round(cast(x.variant_people AS double) / nullif(x.free_people, 0), 2) AS variant_vs_free,
  sum(x.free_people) OVER (ORDER BY x.d) AS cum_free_people,
  sum(x.variant_people) OVER (ORDER BY x.d) AS cum_variant_people,
  round(cast(sum(x.variant_people) OVER (ORDER BY x.d) AS double) / nullif(sum(x.free_people) OVER (ORDER BY x.d), 0), 3) AS cum_variant_vs_free,
  round((sum(x.variant_people) OVER (ORDER BY x.d) - sum(x.free_people) OVER (ORDER BY x.d))
        / nullif(sqrt(sum(x.variant_people) OVER (ORDER BY x.d) + sum(x.free_people) OVER (ORDER BY x.d)), 0), 2) AS cum_z_variant_vs_free,
  x.system_cancels, x.late_cancels, x.sched_to_free, x.paused, x.converted,
  l.ts AS data_until
FROM daily x
CROSS JOIN latest l
LEFT JOIN daily w1 ON w1.d = date_add('day', -7, x.d)
LEFT JOIN daily w2 ON w2.d = date_add('day', -14, x.d)
LEFT JOIN base b ON b.is_weekday = (day_of_week(x.d) <= 5)
WHERE x.d >= date '2026-09-24'
ORDER BY x.d
