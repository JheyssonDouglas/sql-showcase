-- Question: Which products weigh between 500g and 2kg?
-- Technique: BETWEEN for numeric range filtering

SELECT
    product_id,
    product_category_name,
    product_weight_g,
    product_length_cm,
    product_height_cm,
    product_width_cm
FROM olist_products_dataset
WHERE product_weight_g BETWEEN 500 AND 2000
ORDER BY product_weight_g DESC
LIMIT 20;
