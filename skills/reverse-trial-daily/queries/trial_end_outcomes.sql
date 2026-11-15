-- What happens at trial end for every reverse-trial subscription started since launch:
-- pause (default, no card) / scheduled to Free (subscription schedule) / continuing on Team (card added) / ended.
WITH has_pm AS (SELECT DISTINCT customer_id FROM payment_methods WHERE customer_id IS NOT NULL),
rt AS (
  SELECT DISTINCT s.id, s.customer_id, s.status, s.schedule_id, s.trial_end, s.created,
    s.trial_settings_end_behavior_missing_payment_method AS end_behavior
  FROM subscriptions s
  JOIN subscription_items si ON s.id = si.subscription_id
  JOIN prices p ON si.price_id = p.id
  JOIN products pr ON p.product_id = pr.id
  WHERE s.created >= timestamp '2026-10-01 00:00:00' AND pr.name LIKE '%1MIL900K%' AND s.trial_start IS NOT NULL
    -- reverse trial = end behavior pause (default) or cancel (Free-downgrade schedule); old card trials use create_invoice
    AND s.trial_settings_end_behavior_missing_payment_method IN ('pause','cancel')
),
next_phase AS (
  SELECT ph.schedule_id, array_join(array_agg(DISTINCT pr.name), ' + ') AS next_products
  FROM subscription_schedule_phases ph
  JOIN rt ON rt.schedule_id = ph.schedule_id AND ph.start_date >= rt.trial_end
  JOIN subscription_schedule_phase_configuration_items ci ON ci.phase_id = ph.id
  JOIN prices p ON p.id = ci.price
  JOIN products pr ON pr.id = p.product_id
  GROUP BY 1
)
SELECT
  CASE
    WHEN rt.status = 'canceled' THEN 'ended (canceled)'
    WHEN rt.status = 'paused' THEN 'already paused (trial ended, no card)'
    WHEN rt.status = 'active' THEN 'converted (paid Team)'
    WHEN np.next_products LIKE '%Free%' THEN 'scheduled -> Free at trial end'
    WHEN np.next_products IS NOT NULL THEN 'scheduled -> ' || np.next_products
    WHEN hp.customer_id IS NOT NULL THEN 'card added -> continues on Team'
    ELSE 'nothing scheduled -> pauses at trial end'
  END AS trial_end_outcome,
  COUNT(*) AS subs,
  MIN(rt.trial_end) AS first_trial_end, MAX(rt.trial_end) AS last_trial_end,
  COUNT_IF(rt.status = 'trialing' AND rt.trial_end < current_timestamp + INTERVAL '2' DAY) AS ending_within_48h
FROM rt
LEFT JOIN next_phase np ON np.schedule_id = rt.schedule_id
LEFT JOIN has_pm hp ON hp.customer_id = rt.customer_id
GROUP BY 1 ORDER BY 2 DESC
