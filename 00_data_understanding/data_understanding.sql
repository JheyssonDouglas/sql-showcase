/*
===============================================================================
  Data Understanding
  Brazilian E-Commerce Public Dataset by Olist
===============================================================================

  Goal:
  Explore the structure, schema, and content of each table before writing
  analytical queries. Covers column types, row counts, NULLs, date ranges,
  and key value distributions.

  Tables:
  - olist_customers_dataset
  - olist_orders_dataset
  - olist_order_items_dataset
  - olist_products_dataset
  - olist_sellers_dataset
  - olist_order_payments_dataset
  - olist_order_reviews_dataset
  - product_category_name_translation
===============================================================================
*/

-- ============================================================================
-- 1. LIST ALL TABLES
-- ============================================================================

SHOW TABLES;


-- ============================================================================
-- 2. CUSTOMERS
-- ============================================================================

-- Schema
DESCRIBE olist_customers_dataset;

-- Sample rows
SELECT *
FROM olist_customers_dataset
LIMIT 5;

-- Row count and completeness
SELECT
    COUNT(*)                                           AS total_rows,
    COUNT(DISTINCT customer_id)                        AS unique_customer_ids,
    COUNT(DISTINCT customer_unique_id)                 AS unique_customers,
    COUNT(*) - COUNT(customer_id)                      AS null_customer_id,
    COUNT(*) - COUNT(customer_unique_id)               AS null_unique_id,
    COUNT(*) - COUNT(customer_city)                    AS null_city,
    COUNT(*) - COUNT(customer_state)                   AS null_state
FROM olist_customers_dataset;

-- Note: customer_id is order-scoped. customer_unique_id is the stable identifier.
-- The same customer can appear multiple times with different customer_id values.

-- Customer distribution by state (top 10)
SELECT
    customer_state,
    COUNT(DISTINCT customer_unique_id)                 AS unique_customers,
    ROUND(COUNT(DISTINCT customer_unique_id) * 100.0
          / SUM(COUNT(DISTINCT customer_unique_id)) OVER (), 2) AS pct
FROM olist_customers_dataset
GROUP BY customer_state
ORDER BY unique_customers DESC
LIMIT 10;


-- ============================================================================
-- 3. ORDERS
-- ============================================================================

-- Schema
DESCRIBE olist_orders_dataset;

-- Sample rows
SELECT *
FROM olist_orders_dataset
LIMIT 5;

-- Row count and NULL check on key timestamp columns
SELECT
    COUNT(*)                                           AS total_orders,
    COUNT(DISTINCT order_id)                           AS unique_orders,
    COUNT(*) - COUNT(order_approved_at)                AS null_approved_at,
    COUNT(*) - COUNT(order_delivered_carrier_date)     AS null_carrier_date,
    COUNT(*) - COUNT(order_delivered_customer_date)    AS null_customer_date,
    COUNT(*) - COUNT(order_estimated_delivery_date)    AS null_estimated_date
FROM olist_orders_dataset;

-- Order status distribution
SELECT
    order_status,
    COUNT(*)                                           AS total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY total DESC;

-- Date range of orders
SELECT
    MIN(order_purchase_timestamp)::DATE                AS earliest_order,
    MAX(order_purchase_timestamp)::DATE                AS latest_order,
    DATEDIFF('day',
        MIN(order_purchase_timestamp),
        MAX(order_purchase_timestamp))                 AS date_range_days
FROM olist_orders_dataset;


-- ============================================================================
-- 4. ORDER ITEMS
-- ============================================================================

-- Schema
DESCRIBE olist_order_items_dataset;

-- Sample rows
SELECT *
FROM olist_order_items_dataset
LIMIT 5;

-- Row count and key metrics
SELECT
    COUNT(*)                                           AS total_order_items,
    COUNT(DISTINCT order_id)                           AS unique_orders,
    COUNT(DISTINCT product_id)                         AS unique_products,
    COUNT(DISTINCT seller_id)                          AS unique_sellers,
    ROUND(MIN(price), 2)                               AS min_price,
    ROUND(AVG(price), 2)                               AS avg_price,
    ROUND(MAX(price), 2)                               AS max_price,
    ROUND(MIN(freight_value), 2)                       AS min_freight,
    ROUND(AVG(freight_value), 2)                       AS avg_freight,
    ROUND(MAX(freight_value), 2)                       AS max_freight
