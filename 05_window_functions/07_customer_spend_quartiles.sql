-- Question: Which spending quartile does each customer fall into?
-- Technique: NTILE(4) to divide customers into 4 equal groups by total spend

WITH customer_spend AS (
    SELECT
        c.customer_id,
        c.customer_state,
        ROUND(SUM(oi.price), 2) AS total_spent
    FROM olist_customers_dataset         AS c
    INNER JOIN olist_orders_dataset      AS o  ON c.customer_id = o.customer_id
    INNER JOIN olist_order_items_dataset AS oi ON o.order_id    = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_id, c.customer_state
)
SELECT
    customer_id,
    customer_state,
    total_spent,
    NTILE(4) OVER (ORDER BY total_spent DESC) AS spend_quartile,
    CASE NTILE(4) OVER (ORDER BY total_spent DESC)
        WHEN 1 THEN 'Top 25%'
        WHEN 2 THEN '25–50%'
        WHEN 3 THEN '50–75%'
        WHEN 4 THEN 'Bottom 25%'
    END                                        AS spend_tier
FROM customer_spend
ORDER BY total_spent DESC
LIMIT 30;
