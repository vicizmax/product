-- Control vs variant people per flag window (minutes since 00:00 UTC). Windows match the 2026-10-01 flag log;
-- from 2026-10-02 the flag is on all day so only window 4 / the whole day matters. Update when the flag log changes.
WITH sf AS (
  SELECT s.id, s.customer_id, s.created, s.trial_start, s.status, s.canceled_at,
    s.trial_settings_end_behavior_missing_payment_method AS end_behavior,
    bool_or(pr.name LIKE 'SonarCloud Free%') AS is_free,
    bool_or(pr.name LIKE '%1MIL900K%') AS is_1m9
  FROM subscriptions s
  JOIN subscription_items si ON s.id = si.subscription_id
  JOIN prices p ON si.price_id = p.id
  JOIN products pr ON p.product_id = pr.id
  WHERE s.created >= timestamp '2026-09-17 00:00:00'
  GROUP BY 1,2,3,4,5,6,7
),
c AS (
  SELECT sf.*, coalesce(lower(cu.email), sf.customer_id) AS person,
    CASE
      WHEN is_free THEN 'free'
      WHEN is_1m9 AND trial_start IS NOT NULL AND end_behavior IN ('pause','cancel') THEN 'new_trial'
      WHEN trial_start IS NOT NULL THEN 'old_trial'
      ELSE 'other'
    END AS bucket,
    (sf.status = 'canceled' AND date_diff('second', sf.created, sf.canceled_at) <= 10) AS instant_cancel,
    CASE
      WHEN hour(sf.created)*60+minute(sf.created) < 498 THEN '1_pre_0000_0818'
      WHEN hour(sf.created)*60+minute(sf.created) < 570 THEN '2_on_0818_0929'
      WHEN hour(sf.created)*60+minute(sf.created) < 675 THEN '3_off_0930_1115'
      ELSE '4_on_1115_2400' END AS win
  FROM sf JOIN customers cu ON cu.id = sf.customer_id
)
SELECT date(created) AS day, day_of_week(created) AS dow, win,
  COUNT_IF(bucket='free') AS free_subs,
  COUNT_IF(bucket='old_trial') AS old_trial_subs,
  COUNT(DISTINCT CASE WHEN bucket IN ('free','old_trial') THEN person END) AS control_people,
  COUNT(DISTINCT CASE WHEN bucket='free' THEN person END) AS free_people,
  COUNT_IF(bucket='new_trial') AS new_trial_subs,
  COUNT_IF(bucket='new_trial' AND instant_cancel) AS new_trial_instant_cancels,
  COUNT(DISTINCT CASE WHEN bucket='new_trial' AND NOT instant_cancel THEN person END) AS variant_people,
  MAX(created) AS last_ts
FROM c WHERE bucket <> 'other'
GROUP BY 1,2,3 ORDER BY 1,3
