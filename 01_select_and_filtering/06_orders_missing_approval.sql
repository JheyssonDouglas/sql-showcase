-- Question: Which orders were never approved after being placed? Are there orders with a confirmed delivery?
-- Technique: IS NULL / IS NOT NULL for handling missing values

-- Orders that were never approved (potential data quality issue)
SELECT
    order_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at
FROM olist_orders_dataset
WHERE order_approved_at IS NULL
ORDER BY order_purchase_timestamp DESC
LIMIT 20;


-- Orders with confirmed delivery (non-null delivery timestamp)
SELECT
    order_id,
    order_status,
    order_delivered_customer_date
FROM olist_orders_dataset
WHERE order_delivered_customer_date IS NOT NULL
ORDER BY order_delivered_customer_date DESC
LIMIT 20;
