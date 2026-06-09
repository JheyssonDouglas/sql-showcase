-- Question: How many distinct order statuses exist? How many unique customers placed orders?
-- Technique: DISTINCT, COUNT DISTINCT

-- All distinct order statuses
SELECT DISTINCT order_status
FROM olist_orders_dataset
ORDER BY order_status;


-- Unique customer count across all orders
SELECT
    COUNT(*)                       AS total_order_records,
    COUNT(DISTINCT customer_id)    AS unique_customers
FROM olist_orders_dataset;
