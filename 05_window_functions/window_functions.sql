/*
===============================================================================
  Window Functions
  Brazilian E-Commerce Public Dataset by Olist
===============================================================================

  Covers:
  - ROW_NUMBER()    — unique sequential row numbering per partition
  - RANK()          — ranking with gaps for ties
  - DENSE_RANK()    — ranking without gaps for ties
  - NTILE()         — dividing rows into equal-sized buckets
  - PERCENT_RANK()  — relative rank as a percentage
  - LAG() / LEAD()  — accessing previous or next row values
  - SUM() OVER()    — running total and cumulative sum
  - AVG() OVER()    — moving average
  - FIRST_VALUE() / LAST_VALUE() — first/last value in a window frame
===============================================================================
*/

-- ============================================================================
-- 1. ROW_NUMBER — Rank Each Customer's Orders Chronologically
--    Useful for identifying first-time buyers vs repeat customers
-- ============================================================================

SELECT
    customer_id,
    order_id,
    order_purchase_timestamp,
    ROW_NUMBER() OVER (
        PARTITION BY customer_id
        ORDER BY order_purchase_timestamp
    ) AS order_sequence
FROM olist_orders_dataset
ORDER BY customer_id, order_sequence
LIMIT 30;


-- ============================================================================
-- 2. RANK vs DENSE_RANK — Seller Revenue Ranking
--    RANK skips positions after ties; DENSE_RANK does not
-- ============================================================================

WITH seller_revenue AS (
    SELECT
        seller_id,
        ROUND(SUM(price), 2) AS total_revenue
    FROM olist_order_items_dataset
    GROUP BY seller_id
)
SELECT
    seller_id,
    total_revenue,
    RANK()       OVER (ORDER BY total_revenue DESC) AS rank_with_gap,
    DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS rank_no_gap
FROM seller_revenue
ORDER BY total_revenue DESC
LIMIT 20;


-- ============================================================================
-- 3. LAG — Month-over-Month Revenue Change
--    Compare each month's revenue with the previous month
-- ============================================================================

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
        ROUND(SUM(oi.price), 2)                         AS revenue
    FROM olist_orders_dataset         AS o
    INNER JOIN olist_order_items_dataset AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY order_month
)
SELECT
    order_month,
    revenue,
    LAG(revenue, 1) OVER (ORDER BY order_month)    AS prev_month,
    ROUND(
        revenue - LAG(revenue, 1) OVER (ORDER BY order_month)
    , 2)                                           AS absolute_change,
    ROUND(
        (revenue - LAG(revenue, 1) OVER (ORDER BY order_month))
        / NULLIF(LAG(revenue, 1) OVER (ORDER BY order_month), 0) * 100
    , 2)                                           AS pct_change
FROM monthly_revenue
ORDER BY order_month;


-- ============================================================================
-- 4. LEAD — Days Until Next Order per Customer
--    Gap analysis between consecutive purchases
-- ============================================================================

SELECT
    customer_id,
    order_id,
    order_purchase_timestamp,
    LEAD(order_purchase_timestamp) OVER (
        PARTITION BY customer_id
        ORDER BY order_purchase_timestamp
    )                                              AS next_order_timestamp,
    DATEDIFF('day',
        order_purchase_timestamp,
        LEAD(order_purchase_timestamp) OVER (
            PARTITION BY customer_id
            ORDER BY order_purchase_timestamp
        )
    )                                              AS days_to_next_order
FROM olist_orders_dataset
ORDER BY customer_id, order_purchase_timestamp
LIMIT 30;


-- ============================================================================
-- 5. RUNNING TOTAL — Cumulative Revenue Over Time
--    How revenue accumulates month by month
-- ============================================================================

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
        ROUND(SUM(oi.price), 2)                         AS monthly_revenue
    FROM olist_orders_dataset         AS o
    INNER JOIN olist_order_items_dataset AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY order_month
)
SELECT
    order_month,
    monthly_revenue,
    ROUND(SUM(monthly_revenue) OVER (
        ORDER BY order_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ), 2)                            AS cumulative_revenue
FROM monthly_revenue
ORDER BY order_month;


-- ============================================================================
-- 6. MOVING AVERAGE — 3-Month Rolling Average of Daily Orders
--    Smooth out noise to see the underlying trend
-- ============================================================================

WITH daily_orders AS (
    SELECT
        DATE_TRUNC('day', order_purchase_timestamp) AS order_day,
        COUNT(*)                                     AS daily_count
    FROM olist_orders_dataset
    WHERE order_status = 'delivered'
    GROUP BY order_day
)
SELECT
    order_day,
    daily_count,
    ROUND(AVG(daily_count) OVER (
        ORDER BY order_day
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 1)                              AS rolling_3day_avg
FROM daily_orders
ORDER BY order_day;


-- ============================================================================
-- 7. NTILE — Customer Value Quartiles
--    Divide customers into 4 equal groups by total spend
-- ============================================================================

WITH customer_spend AS (
    SELECT
        c.customer_id,
        c.customer_state,
        ROUND(SUM(oi.price), 2) AS total_spent
    FROM olist_customers_dataset         AS c
    INNER JOIN olist_orders_dataset      AS o  ON c.customer_id = o.customer_id
    INNER JOIN olist_order_items_dataset AS oi ON o.order_id    = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_id, c.customer_state
)
SELECT
    customer_id,
    customer_state,
    total_spent,
    NTILE(4) OVER (ORDER BY total_spent DESC) AS spend_quartile,
    CASE NTILE(4) OVER (ORDER BY total_spent DESC)
        WHEN 1 THEN 'Top 25%'
        WHEN 2 THEN '25–50%'
        WHEN 3 THEN '50–75%'
        WHEN 4 THEN 'Bottom 25%'
    END                                        AS spend_tier
FROM customer_spend
ORDER BY total_spent DESC
LIMIT 30;


-- ============================================================================
-- 8. PERCENT_RANK — Seller Percentile by Revenue
--    Where does each seller stand relative to all sellers?
-- ============================================================================

WITH seller_revenue AS (
    SELECT
        seller_id,
        ROUND(SUM(price), 2) AS total_revenue
    FROM olist_order_items_dataset
    GROUP BY seller_id
)
SELECT
    seller_id,
    total_revenue,
    ROUND(PERCENT_RANK() OVER (ORDER BY total_revenue) * 100, 1) AS revenue_percentile
FROM seller_revenue
ORDER BY total_revenue DESC
LIMIT 20;


-- ============================================================================
-- 9. FIRST_VALUE / LAST_VALUE — First and Last Order Date per Customer
-- ============================================================================

SELECT DISTINCT
    customer_id,
    FIRST_VALUE(order_purchase_timestamp) OVER (
        PARTITION BY customer_id
        ORDER BY order_purchase_timestamp
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS first_order_date,
    LAST_VALUE(order_purchase_timestamp) OVER (
        PARTITION BY customer_id
        ORDER BY order_purchase_timestamp
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_order_date
FROM olist_orders_dataset
ORDER BY customer_id
LIMIT 20;


-- ============================================================================
-- 10. QUALIFY — Filter on Window Function Result (DuckDB feature)
--     Get only the most recent order per customer (no outer CTE needed)
-- ============================================================================

SELECT
    customer_id,
    order_id,
    order_purchase_timestamp,
    order_status
FROM olist_orders_dataset
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY customer_id
    ORDER BY order_purchase_timestamp DESC
) = 1
ORDER BY order_purchase_timestamp DESC
LIMIT 20;
