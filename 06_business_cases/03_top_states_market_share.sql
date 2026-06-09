-- Question: Which states generate the most revenue and what is each state's market share?
-- Case: Revenue Analysis (1c)

WITH state_revenue AS (
    SELECT
        c.customer_state,
        ROUND(SUM(oi.price), 2) AS revenue
    FROM olist_customers_dataset         AS c
    INNER JOIN olist_orders_dataset      AS o  ON c.customer_id = o.customer_id
    INNER JOIN olist_order_items_dataset AS oi ON o.order_id    = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_state
)
SELECT
    customer_state,
    revenue,
    ROUND(revenue / SUM(revenue) OVER () * 100, 2)   AS market_share_pct,
    RANK() OVER (ORDER BY revenue DESC)               AS revenue_rank
FROM state_revenue
ORDER BY revenue_rank
LIMIT 10;
