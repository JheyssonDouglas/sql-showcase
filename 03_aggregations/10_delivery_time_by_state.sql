-- Question: What is the average, minimum, and maximum delivery time (in days) per state?
-- Technique: DATEDIFF with GROUP BY

SELECT
    c.customer_state,
    COUNT(*)                                                                AS delivered_orders,
    ROUND(AVG(
        DATEDIFF('day', o.order_purchase_timestamp, o.order_delivered_customer_date)
    ), 1)                                                                   AS avg_delivery_days,
    MIN(DATEDIFF('day', o.order_purchase_timestamp, o.order_delivered_customer_date)) AS min_delivery_days,
    MAX(DATEDIFF('day', o.order_purchase_timestamp, o.order_delivered_customer_date)) AS max_delivery_days
FROM olist_orders_dataset          AS o
INNER JOIN olist_customers_dataset  AS c ON o.customer_id = c.customer_id
WHERE o.order_status                   = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days;
