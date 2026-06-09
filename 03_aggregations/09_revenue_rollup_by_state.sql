-- Question: What is the total revenue per state, with a grand total row?
-- Technique: ROLLUP for hierarchical subtotals

SELECT
    COALESCE(c.customer_state, 'ALL STATES')  AS customer_state,
    COUNT(DISTINCT o.order_id)                AS total_orders,
    ROUND(SUM(oi.price), 2)                   AS total_revenue
FROM olist_customers_dataset            AS c
INNER JOIN olist_orders_dataset         AS o  ON c.customer_id = o.customer_id
INNER JOIN olist_order_items_dataset    AS oi ON o.order_id    = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY ROLLUP(c.customer_state)
ORDER BY total_revenue DESC NULLS LAST;
