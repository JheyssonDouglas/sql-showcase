-- Question: Which product categories generate the most revenue?
-- Technique: Multi-table JOIN + GROUP BY + COALESCE for category translation

SELECT
    COALESCE(t.product_category_name_english, p.product_category_name) AS category,
    COUNT(DISTINCT oi.order_id)     AS total_orders,
    COUNT(oi.order_item_id)         AS total_items_sold,
    ROUND(SUM(oi.price), 2)         AS total_revenue,
    ROUND(AVG(oi.price), 2)         AS avg_item_price
FROM olist_order_items_dataset               AS oi
INNER JOIN olist_products_dataset            AS p  ON oi.product_id           = p.product_id
LEFT  JOIN product_category_name_translation AS t  ON p.product_category_name = t.product_category_name
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 10;
