-- Question: Which sellers have processed more than 100 orders?
-- Technique: HAVING — filtering groups after aggregation

SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id)   AS total_orders,
    ROUND(SUM(oi.price), 2)       AS total_revenue
FROM olist_sellers_dataset             AS s
INNER JOIN olist_order_items_dataset    AS oi ON s.seller_id = oi.seller_id
GROUP BY s.seller_id, s.seller_city, s.seller_state
HAVING COUNT(DISTINCT oi.order_id) > 100
ORDER BY total_orders DESC;
