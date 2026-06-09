/*
===============================================================================
  Query Optimization
  Brazilian E-Commerce Public Dataset by Olist
===============================================================================

  Demonstrates performance-aware SQL writing through before/after comparisons
  and DuckDB's EXPLAIN output analysis.

  Topics:
  1. Avoid SELECT * — only select what you need
  2. Filter early — push WHERE conditions as close to the data as possible
  3. Eliminate repeated subqueries — use CTEs
  4. Avoid functions on indexed columns in WHERE
  5. Use INNER JOIN instead of correlated subqueries
  6. Avoid DISTINCT when GROUP BY is sufficient
  7. Column pruning in CTEs
  8. EXPLAIN — understanding the query execution plan
===============================================================================
*/

-- ============================================================================
-- 1. SELECT * vs COLUMN SELECTION
--    Scanning all 20+ columns vs only the 3 needed
-- ============================================================================

-- BEFORE — reads all columns from disk unnecessarily
SELECT *
FROM olist_orders_dataset
WHERE order_status = 'delivered'
LIMIT 10;

-- AFTER — reads only 3 columns; much less I/O in columnar storage
SELECT
    order_id,
    customer_id,
    order_purchase_timestamp
FROM olist_orders_dataset
WHERE order_status = 'delivered'
LIMIT 10;


-- ============================================================================
-- 2. FILTER EARLY — Push Conditions into CTEs and Subqueries
--    Don't aggregate first and filter later if you can filter first
-- ============================================================================

-- BEFORE — aggregates all 100k orders, then filters
WITH all_customers AS (
    SELECT
        customer_id,
        COUNT(order_id) AS order_count,
        SUM(price)      AS total_spent
    FROM olist_orders_dataset AS o
    INNER JOIN olist_order_items_dataset AS oi ON o.order_id = oi.order_id
    GROUP BY customer_id
)
SELECT * FROM all_customers WHERE order_count > 3;

-- AFTER — filter inside the CTE using HAVING; same result, fewer rows to aggregate
WITH filtered_customers AS (
    SELECT
        o.customer_id,
        COUNT(o.order_id)   AS order_count,
        ROUND(SUM(oi.price), 2) AS total_spent
    FROM olist_orders_dataset AS o
    INNER JOIN olist_order_items_dataset AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.customer_id
    HAVING COUNT(o.order_id) > 3
)
SELECT * FROM filtered_customers ORDER BY total_spent DESC LIMIT 20;


-- ============================================================================
-- 3. AVOID REPEATED SUBQUERIES — Use a CTE Instead
--    Subquery evaluated twice vs computed once with a CTE
-- ============================================================================

-- BEFORE — the revenue subquery is evaluated twice
SELECT
    customer_id,
    total_spent,
    total_spent / (SELECT SUM(price) FROM olist_order_items_dataset) AS revenue_share,
    total_spent - (SELECT AVG(total)
                   FROM (SELECT customer_id, SUM(price) AS total
                         FROM olist_order_items_dataset
                         GROUP BY customer_id) AS sub) AS vs_average
FROM (
    SELECT customer_id, ROUND(SUM(price), 2) AS total_spent
    FROM olist_orders_dataset AS o
    INNER JOIN olist_order_items_dataset AS oi ON o.order_id = oi.order_id
    GROUP BY customer_id
) AS customer_rev
LIMIT 10;

-- AFTER — each value computed exactly once
WITH totals AS (
    SELECT
        SUM(price)  AS grand_total,
        AVG(total)  AS avg_customer_spend
    FROM (
        SELECT customer_id, SUM(price) AS total
        FROM olist_orders_dataset AS o
        INNER JOIN olist_order_items_dataset AS oi ON o.order_id = oi.order_id
        GROUP BY customer_id
    ) AS sub
),
customer_revenue AS (
    SELECT
        o.customer_id,
        ROUND(SUM(oi.price), 2) AS total_spent
    FROM olist_orders_dataset AS o
    INNER JOIN olist_order_items_dataset AS oi ON o.order_id = oi.order_id
    GROUP BY o.customer_id
)
SELECT
    cr.customer_id,
    cr.total_spent,
    ROUND(cr.total_spent / t.grand_total * 100, 4)       AS revenue_share_pct,
    ROUND(cr.total_spent - t.avg_customer_spend, 2)      AS vs_average
FROM customer_revenue AS cr
CROSS JOIN totals      AS t
ORDER BY cr.total_spent DESC
LIMIT 10;


-- ============================================================================
-- 4. AVOID FUNCTIONS ON FILTER COLUMNS
--    Applying a function to a column prevents index/partition pruning
-- ============================================================================

