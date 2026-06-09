/*
===============================================================================
  Business Cases
  Brazilian E-Commerce Public Dataset by Olist
===============================================================================

  Real-world analytical use cases answering business questions that would
  appear in a Data Analyst or Analytics Engineer interview.

  Cases:
  1. Revenue Analysis        — monthly trend, YoY growth, top states/categories
  2. Customer Analysis       — acquisition trend, repeat buyers, LTV estimates
  3. Seller Performance      — revenue, order count, review score, delivery speed
  4. Delivery Performance    — on-time rate, delays, worst-performing states
  5. RFM Segmentation        — Recency, Frequency, Monetary customer model
===============================================================================
*/

-- ============================================================================
-- CASE 1: REVENUE ANALYSIS
-- ============================================================================

-- 1a. Monthly revenue and order volume
SELECT
    DATE_TRUNC('month', o.order_purchase_timestamp)        AS month,
    COUNT(DISTINCT o.order_id)                             AS total_orders,
    ROUND(SUM(oi.price), 2)                                AS product_revenue,
    ROUND(SUM(oi.freight_value), 2)                        AS freight_revenue,
    ROUND(SUM(oi.price + oi.freight_value), 2)             AS total_revenue
FROM olist_orders_dataset         AS o
INNER JOIN olist_order_items_dataset AS oi ON o.order_id = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY month
ORDER BY month;


-- 1b. Year-over-Year revenue growth
WITH yearly_revenue AS (
    SELECT
        EXTRACT(YEAR FROM o.order_purchase_timestamp) AS order_year,
        ROUND(SUM(oi.price), 2)                        AS revenue
    FROM olist_orders_dataset         AS o
    INNER JOIN olist_order_items_dataset AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY order_year
)
SELECT
    order_year,
    revenue,
    LAG(revenue) OVER (ORDER BY order_year)             AS prev_year_revenue,
    ROUND(
        (revenue - LAG(revenue) OVER (ORDER BY order_year))
        / NULLIF(LAG(revenue) OVER (ORDER BY order_year), 0) * 100
    , 2)                                                AS yoy_growth_pct
FROM yearly_revenue
ORDER BY order_year;


-- 1c. Top 10 states by revenue with market share
WITH state_revenue AS (
    SELECT
        c.customer_state,
        ROUND(SUM(oi.price), 2) AS revenue
    FROM olist_customers_dataset         AS c
    INNER JOIN olist_orders_dataset      AS o  ON c.customer_id = o.customer_id
    INNER JOIN olist_order_items_dataset AS oi ON o.order_id    = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_state
)
SELECT
    customer_state,
    revenue,
    ROUND(revenue / SUM(revenue) OVER () * 100, 2) AS market_share_pct,
    RANK() OVER (ORDER BY revenue DESC)             AS revenue_rank
FROM state_revenue
ORDER BY revenue_rank
LIMIT 10;


-- ============================================================================
-- CASE 2: CUSTOMER ANALYSIS
-- ============================================================================

-- 2a. Monthly new customer acquisition
SELECT
    DATE_TRUNC('month', first_order) AS cohort_month,
    COUNT(*)                          AS new_customers
FROM (
    SELECT
        customer_id,
        MIN(order_purchase_timestamp) AS first_order
    FROM olist_orders_dataset
    GROUP BY customer_id
) AS first_orders
GROUP BY cohort_month
ORDER BY cohort_month;


-- 2b. Repeat customer rate
WITH customer_order_count AS (
    SELECT
        customer_id,
        COUNT(order_id) AS order_count
    FROM olist_orders_dataset
    GROUP BY customer_id
)
SELECT
    COUNT(*)                                                          AS total_customers,
    COUNT(*) FILTER (WHERE order_count > 1)                          AS repeat_customers,
    ROUND(COUNT(*) FILTER (WHERE order_count > 1) * 100.0
          / COUNT(*), 2)                                             AS repeat_rate_pct,
    ROUND(AVG(order_count), 2)                                       AS avg_orders_per_customer
FROM customer_order_count;


-- 2c. Customer Lifetime Value (LTV) — top 20 customers by revenue
SELECT
    c.customer_id,
    c.customer_city,
    c.customer_state,
    COUNT(DISTINCT o.order_id)    AS total_orders,
    ROUND(SUM(oi.price), 2)       AS lifetime_revenue,
    ROUND(AVG(oi.price), 2)       AS avg_item_value,
    MIN(o.order_purchase_timestamp) AS first_purchase,
    MAX(o.order_purchase_timestamp) AS last_purchase,
    DATEDIFF('day',
        MIN(o.order_purchase_timestamp),
        MAX(o.order_purchase_timestamp))  AS customer_lifespan_days
FROM olist_customers_dataset         AS c
INNER JOIN olist_orders_dataset      AS o  ON c.customer_id = o.customer_id
INNER JOIN olist_order_items_dataset AS oi ON o.order_id    = oi.order_id
WHERE o.order_status = 'delivered'
GROUP BY c.customer_id, c.customer_city, c.customer_state
ORDER BY lifetime_revenue DESC
LIMIT 20;


-- ============================================================================
-- CASE 3: SELLER PERFORMANCE SCORECARD
-- ============================================================================

