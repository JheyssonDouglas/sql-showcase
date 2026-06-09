-- Question: In what order did each customer place their orders?
-- Technique: ROW_NUMBER() PARTITION BY customer — sequential numbering within each customer

SELECT
    customer_id,
    order_id,
    order_purchase_timestamp,
    ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY order_purchase_timestamp
    ) AS order_sequence
FROM olist_orders_dataset
ORDER BY customer_id, order_sequence
LIMIT 30;
