/*
===============================================================================
  JOINs
  Brazilian E-Commerce Public Dataset by Olist
===============================================================================

  Covers:
  - INNER JOIN — matching rows in both tables
  - LEFT JOIN  — all rows from left, matched rows from right
  - Multi-table JOINs — combining 3+ tables
  - Anti-JOIN pattern — rows in A with no match in B
  - JOIN with aggregation
  - Self-join concept applied to the dataset
===============================================================================
*/

-- ============================================================================
-- 1. INNER JOIN — Orders with Customer Information
--    Only orders that have a matching customer record
-- ============================================================================

SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    c.customer_city,
    c.customer_state
FROM olist_orders_dataset        AS o
INNER JOIN olist_customers_dataset AS c
    ON o.customer_id = c.customer_id
ORDER BY o.order_purchase_timestamp DESC
LIMIT 20;


-- ============================================================================
-- 2. LEFT JOIN — Orders with Their Reviews
--    All orders, including those without a review
-- ============================================================================

SELECT
    o.order_id,
    o.order_status,
    r.review_score,
    r.review_comment_title
FROM olist_orders_dataset      AS o
LEFT JOIN olist_order_reviews_dataset AS r
    ON o.order_id = r.order_id
ORDER BY r.review_score ASC NULLS LAST
LIMIT 20;


-- ============================================================================
-- 3. ANTI-JOIN — Orders Without Any Payment Record
--    Useful for finding data quality issues
-- ============================================================================

SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp
FROM olist_orders_dataset          AS o
LEFT JOIN olist_order_payments_dataset AS p
    ON o.order_id = p.order_id
WHERE p.order_id IS NULL
ORDER BY o.order_purchase_timestamp DESC;


-- ============================================================================
-- 4. MULTI-TABLE JOIN — Order Items with Product and Seller Details
--    Combining order_items + products + sellers in a single query
-- ============================================================================

SELECT
    oi.order_id,
    oi.order_item_id,
    oi.price,
    oi.freight_value,
    p.product_category_name,
    p.product_weight_g,
    s.seller_city,
    s.seller_state
FROM olist_order_items_dataset AS oi
INNER JOIN olist_products_dataset  AS p  ON oi.product_id = p.product_id
INNER JOIN olist_sellers_dataset   AS s  ON oi.seller_id  = s.seller_id
ORDER BY oi.price DESC
LIMIT 20;


-- ============================================================================
-- 5. FULL ORDER DETAILS
--    Everything about an order in one query:
--    customer → order → items → product → seller → payment → review
-- ============================================================================

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
    s.seller_state                  AS seller_state,
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


-- ============================================================================
-- 6. JOIN WITH AGGREGATION — Revenue per Seller
--    Total revenue and order count for each seller
-- ============================================================================

SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id)        AS total_orders,
    ROUND(SUM(oi.price), 2)            AS total_revenue,
    ROUND(AVG(oi.price), 2)            AS avg_item_price
FROM olist_sellers_dataset          AS s
INNER JOIN olist_order_items_dataset AS oi ON s.seller_id = oi.seller_id
GROUP BY s.seller_id, s.seller_city, s.seller_state
ORDER BY total_revenue DESC
LIMIT 20;


-- ============================================================================
-- 7. JOIN WITH CATEGORY TRANSLATION
--    Olist products have Portuguese category names — translate them to English
-- ============================================================================

SELECT
    p.product_id,
    p.product_category_name                           AS category_pt,
    COALESCE(t.product_category_name_english, 'unknown') AS category_en,
    p.product_weight_g,
    p.product_length_cm
FROM olist_products_dataset                AS p
LEFT JOIN product_category_name_translation AS t
    ON p.product_category_name = t.product_category_name
ORDER BY p.product_category_name
LIMIT 20;


-- ============================================================================
-- 8. LEFT JOIN TO IDENTIFY INCOMPLETE ORDERS
--    Orders that were approved but never shipped
-- ============================================================================

SELECT
    o.order_id,
    o.order_status,
    o.order_approved_at,
    o.order_delivered_carrier_date
FROM olist_orders_dataset AS o
WHERE o.order_approved_at              IS NOT NULL
  AND o.order_delivered_carrier_date   IS NULL
  AND o.order_status NOT IN ('canceled', 'unavailable')
ORDER BY o.order_approved_at DESC
LIMIT 20;
