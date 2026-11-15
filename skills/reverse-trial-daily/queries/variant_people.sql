-- Reverse-trial outcome per person (email), grouped by first signup day.
WITH rt AS (
  SELECT DISTINCT s.id, s.status, s.created, s.canceled_at, coalesce(lower(c.email), s.customer_id) AS email
  FROM subscriptions s
  JOIN customers c ON c.id = s.customer_id
  JOIN subscription_items si ON s.id = si.subscription_id
  JOIN prices p ON si.price_id = p.id
  JOIN products pr ON p.product_id = pr.id
  WHERE s.created >= timestamp '2026-10-01 00:00:00' AND pr.name LIKE '%1MIL900K%'
    AND s.trial_start IS NOT NULL AND s.trial_settings_end_behavior_missing_payment_method IN ('pause','cancel')
),
per_email AS (
  SELECT email, MIN(date(created)) AS first_day, COUNT(*) AS attempts,
    COUNT_IF(status='canceled' AND date_diff('second', created, canceled_at) <= 10) AS instant_cancels,
    bool_or(status='trialing') AS any_trialing, bool_or(status='paused') AS any_paused,
    bool_or(status='active') AS any_active,
    bool_or(status='canceled' AND date_diff('second', created, canceled_at) > 10) AS any_late_cancel,
    bool_or(status NOT IN ('trialing','paused','active','canceled')) AS any_other
  FROM rt GROUP BY 1
)
SELECT first_day,
  CASE WHEN any_active THEN 'active' WHEN any_trialing THEN 'trialing' WHEN any_paused THEN 'paused'
       WHEN any_late_cancel THEN 'canceled_later' WHEN any_other THEN 'other_status' ELSE 'only_instant_cancels' END AS outcome,
  COUNT(*) AS people, SUM(attempts) AS subs, SUM(instant_cancels) AS instant_cancels
FROM per_email GROUP BY 1,2 ORDER BY 1,2
