-- Question: Who are the top 20 customers by lifetime revenue?
-- Case: Customer Analysis (2c)

SELECT
    c.customer_id,
    c.customer_city,
    c.customer_state,
    COUNT(DISTINCT o.order_id)       AS total_orders,
    ROUND(SUM(oi.price), 2)          AS lifetime_revenue,
    ROUND(AVG(oi.price), 2)          AS avg_item_value,
    MIN(o.order_purchase_timestamp)  AS first_purchase,
    MAX(o.order_purchase_timestamp)  AS last_purchase,
    DATEDIFF('day',
        MIN(o.order_purchase_timestamp),
        MAX(o.order_purchase_timestamp)) AS customer_lifespan_days
FROM olist_customers_dataset         AS c
INNER JOIN olist_orders_dataset      AS o  ON c.customer_id = o.customer_id
INNER JOIN olist_order_items_dataset AS oi ON o.order_id    = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_id, c.customer_city, c.customer_state
ORDER BY lifetime_revenue DESC
LIMIT 20;
