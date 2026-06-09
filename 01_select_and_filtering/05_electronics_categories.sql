-- Question: Which product categories are electronics-related?
-- Technique: ILIKE for case-insensitive pattern matching

SELECT DISTINCT
    product_category_name
FROM olist_products_dataset
WHERE product_category_name ILIKE '%eletro%'
ORDER BY product_category_name;
