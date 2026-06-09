-- Question: Are there orders with no payment record? (data quality check)
-- Technique: Anti-JOIN — LEFT JOIN where right side IS NULL

SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp
FROM olist_orders_dataset               AS o
LEFT JOIN olist_order_payments_dataset   AS p ON o.order_id = p.order_id
WHERE p.order_id IS NULL
ORDER BY o.order_purchase_timestamp DESC;
