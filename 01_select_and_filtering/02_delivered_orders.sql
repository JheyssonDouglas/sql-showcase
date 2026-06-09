-- Question: Which orders have been successfully delivered?
-- Technique: WHERE equality filter, ORDER BY, LIMIT

SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_delivered_customer_date
FROM olist_orders_dataset
WHERE order_status = 'delivered'
ORDER BY order_purchase_timestamp DESC
LIMIT 20;
