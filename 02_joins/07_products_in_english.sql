-- Question: What are the product categories in English?
-- Technique: LEFT JOIN with COALESCE to handle products without a translation

SELECT
    p.product_id,
    p.product_category_name                               AS category_pt,
    COALESCE(t.product_category_name_english, 'unknown')  AS category_en,
    p.product_weight_g,
    p.product_length_cm
FROM olist_products_dataset                AS p
LEFT JOIN product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name
ORDER BY p.product_category_name
LIMIT 20;
