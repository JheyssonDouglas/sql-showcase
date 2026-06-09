-- Question: What is each customer's most recent order?
-- Technique: QUALIFY — DuckDB filter on window function result (no outer CTE needed)

SELECT
    customer_id,
    order_id,
    order_purchase_timestamp,
    order_status
FROM olist_orders_dataset
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY customer_id
    ORDER BY order_purchase_timestamp DESC
) = 1
ORDER BY order_purchase_timestamp DESC
LIMIT 20;
