-- Question: How many delivered orders were placed each month?
-- Technique: DATE_TRUNC to group timestamps by month

SELECT
    DATE_TRUNC('month', order_purchase_timestamp) AS order_month,
    COUNT(*)                                       AS total_orders
FROM olist_orders_dataset
WHERE order_status = 'delivered'
GROUP BY order_month
ORDER BY order_month;
