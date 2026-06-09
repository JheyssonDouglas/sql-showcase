-- Question: Which states generate the most revenue? What is the average order value per state?
-- Technique: Multi-table GROUP BY with SUM, AVG, COUNT DISTINCT

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id)                                         AS total_orders,
    ROUND(SUM(oi.price), 2)                                            AS total_revenue,
    ROUND(AVG(oi.price), 2)                                            AS avg_item_price,
    ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2)              AS avg_order_value
FROM olist_customers_dataset            AS c
INNER JOIN olist_orders_dataset         AS o  ON c.customer_id = o.customer_id
INNER JOIN olist_order_items_dataset    AS oi ON o.order_id    = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;