-- BEFORE — EXTRACT() forces a full scan of order_purchase_timestamp
SELECT COUNT(*)
FROM olist_orders_dataset
WHERE EXTRACT(YEAR FROM order_purchase_timestamp) = 2018;

-- AFTER — range filter on the raw timestamp column; index/partition-friendly
SELECT COUNT(*)
FROM olist_orders_dataset
WHERE order_purchase_timestamp >= '2018-01-01'
  AND order_purchase_timestamp  < '2019-01-01';


-- ============================================================================
-- 5. CORRELATED SUBQUERY vs JOIN
--    A correlated subquery executes once per row; a JOIN is set-based
-- ============================================================================

-- BEFORE — correlated subquery (O(n) execution)
SELECT
    order_id,
    customer_id,
    order_purchase_timestamp
FROM olist_orders_dataset AS o
WHERE order_purchase_timestamp = (
    SELECT MAX(o2.order_purchase_timestamp)
    FROM olist_orders_dataset AS o2
    WHERE o2.customer_id = o.customer_id
)
LIMIT 10;

-- AFTER — equivalent result using a single-pass window + QUALIFY
SELECT
    order_id,
    customer_id,
    order_purchase_timestamp
FROM olist_orders_dataset
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY customer_id
    ORDER BY order_purchase_timestamp DESC
) = 1
ORDER BY order_purchase_timestamp DESC
LIMIT 10;


-- ============================================================================
-- 6. UNNECESSARY DISTINCT vs GROUP BY
--    GROUP BY is explicit about what you want; DISTINCT can be ambiguous
-- ============================================================================

-- BEFORE — DISTINCT on multiple columns is implicit GROUP BY
SELECT DISTINCT
    customer_state,
    customer_city
FROM olist_customers_dataset
ORDER BY customer_state, customer_city;

-- AFTER — explicit GROUP BY, same result, and allows adding aggregates later
SELECT
    customer_state,
    customer_city,
    COUNT(*) AS customer_count
FROM olist_customers_dataset
GROUP BY customer_state, customer_city
ORDER BY customer_state, customer_city;


-- ============================================================================
-- 7. PRUNE COLUMNS IN CTEs
--    Only select columns you will use in the outer query
-- ============================================================================

-- BEFORE — CTE selects all columns even though only 2 are used
WITH all_orders AS (
    SELECT * FROM olist_orders_dataset
)
SELECT order_id, order_status FROM all_orders WHERE order_status = 'delivered' LIMIT 10;

-- AFTER — CTE is a thin projection with only what's needed
WITH delivered_orders AS (
    SELECT order_id, order_status
    FROM olist_orders_dataset
    WHERE order_status = 'delivered'
)
SELECT order_id, order_status FROM delivered_orders LIMIT 10;


-- ============================================================================
-- 8. EXPLAIN — Understanding the Execution Plan
--    Use EXPLAIN to see how DuckDB executes a query before running it
-- ============================================================================

EXPLAIN
SELECT
    c.customer_state,
    COUNT(DISTINCT o.order_id)   AS total_orders,
    ROUND(SUM(oi.price), 2)      AS total_revenue
FROM olist_customers_dataset         AS c
INNER JOIN olist_orders_dataset      AS o  ON c.customer_id = o.customer_id
INNER JOIN olist_order_items_dataset AS oi ON o.order_id    = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_state
ORDER BY total_revenue DESC;


-- ============================================================================
-- 9. AGGREGATION REWRITE — Avoid Double Scan
--    Single pass with conditional aggregation vs two separate queries
-- ============================================================================

-- BEFORE — two separate queries to get delivered and canceled counts
SELECT customer_state, COUNT(*) AS delivered_orders
FROM olist_orders_dataset AS o
JOIN olist_customers_dataset AS c ON o.customer_id = c.customer_id
WHERE order_status = 'delivered'
GROUP BY customer_state;

SELECT customer_state, COUNT(*) AS canceled_orders
FROM olist_orders_dataset AS o
JOIN olist_customers_dataset AS c ON o.customer_id = c.customer_id
WHERE order_status = 'canceled'
GROUP BY customer_state;

-- AFTER — single scan with conditional aggregation
SELECT
    c.customer_state,
    COUNT(*) FILTER (WHERE o.order_status = 'delivered')  AS delivered_orders,
    COUNT(*) FILTER (WHERE o.order_status = 'canceled')   AS canceled_orders,
    COUNT(*)                                               AS all_orders
FROM olist_orders_dataset       AS o
INNER JOIN olist_customers_dataset AS c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY all_orders DESC;
