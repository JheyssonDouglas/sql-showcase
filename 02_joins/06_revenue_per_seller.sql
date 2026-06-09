-- Question: What is each seller's total revenue and order count?
-- Technique: JOIN with GROUP BY aggregation

SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id)   AS total_orders,
    ROUND(SUM(oi.price), 2)       AS total_revenue,
    ROUND(AVG(oi.price), 2)       AS avg_item_price
FROM olist_sellers_dataset            AS s
INNER JOIN olist_order_items_dataset   AS oi ON s.seller_id = oi.seller_id
GROUP BY s.seller_id, s.seller_city, s.seller_state
ORDER BY total_revenue DESC
LIMIT 20;
