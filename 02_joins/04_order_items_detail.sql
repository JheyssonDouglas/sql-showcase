-- Question: What product category and seller state is each order item from?
-- Technique: 3-table INNER JOIN (order_items + products + sellers)

SELECT
    oi.order_id,
    oi.order_item_id,
    oi.price,
    oi.freight_value,
    p.product_category_name,
    p.product_weight_g,
    s.seller_city,
    s.seller_state
FROM olist_order_items_dataset  AS oi
INNER JOIN olist_products_dataset AS p ON oi.product_id = p.product_id
INNER JOIN olist_sellers_dataset  AS s ON oi.seller_id  = s.seller_id
ORDER BY oi.price DESC
LIMIT 20;
