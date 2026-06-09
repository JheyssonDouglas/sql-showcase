-- Question: How many orders are in each status, and what percentage of the total?
-- Technique: GROUP BY with inline window function for percentage

SELECT
    order_status,
    COUNT(*)                                                        AS total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)             AS pct_of_total
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY total_orders DESC;
