-- Question: What is the monthly revenue and order volume trend?
-- Case: Revenue Analysis (1a)

SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)    AS month,
    COUNT(DISTINCT o.order_id)                         AS total_orders,
    ROUND(SUM(oi.price), 2)                            AS product_revenue,
    ROUND(SUM(oi.freight_value), 2)                    AS freight_revenue,
    ROUND(SUM(oi.price + oi.freight_value), 2)         AS total_revenue
FROM olist_orders_dataset            AS o
INNER JOIN olist_order_items_dataset  AS oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY month
ORDER BY month;
