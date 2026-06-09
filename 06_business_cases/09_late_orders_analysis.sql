-- Question: How many days late are delayed orders on average, per state?
-- Case: Delivery Performance (4b)

SELECT
    c.customer_state,
    COUNT(*)                                    AS late_orders,
    ROUND(AVG(
        DATEDIFF('day',
            o.order_estimated_delivery_date,
            o.order_delivered_customer_date)
    ), 1)                                       AS avg_days_late,
    MAX(
        DATEDIFF('day',
            o.order_estimated_delivery_date,
            o.order_delivered_customer_date)
    )                                           AS max_days_late
FROM olist_orders_dataset           AS o
INNER JOIN olist_customers_dataset   AS c ON o.customer_id = c.customer_id
WHERE o.order_status                     = 'delivered'
  AND o.order_delivered_customer_date    > o.order_estimated_delivery_date
GROUP BY c.customer_state
ORDER BY avg_days_late DESC;
