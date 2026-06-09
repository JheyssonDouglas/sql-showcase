-- Question: Which states have the best and worst on-time delivery rates?
-- Case: Delivery Performance (4a)

SELECT
    c.customer_state,
    COUNT(*) FILTER (WHERE o.order_status = 'delivered')     AS delivered_orders,
    COUNT(*) FILTER (
        WHERE o.order_delivered_customer_date <= o.order_estimated_delivery_date
          AND o.order_status = 'delivered'
    )                                                         AS on_time,
    ROUND(
        COUNT(*) FILTER (
            WHERE o.order_delivered_customer_date <= o.order_estimated_delivery_date
              AND o.order_status = 'delivered'
        ) * 100.0
        / NULLIF(COUNT(*) FILTER (WHERE o.order_status = 'delivered'), 0)
    , 1)                                                      AS on_time_rate_pct,
    ROUND(AVG(
        CASE WHEN o.order_status = 'delivered'
            THEN DATEDIFF('day',
                o.order_purchase_timestamp,
                o.order_delivered_customer_date)
        END
    ), 1)                                                     AS avg_delivery_days
FROM olist_orders_dataset          AS o
INNER JOIN olist_customers_dataset  AS c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
HAVING COUNT(*) FILTER (WHERE o.order_status = 'delivered') > 100
ORDER BY on_time_rate_pct DESC;
