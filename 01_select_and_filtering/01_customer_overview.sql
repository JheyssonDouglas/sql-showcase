-- Question: What does a customer record look like? What columns are available?
-- Technique: SELECT with column aliasing

SELECT
    customer_id,
    customer_unique_id,
    customer_city,
    customer_state,
    customer_zip_code_prefix AS zip_prefix
FROM olist_customers_dataset
LIMIT 10;
