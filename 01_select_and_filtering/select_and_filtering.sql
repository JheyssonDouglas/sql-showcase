/*
===============================================================================
  SELECT and Filtering
  Brazilian E-Commerce Public Dataset by Olist
===============================================================================

  Covers:
  - Column selection and aliasing
  - Row filtering with WHERE
  - Pattern matching with LIKE / ILIKE
  - Range filtering with BETWEEN
  - List filtering with IN / NOT IN
  - NULL handling with IS NULL / IS NOT NULL
  - Deduplication with DISTINCT
  - Sorting with ORDER BY
  - Pagination with LIMIT / OFFSET
  - Date filtering and casting
===============================================================================
*/

-- ============================================================================
-- 1. COLUMN SELECTION AND ALIASING
--    Selecting specific columns with meaningful aliases
-- ============================================================================

SELECT
    order_id,
    customer_id,
    order_status                                    AS status,
    order_purchase_timestamp                        AS purchased_at,
    order_estimated_delivery_date                   AS estimated_delivery
FROM olist_orders_dataset
LIMIT 10;


-- ============================================================================
-- 2. FILTERING BY STATUS
--    Only delivered orders
-- ============================================================================

SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp
FROM olist_orders_dataset
WHERE order_status = 'delivered'
LIMIT 20;


-- ============================================================================
-- 3. FILTERING BY MULTIPLE CONDITIONS (AND / OR)
--    Orders that are either canceled or unavailable
-- ============================================================================

SELECT
    order_id,
    order_status,
    order_purchase_timestamp
FROM olist_orders_dataset
WHERE order_status = 'canceled'
   OR order_status = 'unavailable'
ORDER BY order_purchase_timestamp DESC
LIMIT 20;


-- ============================================================================
-- 4. IN OPERATOR
--    Equivalent to multiple OR conditions — cleaner syntax
-- ============================================================================

SELECT
    order_id,
    order_status,
    order_purchase_timestamp
FROM olist_orders_dataset
WHERE order_status IN ('canceled', 'unavailable', 'processing')
ORDER BY order_purchase_timestamp DESC;


-- ============================================================================
-- 5. NOT IN OPERATOR
--    Exclude specific statuses
-- ============================================================================

SELECT
    order_id,
    order_status
FROM olist_orders_dataset
WHERE order_status NOT IN ('delivered', 'shipped')
ORDER BY order_status;


-- ============================================================================
-- 6. BETWEEN OPERATOR
--    Products within a price range
-- ============================================================================

SELECT
    product_id,
    product_category_name,
    product_weight_g,
    product_length_cm
FROM olist_products_dataset
WHERE product_weight_g BETWEEN 500 AND 2000
ORDER BY product_weight_g DESC
LIMIT 20;


-- ============================================================================
-- 7. LIKE / ILIKE — PATTERN MATCHING
--    Find product categories containing a keyword
-- ============================================================================

SELECT DISTINCT
    product_category_name
FROM olist_products_dataset
WHERE product_category_name ILIKE '%eletro%'
ORDER BY product_category_name;


-- ============================================================================
-- 8. IS NULL — FINDING MISSING DATA
--    Orders missing an approval timestamp (never processed)
-- ============================================================================

SELECT
    order_id,
    order_status,
    order_purchase_timestamp,
    order_approved_at
FROM olist_orders_dataset
WHERE order_approved_at IS NULL
ORDER BY order_purchase_timestamp DESC
LIMIT 20;


-- ============================================================================
-- 9. IS NOT NULL — EXCLUDING MISSING DATA
--    Only orders that have been delivered (have a delivery timestamp)
-- ============================================================================

SELECT
    order_id,
    order_status,
    order_delivered_customer_date
FROM olist_orders_dataset
WHERE order_delivered_customer_date IS NOT NULL
ORDER BY order_delivered_customer_date DESC
LIMIT 20;


-- ============================================================================
-- 10. DISTINCT
--     How many unique order statuses exist?
-- ============================================================================

SELECT DISTINCT order_status
FROM olist_orders_dataset
ORDER BY order_status;


-- ============================================================================
-- 11. DISTINCT COUNT
--     How many unique customers placed at least one order?
-- ============================================================================

SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM olist_orders_dataset;


-- ============================================================================
-- 12. ORDERING BY MULTIPLE COLUMNS
--     Sellers ordered by state, then city
-- ============================================================================

SELECT
    seller_id,
    seller_city,
    seller_state
FROM olist_sellers_dataset
ORDER BY seller_state ASC, seller_city ASC
LIMIT 30;


-- ============================================================================
-- 13. LIMIT AND OFFSET — PAGINATION
--     Page 3 of results (rows 21–30)
-- ============================================================================

SELECT
    order_id,
    order_status,
    order_purchase_timestamp
FROM olist_orders_dataset
ORDER BY order_purchase_timestamp DESC
LIMIT 10 OFFSET 20;


-- ============================================================================
-- 14. DATE FILTERING
--     Orders placed in Q4 2017
-- ============================================================================

SELECT
    order_id,
    order_status,
    order_purchase_timestamp
FROM olist_orders_dataset
WHERE order_purchase_timestamp >= '2017-10-01'
  AND order_purchase_timestamp  < '2018-01-01'
ORDER BY order_purchase_timestamp
LIMIT 20;


-- ============================================================================
-- 15. COMBINING FILTERS
--     Delivered orders from São Paulo placed in 2018
-- ============================================================================

SELECT
    o.order_id,
    o.order_status,
    o.order_purchase_timestamp,
    c.customer_state
FROM olist_orders_dataset        AS o
JOIN olist_customers_dataset     AS c USING (customer_id)
WHERE o.order_status                = 'delivered'
  AND c.customer_state              = 'SP'
  AND o.order_purchase_timestamp   >= '2018-01-01'
  AND o.order_purchase_timestamp    < '2019-01-01'
ORDER BY o.order_purchase_timestamp DESC
LIMIT 20;
