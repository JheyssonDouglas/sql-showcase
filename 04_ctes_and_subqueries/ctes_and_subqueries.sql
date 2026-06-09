/*
===============================================================================
  CTEs and Subqueries
  Brazilian E-Commerce Public Dataset by Olist
===============================================================================

  Covers:
  - Simple CTE (WITH clause)
  - Multiple chained CTEs
  - Subquery in WHERE (scalar and IN)
  - Subquery in FROM (derived table)
  - Correlated subquery
  - CTE for multi-step analytical logic
  - Recursive CTE pattern
===============================================================================
*/

-- ============================================================================
-- 1. SIMPLE CTE — Customer Order Summary
--    Count orders per customer, then filter to multi-order customers
-- ============================================================================

WITH customer_orders AS (
    SELECT
        customer_id,
        COUNT(order_id)             AS order_count,
        MIN(order_purchase_timestamp) AS first_order,
        MAX(order_purchase_timestamp) AS last_order
    FROM olist_orders_dataset
    GROUP BY customer_id
)
SELECT
    customer_id,
    order_count,
    first_order,
    last_order,
    DATEDIFF('day', first_order, last_order) AS days_as_customer
FROM customer_orders
WHERE order_count > 1
ORDER BY order_count DESC;


-- ============================================================================
-- 2. CTE — Monthly Revenue with Growth
--    Compute month-over-month revenue change
-- ============================================================================

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp)  AS order_month,
        ROUND(SUM(oi.price), 2)                          AS revenue
    FROM olist_orders_dataset         AS o
    INNER JOIN olist_order_items_dataset AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY order_month
)
SELECT
    order_month,
    revenue,
    LAG(revenue) OVER (ORDER BY order_month)                  AS prev_month_revenue,
    ROUND(revenue - LAG(revenue) OVER (ORDER BY order_month), 2) AS revenue_change,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY order_month))
        / NULLIF(LAG(revenue) OVER (ORDER BY order_month), 0) * 100
    , 2)                                                       AS pct_change
FROM monthly_revenue
ORDER BY order_month;


-- ============================================================================
-- 3. MULTIPLE CTEs — Top Sellers in Top Categories
--    Step 1: find top 5 categories by revenue
--    Step 2: find top sellers in those categories
-- ============================================================================

WITH top_categories AS (
    SELECT
        COALESCE(t.product_category_name_english, p.product_category_name) AS category,
        ROUND(SUM(oi.price), 2) AS category_revenue
    FROM olist_order_items_dataset          AS oi
    INNER JOIN olist_products_dataset       AS p  ON oi.product_id           = p.product_id
    LEFT  JOIN product_category_name_translation AS t ON p.product_category_name = t.product_category_name
    GROUP BY category
    ORDER BY category_revenue DESC
    LIMIT 5
),
seller_category_revenue AS (
    SELECT
        s.seller_id,
        s.seller_state,
        COALESCE(t.product_category_name_english, p.product_category_name) AS category,
        ROUND(SUM(oi.price), 2)     AS seller_revenue,
        COUNT(DISTINCT oi.order_id) AS order_count
    FROM olist_order_items_dataset          AS oi
    INNER JOIN olist_sellers_dataset        AS s  ON oi.seller_id            = s.seller_id
    INNER JOIN olist_products_dataset       AS p  ON oi.product_id           = p.product_id
    LEFT  JOIN product_category_name_translation AS t ON p.product_category_name = t.product_category_name
    GROUP BY s.seller_id, s.seller_state, category
)
SELECT
    scr.category,
    scr.seller_id,
    scr.seller_state,
    scr.seller_revenue,
    scr.order_count
FROM seller_category_revenue AS scr
INNER JOIN top_categories     AS tc ON scr.category = tc.category
ORDER BY scr.category, scr.seller_revenue DESC;


-- ============================================================================
-- 4. SUBQUERY IN WHERE — Above-Average Order Value
--    Find orders whose total exceeds the overall average
-- ============================================================================

SELECT
    oi.order_id,
    ROUND(SUM(oi.price + oi.freight_value), 2) AS order_total
FROM olist_order_items_dataset AS oi
GROUP BY oi.order_id
HAVING SUM(oi.price + oi.freight_value) > (
    SELECT AVG(order_total)
    FROM (
        SELECT order_id, SUM(price + freight_value) AS order_total
        FROM olist_order_items_dataset
        GROUP BY order_id
    ) AS sub
)
ORDER BY order_total DESC
LIMIT 20;


-- ============================================================================
-- 5. SUBQUERY IN FROM (DERIVED TABLE) — State Revenue Tier
--    Classify states by revenue percentile
-- ============================================================================

SELECT
    customer_state,
    total_revenue,
    CASE
        WHEN revenue_rank <= 3 THEN 'Tier 1 — Top'
        WHEN revenue_rank <= 7 THEN 'Tier 2 — Mid'
        ELSE                        'Tier 3 — Low'
    END AS revenue_tier
FROM (
    SELECT
        c.customer_state,
        ROUND(SUM(oi.price), 2)                             AS total_revenue,
        RANK() OVER (ORDER BY SUM(oi.price) DESC)           AS revenue_rank
    FROM olist_customers_dataset            AS c
    INNER JOIN olist_orders_dataset         AS o  ON c.customer_id = o.customer_id
    INNER JOIN olist_order_items_dataset    AS oi ON o.order_id    = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_state
) AS state_revenue
ORDER BY revenue_rank;


-- ============================================================================
-- 6. CORRELATED SUBQUERY — Last Order Per Customer
--    For each customer, retrieve the most recent order
-- ============================================================================

SELECT
    o.customer_id,
    o.order_id,
    o.order_purchase_timestamp,
    o.order_status
FROM olist_orders_dataset AS o
WHERE o.order_purchase_timestamp = (
    SELECT MAX(o2.order_purchase_timestamp)
    FROM olist_orders_dataset AS o2
    WHERE o2.customer_id = o.customer_id
)
ORDER BY o.order_purchase_timestamp DESC
LIMIT 20;


-- ============================================================================
-- 7. MULTI-STEP CTE CHAIN — Customer Lifetime Value Approximation
--    Step 1: revenue per customer
--    Step 2: segment customers by value
--    Step 3: aggregate stats per segment
-- ============================================================================

WITH customer_revenue AS (
    SELECT
        c.customer_id,
        c.customer_state,
        COUNT(DISTINCT o.order_id)   AS total_orders,
        ROUND(SUM(oi.price), 2)      AS total_spent
    FROM olist_customers_dataset         AS c
    INNER JOIN olist_orders_dataset      AS o  ON c.customer_id = o.customer_id
    INNER JOIN olist_order_items_dataset AS oi ON o.order_id    = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_id, c.customer_state
),
customer_segments AS (
    SELECT
        customer_id,
        customer_state,
        total_orders,
        total_spent,
        NTILE(4) OVER (ORDER BY total_spent) AS spend_quartile
    FROM customer_revenue
)
SELECT
    CASE spend_quartile
        WHEN 4 THEN 'High Value'
        WHEN 3 THEN 'Mid-High Value'
        WHEN 2 THEN 'Mid-Low Value'
        ELSE        'Low Value'
    END                              AS customer_segment,
    COUNT(*)                         AS customer_count,
    ROUND(AVG(total_orders), 2)      AS avg_orders,
    ROUND(AVG(total_spent), 2)       AS avg_total_spent,
    ROUND(SUM(total_spent), 2)       AS segment_revenue
FROM customer_segments
GROUP BY spend_quartile
ORDER BY spend_quartile DESC;
