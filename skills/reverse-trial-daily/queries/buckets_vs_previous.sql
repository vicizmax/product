-- Free / old trial / new trial per day since 2026-09-01; *_to_cutoff = same time-of-day cut as the latest data point.
WITH latest AS (SELECT max(created) AS ts FROM subscriptions),
sf AS (
  SELECT s.id, s.customer_id, s.created, s.trial_start, s.status, s.canceled_at,
    s.trial_settings_end_behavior_missing_payment_method AS end_behavior,
    bool_or(pr.name LIKE 'SonarCloud Free%') AS is_free,
    bool_or(pr.name LIKE '%1MIL900K%') AS is_1m9
  FROM subscriptions s
  JOIN subscription_items si ON s.id = si.subscription_id
  JOIN prices p ON si.price_id = p.id
  JOIN products pr ON p.product_id = pr.id
  WHERE s.created >= timestamp '2026-09-01 00:00:00'
  GROUP BY 1,2,3,4,5,6,7
),
c AS (
  SELECT sf.*,
    CASE
      WHEN is_free THEN 'free'
      WHEN is_1m9 AND trial_start IS NOT NULL AND end_behavior IN ('pause','cancel') THEN 'new_trial'
      WHEN trial_start IS NOT NULL THEN 'old_trial'
      ELSE 'other'
    END AS bucket,
    (sf.status = 'canceled' AND date_diff('second', sf.created, sf.canceled_at) <= 10) AS instant_cancel,
    (hour(sf.created)*60+minute(sf.created)) < (SELECT hour(ts)*60+minute(ts) FROM latest) AS before_cutoff
  FROM sf
)
SELECT date(created) AS day, day_of_week(created) AS dow,
  COUNT_IF(bucket='free') AS free,
  COUNT_IF(bucket='old_trial') AS old_trial,
  COUNT_IF(bucket='new_trial' AND NOT instant_cancel) AS new_trial,
  COUNT_IF(bucket IN ('free','old_trial') OR (bucket='new_trial' AND NOT instant_cancel)) AS total,
  COUNT_IF(before_cutoff AND bucket='free') AS free_to_cutoff,
  COUNT_IF(before_cutoff AND bucket='old_trial') AS old_trial_to_cutoff,
  COUNT_IF(before_cutoff AND bucket='new_trial' AND NOT instant_cancel) AS new_trial_to_cutoff,
  COUNT_IF(before_cutoff AND (bucket IN ('free','old_trial') OR (bucket='new_trial' AND NOT instant_cancel))) AS total_to_cutoff,
  (SELECT ts FROM latest) AS cutoff_ts
FROM c GROUP BY 1,2 ORDER BY 1
