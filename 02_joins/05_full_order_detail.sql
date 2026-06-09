-- Question: What is the complete picture of an order in a single query?
-- Technique: 7-table JOIN (customer → order → items → product → seller → payment → review)

SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    c.customer_city,
    c.customer_state,
    oi.order_item_id,
    oi.price,
    oi.freight_value,
    p.product_category_name,
    s.seller_state          AS seller_state,
    pay.payment_type,
    pay.payment_value,
    r.review_score
FROM olist_orders_dataset               AS o
INNER JOIN olist_customers_dataset      AS c   ON o.customer_id  = c.customer_id
INNER JOIN olist_order_items_dataset    AS oi  ON o.order_id     = oi.order_id
INNER JOIN olist_products_dataset       AS p   ON oi.product_id  = p.product_id
INNER JOIN olist_sellers_dataset        AS s   ON oi.seller_id   = s.seller_id
INNER JOIN olist_order_payments_dataset AS pay ON o.order_id     = pay.order_id
LEFT  JOIN olist_order_reviews_dataset  AS r   ON o.order_id     = r.order_id
LIMIT 10;
