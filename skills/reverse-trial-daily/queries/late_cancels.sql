-- Reverse-trial subscriptions canceled more than 10s after creation (real cancellations, not setup failures).
SELECT s.id, s.customer_id, s.created, s.canceled_at, date_diff('minute', s.created, s.canceled_at) AS min_to_cancel,
  s.cancellation_details_reason, s.cancellation_details_feedback,
  array_join(array_agg(DISTINCT pr.name), ' + ') AS products
FROM subscriptions s
JOIN subscription_items si ON s.id = si.subscription_id
JOIN prices p ON si.price_id = p.id
JOIN products pr ON p.product_id = pr.id
WHERE s.created >= timestamp '2026-10-01 00:00:00' AND s.status = 'canceled'
  AND s.trial_start IS NOT NULL AND s.trial_settings_end_behavior_missing_payment_method IN ('pause','cancel')
  AND s.id IN (SELECT si2.subscription_id FROM subscription_items si2 JOIN prices p2 ON si2.price_id=p2.id JOIN products pr2 ON p2.product_id=pr2.id WHERE pr2.name LIKE '%1MIL900K%')
  AND date_diff('second', s.created, s.canceled_at) > 10
GROUP BY 1,2,3,4,5,6,7 ORDER BY s.created
