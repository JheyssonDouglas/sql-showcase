-- Question: What was each customer's first and last order date?
-- Technique: FIRST_VALUE() / LAST_VALUE() with full partition frame

SELECT DISTINCT
    customer_id,
    FIRST_VALUE(order_purchase_timestamp) OVER (
        PARTITION BY customer_id
        ORDER BY order_purchase_timestamp
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS first_order_date,
    LAST_VALUE(order_purchase_timestamp) OVER (
        PARTITION BY customer_id
        ORDER BY order_purchase_timestamp
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_order_date
FROM olist_orders_dataset
ORDER BY customer_id
LIMIT 20;