FROM olist_order_items_dataset;

-- Items per order distribution
SELECT
    items_per_order,
    COUNT(*)                                           AS order_count
FROM (
    SELECT order_id, COUNT(*) AS items_per_order
    FROM olist_order_items_dataset
    GROUP BY order_id
) AS sub
GROUP BY items_per_order
ORDER BY items_per_order;


-- ============================================================================
-- 5. PRODUCTS
-- ============================================================================

-- Schema
DESCRIBE olist_products_dataset;

-- Sample rows
SELECT *
FROM olist_products_dataset
LIMIT 5;

-- Row count and NULL check
SELECT
    COUNT(*)                                           AS total_products,
    COUNT(DISTINCT product_id)                         AS unique_products,
    COUNT(*) - COUNT(product_category_name)            AS null_category,
    COUNT(*) - COUNT(product_weight_g)                 AS null_weight,
    COUNT(*) - COUNT(product_length_cm)                AS null_dimensions
FROM olist_products_dataset;

-- Top 10 categories by product count
SELECT
    COALESCE(t.product_category_name_english,
             p.product_category_name, 'uncategorized') AS category,
    COUNT(*)                                           AS product_count
FROM olist_products_dataset                    AS p
LEFT JOIN product_category_name_translation    AS t
    ON p.product_category_name = t.product_category_name
GROUP BY category
ORDER BY product_count DESC
LIMIT 10;


-- ============================================================================
-- 6. SELLERS
-- ============================================================================

-- Schema
DESCRIBE olist_sellers_dataset;

-- Sample rows
SELECT *
FROM olist_sellers_dataset
LIMIT 5;

-- Row count and distribution by state
SELECT
    COUNT(*)                                           AS total_sellers,
    COUNT(DISTINCT seller_id)                          AS unique_sellers,
    COUNT(DISTINCT seller_state)                       AS distinct_states,
    COUNT(DISTINCT seller_city)                        AS distinct_cities
FROM olist_sellers_dataset;

-- Top 10 seller states
SELECT
    seller_state,
    COUNT(*)                                           AS seller_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct
FROM olist_sellers_dataset
GROUP BY seller_state
ORDER BY seller_count DESC
LIMIT 10;


-- ============================================================================
-- 7. ORDER PAYMENTS
-- ============================================================================

-- Schema
DESCRIBE olist_order_payments_dataset;

-- Sample rows
SELECT *
FROM olist_order_payments_dataset
LIMIT 5;

-- Row count and payment type distribution
SELECT
    COUNT(*)                                           AS total_payment_records,
    COUNT(DISTINCT order_id)                           AS unique_orders
FROM olist_order_payments_dataset;

SELECT
    payment_type,
    COUNT(*)                                           AS total_records,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_records,
    ROUND(SUM(payment_value), 2)                       AS total_value,
    ROUND(AVG(payment_value), 2)                       AS avg_value,
    ROUND(AVG(payment_installments), 1)                AS avg_installments
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY total_records DESC;


-- ============================================================================
-- 8. ORDER REVIEWS
-- ============================================================================

-- Schema
DESCRIBE olist_order_reviews_dataset;

-- Sample rows
SELECT *
FROM olist_order_reviews_dataset
LIMIT 5;

-- Row count and score distribution
SELECT
    COUNT(*)                                           AS total_reviews,
    COUNT(DISTINCT order_id)                           AS unique_orders_reviewed,
    COUNT(*) - COUNT(review_comment_message)           AS reviews_without_comment,
    ROUND(AVG(review_score), 2)                        AS avg_score
FROM olist_order_reviews_dataset;

SELECT
    review_score,
    COUNT(*)                                           AS total,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct
FROM olist_order_reviews_dataset
GROUP BY review_score
ORDER BY review_score;


-- ============================================================================
-- 9. CATEGORY TRANSLATION
-- ============================================================================

-- Sample rows
SELECT *
FROM product_category_name_translation
LIMIT 10;

-- How many categories have a translation?
SELECT
    COUNT(*)                                           AS total_translations,
    COUNT(DISTINCT product_category_name)              AS unique_pt_names,
    COUNT(DISTINCT product_category_name_english)      AS unique_en_names
FROM product_category_name_translation;