WITH seller_metrics AS (
    SELECT
        s.seller_id,
        s.seller_city,
        s.seller_state,
        COUNT(DISTINCT oi.order_id)                                   AS total_orders,
        ROUND(SUM(oi.price), 2)                                       AS total_revenue,
        ROUND(AVG(oi.price), 2)                                       AS avg_item_price,
        ROUND(AVG(r.review_score), 2)                                 AS avg_review_score,
        ROUND(AVG(
            DATEDIFF('day',
                o.order_purchase_timestamp,
                o.order_delivered_customer_date)
        ), 1)                                                         AS avg_delivery_days,
        COUNT(*) FILTER (WHERE o.order_delivered_customer_date
                              <= o.order_estimated_delivery_date
                          AND o.order_delivered_customer_date IS NOT NULL
        )                                                             AS on_time_deliveries,
        COUNT(*) FILTER (WHERE o.order_delivered_customer_date
                              IS NOT NULL)                            AS total_delivered
    FROM olist_sellers_dataset              AS s
    INNER JOIN olist_order_items_dataset    AS oi ON s.seller_id  = oi.seller_id
    INNER JOIN olist_orders_dataset         AS o  ON oi.order_id  = o.order_id
    LEFT  JOIN olist_order_reviews_dataset  AS r  ON o.order_id   = r.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY s.seller_id, s.seller_city, s.seller_state
    HAVING COUNT(DISTINCT oi.order_id) >= 10
)
SELECT
    seller_id,
    seller_city,
    seller_state,
    total_orders,
    total_revenue,
    avg_item_price,
    avg_review_score,
    avg_delivery_days,
    ROUND(on_time_deliveries * 100.0 / NULLIF(total_delivered, 0), 1) AS on_time_pct
FROM seller_metrics
ORDER BY total_revenue DESC
LIMIT 20;


-- ============================================================================
-- CASE 4: DELIVERY PERFORMANCE
-- ============================================================================

-- 4a. On-time delivery rate by state
SELECT
    c.customer_state,
    COUNT(*) FILTER (WHERE o.order_status = 'delivered')    AS delivered_orders,
    COUNT(*) FILTER (
        WHERE o.order_delivered_customer_date <= o.order_estimated_delivery_date
          AND o.order_status = 'delivered'
    )                                                        AS on_time,
    ROUND(
        COUNT(*) FILTER (
            WHERE o.order_delivered_customer_date <= o.order_estimated_delivery_date
              AND o.order_status = 'delivered'
        ) * 100.0
        / NULLIF(COUNT(*) FILTER (WHERE o.order_status = 'delivered'), 0)
    , 1)                                                     AS on_time_rate_pct,
    ROUND(AVG(
        CASE WHEN o.order_status = 'delivered'
            THEN DATEDIFF('day',
                o.order_purchase_timestamp,
                o.order_delivered_customer_date)
        END
    ), 1)                                                    AS avg_delivery_days
FROM olist_orders_dataset        AS o
INNER JOIN olist_customers_dataset AS c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
HAVING COUNT(*) FILTER (WHERE o.order_status = 'delivered') > 100
ORDER BY on_time_rate_pct DESC;


-- 4b. Late orders — how many days late on average?
SELECT
    c.customer_state,
    COUNT(*)                              AS late_orders,
    ROUND(AVG(
        DATEDIFF('day',
            o.order_estimated_delivery_date,
            o.order_delivered_customer_date)
    ), 1)                                 AS avg_days_late,
    MAX(
        DATEDIFF('day',
            o.order_estimated_delivery_date,
            o.order_delivered_customer_date)
    )                                     AS max_days_late
FROM olist_orders_dataset          AS o
INNER JOIN olist_customers_dataset  AS c ON o.customer_id = c.customer_id
WHERE o.order_status                    = 'delivered'
  AND o.order_delivered_customer_date   > o.order_estimated_delivery_date
GROUP BY c.customer_state
ORDER BY avg_days_late DESC;


-- ============================================================================
-- CASE 5: RFM SEGMENTATION
--    Recency  — how recently did the customer buy?
--    Frequency — how often do they buy?
--    Monetary  — how much do they spend?
-- ============================================================================

WITH rfm_base AS (
    SELECT
        c.customer_id,
        DATEDIFF('day',
            MAX(o.order_purchase_timestamp),
            (SELECT MAX(order_purchase_timestamp) FROM olist_orders_dataset)
        )                                        AS recency_days,
        COUNT(DISTINCT o.order_id)               AS frequency,
        ROUND(SUM(oi.price), 2)                  AS monetary
    FROM olist_customers_dataset         AS c
    INNER JOIN olist_orders_dataset      AS o  ON c.customer_id = o.customer_id
    INNER JOIN olist_order_items_dataset AS oi ON o.order_id    = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_id
),
rfm_scores AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency_days ASC)   AS r_score,  -- lower recency = better
        NTILE(5) OVER (ORDER BY frequency DESC)      AS f_score,
        NTILE(5) OVER (ORDER BY monetary DESC)       AS m_score
    FROM rfm_base
),
rfm_segments AS (
    SELECT
        customer_id,
        recency_days,
        frequency,
        monetary,
        r_score,
        f_score,
        m_score,
        (r_score + f_score + m_score)   AS rfm_total,
        CASE
            WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
            WHEN r_score >= 3 AND f_score >= 3                   THEN 'Loyal Customers'
            WHEN r_score >= 4 AND f_score <= 2                   THEN 'Promising'
            WHEN r_score >= 3 AND f_score <= 2                   THEN 'Potential Loyalists'
            WHEN r_score <= 2 AND f_score >= 4                   THEN 'At Risk'
            WHEN r_score <= 2 AND f_score >= 2                   THEN 'Need Attention'
            ELSE                                                       'Lost'
        END                             AS segment
    FROM rfm_scores
)
SELECT
    segment,
    COUNT(*)                         AS customer_count,
    ROUND(AVG(recency_days), 1)      AS avg_recency_days,
    ROUND(AVG(frequency), 2)         AS avg_frequency,
    ROUND(AVG(monetary), 2)          AS avg_monetary,
    ROUND(SUM(monetary), 2)          AS segment_revenue
FROM rfm_segments
GROUP BY segment
ORDER BY segment_revenue DESC;
