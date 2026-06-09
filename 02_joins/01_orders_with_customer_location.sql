-- Question: What city and state did each order come from?
-- Technique: INNER JOIN — only orders with a matching customer record

SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    c.customer_city,
    c.customer_state
FROM olist_orders_dataset          AS o
INNER JOIN olist_customers_dataset  AS c ON o.customer_id = c.customer_id
ORDER BY o.order_purchase_timestamp DESC
LIMIT 20;
