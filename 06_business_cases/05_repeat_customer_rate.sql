-- Question: What percentage of customers make more than one purchase?
-- Case: Customer Analysis (2b)

WITH customer_order_count AS (
    SELECT
        customer_id,
        COUNT(order_id) AS order_count
    FROM olist_orders_dataset
    GROUP BY customer_id
)
SELECT
    COUNT(*)                                                       AS total_customers,
    COUNT(*) FILTER (WHERE order_count > 1)                       AS repeat_customers,
    ROUND(COUNT(*) FILTER (WHERE order_count > 1) * 100.0
          / COUNT(*), 2)                                          AS repeat_rate_pct,
    ROUND(AVG(order_count), 2)                                    AS avg_orders_per_customer
FROM customer_order_count;
