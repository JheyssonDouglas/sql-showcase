/*
===============================================================================
  Relationship Validation
  Brazilian E-Commerce Public Dataset by Olist
===============================================================================

  Goal:
  Validate referential integrity and cardinalities between tables before
  writing analytical queries. Identify orphan records, duplicate keys,
  and unexpected join behaviors.

  Checks:
  1. Primary key uniqueness per table
  2. FK: orders → customers
  3. FK: order_items → orders
  4. FK: order_items → products
  5. FK: order_items → sellers
  6. FK: order_payments → orders
  7. FK: order_reviews → orders
  8. Cardinality summary (1:1 vs 1:N)
  9. customer_id vs customer_unique_id behavior
===============================================================================
*/

-- ============================================================================
-- 1. PRIMARY KEY UNIQUENESS
--    Each PK column should have zero duplicates
-- ============================================================================

SELECT 'customers'    AS table_name,
       COUNT(*)        AS total_rows,
       COUNT(DISTINCT customer_id) AS distinct_pks,
       COUNT(*) - COUNT(DISTINCT customer_id) AS duplicates
FROM olist_customers_dataset

UNION ALL

SELECT 'orders',
       COUNT(*),
       COUNT(DISTINCT order_id),
       COUNT(*) - COUNT(DISTINCT order_id)
FROM olist_orders_dataset

UNION ALL

SELECT 'products',
       COUNT(*),
       COUNT(DISTINCT product_id),
       COUNT(*) - COUNT(DISTINCT product_id)
FROM olist_products_dataset

UNION ALL

SELECT 'sellers',
       COUNT(*),
       COUNT(DISTINCT seller_id),
       COUNT(*) - COUNT(DISTINCT seller_id)
FROM olist_sellers_dataset;


-- ============================================================================
-- 2. FK: orders → customers
--    Every order must have a matching customer record
-- ============================================================================

-- Orders with no matching customer (should be 0)
SELECT COUNT(*) AS orphan_orders
FROM olist_orders_dataset         AS o
LEFT JOIN olist_customers_dataset  AS c ON o.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

-- Cardinality: how many orders per customer?
SELECT
    orders_per_customer,
    COUNT(*)           AS customer_count
FROM (
    SELECT customer_id, COUNT(order_id) AS orders_per_customer
    FROM olist_orders_dataset
    GROUP BY customer_id
) AS sub
GROUP BY orders_per_customer
ORDER BY orders_per_customer;


-- ============================================================================
-- 3. FK: order_items → orders
--    Every order item must reference a valid order
-- ============================================================================

-- Orphan order items (should be 0)
SELECT COUNT(*) AS orphan_order_items
FROM olist_order_items_dataset    AS oi
LEFT JOIN olist_orders_dataset     AS o ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Cardinality: items per order
SELECT
    COUNT(*)                                          AS total_items,
    COUNT(DISTINCT order_id)                          AS unique_orders,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT order_id), 2) AS avg_items_per_order
FROM olist_order_items_dataset;


-- ============================================================================
-- 4. FK: order_items → products
--    Every order item must reference a valid product
-- ============================================================================

-- Orphan items with no product (should be 0)
SELECT COUNT(*) AS order_items_without_product
FROM olist_order_items_dataset  AS oi
LEFT JOIN olist_products_dataset AS p ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;


-- ============================================================================
-- 5. FK: order_items → sellers
--    Every order item must reference a valid seller
-- ============================================================================

-- Orphan items with no seller (should be 0)
SELECT COUNT(*) AS order_items_without_seller
FROM olist_order_items_dataset AS oi
LEFT JOIN olist_sellers_dataset AS s ON oi.seller_id = s.seller_id
WHERE s.seller_id IS NULL;


-- ============================================================================
-- 6. FK: order_payments → orders
--    Every payment must reference a valid order
-- ============================================================================

-- Orphan payments (should be 0)
SELECT COUNT(*) AS orphan_payments
FROM olist_order_payments_dataset AS p
LEFT JOIN olist_orders_dataset     AS o ON p.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Orders without any payment record
SELECT COUNT(*) AS orders_without_payment
FROM olist_orders_dataset          AS o
LEFT JOIN olist_order_payments_dataset AS p ON o.order_id = p.order_id
WHERE p.order_id IS NULL;

-- Cardinality: payments per order (some orders use multiple payment methods)
SELECT
    payments_per_order,
    COUNT(*) AS order_count
FROM (
    SELECT order_id, COUNT(*) AS payments_per_order
    FROM olist_order_payments_dataset
    GROUP BY order_id
) AS sub
GROUP BY payments_per_order
ORDER BY payments_per_order;


-- ============================================================================
-- 7. FK: order_reviews → orders
--    Every review must reference a valid order
-- ============================================================================

-- Orphan reviews (should be 0)
SELECT COUNT(*) AS orphan_reviews
FROM olist_order_reviews_dataset AS r
LEFT JOIN olist_orders_dataset    AS o ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Orders without a review
SELECT COUNT(*) AS orders_without_review
FROM olist_orders_dataset         AS o
LEFT JOIN olist_order_reviews_dataset AS r ON o.order_id = r.order_id
WHERE r.order_id IS NULL;


-- ============================================================================
-- 8. CARDINALITY SUMMARY
--    High-level overview of all relationship cardinalities
-- ============================================================================

SELECT
    'customers → orders'        AS relationship,
    COUNT(DISTINCT c.customer_id)       AS left_count,
    COUNT(DISTINCT o.order_id)          AS right_count,
    'one-to-one (by customer_id)'       AS cardinality_note
FROM olist_customers_dataset  AS c
LEFT JOIN olist_orders_dataset AS o ON c.customer_id = o.customer_id

UNION ALL

SELECT
    'orders → order_items',
    COUNT(DISTINCT o.order_id),
    COUNT(oi.order_item_id),
    'one-to-many'
FROM olist_orders_dataset           AS o
LEFT JOIN olist_order_items_dataset  AS oi ON o.order_id = oi.order_id

UNION ALL

SELECT
    'orders → order_payments',
    COUNT(DISTINCT o.order_id),
    COUNT(p.payment_sequential),
    'one-to-many (multiple payment methods)'
FROM olist_orders_dataset              AS o
LEFT JOIN olist_order_payments_dataset  AS p ON o.order_id = p.order_id

UNION ALL

SELECT
    'orders → order_reviews',
    COUNT(DISTINCT o.order_id),
    COUNT(DISTINCT r.review_id),
    'one-to-one (one review per order)'
FROM olist_orders_dataset               AS o
LEFT JOIN olist_order_reviews_dataset    AS r ON o.order_id = r.order_id;


-- ============================================================================
-- 9. customer_id vs customer_unique_id
--    The same physical customer can appear with multiple customer_id values.
--    customer_unique_id is stable across orders — use it for retention analysis.
-- ============================================================================

SELECT
    COUNT(DISTINCT customer_id)         AS total_customer_ids,
    COUNT(DISTINCT customer_unique_id)  AS total_unique_customers,
    COUNT(DISTINCT customer_id)
        - COUNT(DISTINCT customer_unique_id) AS id_inflation
FROM olist_customers_dataset;

-- Customers with more than one customer_id (returning buyers)
SELECT
    customer_unique_id,
    COUNT(customer_id) AS customer_id_count
FROM olist_customers_dataset
GROUP BY customer_unique_id
HAVING COUNT(customer_id) > 1
ORDER BY customer_id_count DESC
LIMIT 10;
