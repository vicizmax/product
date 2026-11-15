-- Clean-window people per arm, split by pre-experiment history (main arm comparison).
-- existing = the email had any subscription before 2026-10-01 11:15 UTC. Fixed cut so both arms are treated alike
-- (an in-experiment retry or second org doesn't make someone "existing").
WITH prior AS (
  SELECT DISTINCT coalesce(lower(cu.email), s.customer_id) AS person
  FROM subscriptions s JOIN customers cu ON cu.id = s.customer_id
  WHERE s.created < timestamp '2026-10-01 11:15:00'
),
sf AS (
  SELECT s.id, s.customer_id, s.created, s.trial_start, s.status, s.canceled_at,
    s.trial_settings_end_behavior_missing_payment_method AS end_behavior,
    bool_or(pr.name LIKE 'SonarCloud Free%') AS is_free,
    bool_or(pr.name LIKE '%1MIL900K%') AS is_1m9
  FROM subscriptions s
  JOIN subscription_items si ON s.id = si.subscription_id
  JOIN prices p ON si.price_id = p.id
  JOIN products pr ON p.product_id = pr.id
  WHERE s.created >= timestamp '2026-10-01 11:15:00'
  GROUP BY 1,2,3,4,5,6,7
),
c AS (
  SELECT date(sf.created) AS d, coalesce(lower(cu.email), sf.customer_id) AS person,
    CASE WHEN is_free THEN 'free'
         WHEN is_1m9 AND trial_start IS NOT NULL AND end_behavior IN ('pause','cancel') THEN 'new_trial'
         WHEN trial_start IS NOT NULL THEN 'old_trial' ELSE 'other' END AS bucket,
    (sf.status = 'canceled' AND date_diff('second', sf.created, sf.canceled_at) <= 10) AS instant_cancel
  FROM sf JOIN customers cu ON cu.id = sf.customer_id
)
SELECT d, (pr.person IS NOT NULL) AS existing,
  COUNT(DISTINCT CASE WHEN bucket='free' THEN c.person END) AS free_people,
  COUNT(DISTINCT CASE WHEN bucket='old_trial' THEN c.person END) AS old_trial_people,
  COUNT(DISTINCT CASE WHEN bucket IN ('free','old_trial') THEN c.person END) AS control_people,
  COUNT(DISTINCT CASE WHEN bucket='new_trial' AND NOT instant_cancel THEN c.person END) AS variant_people
FROM c LEFT JOIN prior pr ON pr.person = c.person
WHERE bucket <> 'other'
GROUP BY 1,2 ORDER BY 1,2
