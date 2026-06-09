/*
===============================================================================
  Aggregations
  Brazilian E-Commerce Public Dataset by Olist
===============================================================================

  Covers:
  - COUNT, SUM, AVG, MIN, MAX
  - GROUP BY with single and multiple columns
  - HAVING — filtering on aggregated values
  - COUNT DISTINCT — unique value counts
  - Conditional aggregation with CASE WHEN
  - ROLLUP — subtotals and grand totals
  - Percentages and ratios derived from aggregations
===============================================================================
*/

-- ============================================================================
-- 1. ORDER VOLUME BY STATUS
--    How many orders are in each status?
-- ============================================================================

SELECT
    order_status,
    COUNT(*)                                   AS total_orders,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM olist_orders_dataset
GROUP BY order_status
ORDER BY total_orders DESC;


-- ============================================================================
-- 2. REVENUE BY STATE
--    Which states generate the most revenue?
-- ============================================================================

SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id)             AS total_orders,
    ROUND(SUM(oi.price), 2)               AS total_revenue,
    ROUND(AVG(oi.price), 2)               AS avg_item_price,
    ROUND(SUM(oi.price) / COUNT(DISTINCT o.order_id), 2) AS avg_order_value
FROM olist_customers_dataset            AS c
INNER JOIN olist_orders_dataset         AS o  ON c.customer_id = o.customer_id
INNER JOIN olist_order_items_dataset    AS oi ON o.order_id    = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;


-- ============================================================================
-- 3. MONTHLY ORDER VOLUME
--    How many orders were placed each month?
-- ============================================================================

SELECT
    DATE_TRUNC('month', order_purchase_timestamp) AS order_month,
    COUNT(*)                                       AS total_orders
FROM olist_orders_dataset
WHERE order_status = 'delivered'
GROUP BY order_month
ORDER BY order_month;


-- ============================================================================
-- 4. TOP 10 PRODUCT CATEGORIES BY REVENUE
--    Which categories drive the most revenue?
-- ============================================================================

SELECT
    COALESCE(t.product_category_name_english, p.product_category_name) AS category,
    COUNT(DISTINCT oi.order_id)     AS total_orders,
    COUNT(oi.order_item_id)         AS total_items_sold,
    ROUND(SUM(oi.price), 2)         AS total_revenue,
    ROUND(AVG(oi.price), 2)         AS avg_item_price
FROM olist_order_items_dataset          AS oi
INNER JOIN olist_products_dataset       AS p  ON oi.product_id          = p.product_id
LEFT  JOIN product_category_name_translation AS t ON p.product_category_name = t.product_category_name
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 10;


-- ============================================================================
-- 5. AVERAGE ORDER VALUE BY PAYMENT TYPE
--    How does payment method affect order size?
-- ============================================================================

SELECT
    payment_type,
    COUNT(DISTINCT order_id)           AS total_orders,
    ROUND(AVG(payment_value), 2)       AS avg_payment_value,
    ROUND(SUM(payment_value), 2)       AS total_payment_value,
    ROUND(MAX(payment_value), 2)       AS max_payment_value
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY total_orders DESC;


-- ============================================================================
-- 6. SELLERS WITH HIGH ORDER VOLUME
--    Sellers with more than 100 orders (HAVING filter)
-- ============================================================================

SELECT
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(DISTINCT oi.order_id)    AS total_orders,
    ROUND(SUM(oi.price), 2)        AS total_revenue
FROM olist_sellers_dataset            AS s
INNER JOIN olist_order_items_dataset   AS oi ON s.seller_id = oi.seller_id
GROUP BY s.seller_id, s.seller_city, s.seller_state
HAVING COUNT(DISTINCT oi.order_id) > 100
ORDER BY total_orders DESC;


-- ============================================================================
-- 7. REVIEW SCORE DISTRIBUTION
--    How are customer ratings distributed?
-- ============================================================================

SELECT
    review_score,
    COUNT(*)                                     AS total_reviews,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS pct_of_total
FROM olist_order_reviews_dataset
GROUP BY review_score
ORDER BY review_score;


-- ============================================================================
-- 8. CONDITIONAL AGGREGATION
--    Count of orders by status for each customer state (pivot-style)
-- ============================================================================

SELECT
    c.customer_state,
    COUNT(*)                                                     AS total_orders,
    COUNT(*) FILTER (WHERE o.order_status = 'delivered')         AS delivered,
    COUNT(*) FILTER (WHERE o.order_status = 'canceled')          AS canceled,
    COUNT(*) FILTER (WHERE o.order_status = 'shipped')           AS shipped,
    COUNT(*) FILTER (WHERE o.order_status = 'processing')        AS processing
FROM olist_customers_dataset    AS c
INNER JOIN olist_orders_dataset  AS o ON c.customer_id = o.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;


-- ============================================================================
-- 9. REVENUE ROLLUP — State and City Subtotals
--    Subtotals per state, and grand total at the bottom
-- ============================================================================

SELECT
    COALESCE(c.customer_state, 'ALL STATES') AS customer_state,
    COUNT(DISTINCT o.order_id)               AS total_orders,
    ROUND(SUM(oi.price), 2)                  AS total_revenue
FROM olist_customers_dataset            AS c
INNER JOIN olist_orders_dataset         AS o  ON c.customer_id = o.customer_id
INNER JOIN olist_order_items_dataset    AS oi ON o.order_id    = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY ROLLUP(c.customer_state)
ORDER BY total_revenue DESC NULLS LAST;


-- ============================================================================
-- 10. DELIVERY TIME STATISTICS
--     Average, min, and max delivery time in days by state
-- ============================================================================

SELECT
    c.customer_state,
    COUNT(*)                                                   AS delivered_orders,
    ROUND(AVG(
        DATEDIFF('day',
            o.order_purchase_timestamp,
            o.order_delivered_customer_date)
    ), 1)                                                      AS avg_delivery_days,
    MIN(DATEDIFF('day',
        o.order_purchase_timestamp,
        o.order_delivered_customer_date))                      AS min_delivery_days,
    MAX(DATEDIFF('day',
        o.order_purchase_timestamp,
        o.order_delivered_customer_date))                      AS max_delivery_days
FROM olist_orders_dataset        AS o
INNER JOIN olist_customers_dataset AS c ON o.customer_id = c.customer_id
WHERE o.order_status                    = 'delivered'
  AND o.order_delivered_customer_date IS NOT NULL
GROUP BY c.customer_state
ORDER BY avg_delivery_days;
