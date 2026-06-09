-- Question: Which orders were approved but never picked up by the carrier?
-- Technique: Filtered LEFT JOIN using WHERE on timestamp columns

SELECT
    o.order_id,
    o.order_status,
    o.order_approved_at,
    o.order_delivered_carrier_date
FROM olist_orders_dataset AS o
WHERE o.order_approved_at              IS NOT NULL
  AND o.order_delivered_carrier_date   IS NULL
  AND o.order_status NOT IN ('canceled', 'unavailable')
ORDER BY o.order_approved_at DESC
LIMIT 20;
