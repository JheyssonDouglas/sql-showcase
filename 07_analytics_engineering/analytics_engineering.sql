/*
===============================================================================
  Analytics Engineering
  Brazilian E-Commerce Public Dataset by Olist
===============================================================================

  Demonstrates dimensional modeling principles applied in SQL:
  - Building a Star Schema from raw operational tables
  - Dimension tables: dim_customer, dim_product, dim_seller, dim_date
  - Fact table: fact_sales
  - Reporting layer: aggregate views on top of the star schema

  Pattern used: CREATE TABLE AS SELECT (CTAS)
  This is the same pattern used in dbt, BigQuery, Redshift, and Snowflake.

  Star Schema:
                    dim_date
                       |
  dim_customer ── fact_sales ── dim_seller
                       |
                   dim_product
===============================================================================
*/

-- ============================================================================
-- DIMENSION: dim_customer
--    One row per unique customer_unique_id
--    Olist's customer_id changes per order; customer_unique_id is stable
-- ============================================================================

CREATE OR REPLACE TABLE dim_customer AS
SELECT
    customer_unique_id                          AS customer_key,
    MIN(customer_id)                            AS customer_id,
    customer_city,
    customer_state,
    COUNT(customer_id)                          AS order_profile_count
FROM olist_customers_dataset
GROUP BY customer_unique_id, customer_city, customer_state;

SELECT * FROM dim_customer LIMIT 5;


-- ============================================================================
-- DIMENSION: dim_product
--    One row per product with translated category name
-- ============================================================================

CREATE OR REPLACE TABLE dim_product AS
SELECT
    p.product_id                                                      AS product_key,
    COALESCE(t.product_category_name_english, p.product_category_name,
             'uncategorized')                                         AS category_en,
    p.product_category_name                                           AS category_pt,
    p.product_name_lenght                                             AS name_length,
    p.product_description_lenght                                      AS description_length,
    p.product_photos_qty                                              AS photos_qty,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm,
    ROUND(
        p.product_weight_g / 1000.0
    , 3)                                                              AS weight_kg
FROM olist_products_dataset                     AS p
LEFT JOIN product_category_name_translation      AS t
    ON p.product_category_name = t.product_category_name;

SELECT * FROM dim_product LIMIT 5;


-- ============================================================================
-- DIMENSION: dim_seller
--    One row per seller
-- ============================================================================

CREATE OR REPLACE TABLE dim_seller AS
SELECT
    seller_id                  AS seller_key,
    seller_city,
    seller_state,
    seller_zip_code_prefix     AS zip_prefix
FROM olist_sellers_dataset;

SELECT * FROM dim_seller LIMIT 5;


-- ============================================================================
-- DIMENSION: dim_date
--    Date spine generated from the full range of order dates
--    Enables time-intelligence queries (YoY, MoM, same-day-last-year)
-- ============================================================================

CREATE OR REPLACE TABLE dim_date AS
WITH date_spine AS (
    SELECT UNNEST(
        generate_series(
            (SELECT MIN(order_purchase_timestamp::DATE) FROM olist_orders_dataset),
            (SELECT MAX(order_purchase_timestamp::DATE) FROM olist_orders_dataset),
            INTERVAL '1 day'
        )
    )::DATE AS date_day
)
SELECT
    date_day                                          AS date_key,
    EXTRACT(YEAR  FROM date_day)::INT                 AS year,
    EXTRACT(MONTH FROM date_day)::INT                 AS month,
    EXTRACT(DAY   FROM date_day)::INT                 AS day,
    EXTRACT(QUARTER FROM date_day)::INT               AS quarter,
    EXTRACT(DOW FROM date_day)::INT                   AS day_of_week,
    CASE EXTRACT(DOW FROM date_day)::INT
        WHEN 0 THEN 'Sunday'
        WHEN 1 THEN 'Monday'
        WHEN 2 THEN 'Tuesday'
        WHEN 3 THEN 'Wednesday'
        WHEN 4 THEN 'Thursday'
        WHEN 5 THEN 'Friday'
        WHEN 6 THEN 'Saturday'
    END                                               AS day_name,
    STRFTIME(date_day, '%B')                          AS month_name,
    DATE_TRUNC('month', date_day)::DATE               AS month_start,
    DATE_TRUNC('year',  date_day)::DATE               AS year_start,
    CASE WHEN EXTRACT(DOW FROM date_day) IN (0, 6)
         THEN FALSE ELSE TRUE
    END                                               AS is_weekday,
    'Q' || EXTRACT(QUARTER FROM date_day)::VARCHAR
        || ' ' || EXTRACT(YEAR FROM date_day)::VARCHAR AS quarter_label
FROM date_spine;

SELECT * FROM dim_date LIMIT 10;


-- ============================================================================
-- FACT TABLE: fact_sales
--    Grain: one row per order item
--    This is the most granular fact table — all aggregations start here
-- ============================================================================

CREATE OR REPLACE TABLE fact_sales AS
SELECT
    -- Surrogate key
    oi.order_id || '-' || oi.order_item_id          AS sales_key,

    -- Foreign keys to dimensions
    oi.order_id,
    c.customer_unique_id                             AS customer_key,
    oi.product_id                                    AS product_key,
    oi.seller_id                                     AS seller_key,
    o.order_purchase_timestamp::DATE                 AS date_key,

    -- Order metadata
    oi.order_item_id,
    o.order_status,
    o.order_purchase_timestamp,
    o.order_approved_at,
    o.order_delivered_carrier_date,
    o.order_delivered_customer_date,
    o.order_estimated_delivery_date,

    -- Measures
    oi.price,
    oi.freight_value,
    oi.price + oi.freight_value                     AS total_value,

    -- Derived delivery flags
    CASE
        WHEN o.order_delivered_customer_date IS NOT NULL
         AND o.order_delivered_customer_date <= o.order_estimated_delivery_date
        THEN TRUE
        ELSE FALSE
    END                                              AS is_on_time,

    CASE
        WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
        THEN DATEDIFF('day',
            o.order_estimated_delivery_date,
            o.order_delivered_customer_date)
        ELSE 0
    END                                              AS days_late,

    DATEDIFF('day',
        o.order_purchase_timestamp,
        o.order_delivered_customer_date)             AS delivery_days

FROM olist_order_items_dataset  AS oi
INNER JOIN olist_orders_dataset  AS o  ON oi.order_id  = o.order_id
INNER JOIN olist_customers_dataset AS c ON o.customer_id = c.customer_id;

SELECT * FROM fact_sales LIMIT 5;


-- ============================================================================
-- REPORTING LAYER — Validate the Star Schema
-- ============================================================================

-- Row count sanity check
SELECT
    'fact_sales'   AS table_name, COUNT(*) AS rows FROM fact_sales
UNION ALL
SELECT 'dim_customer',             COUNT(*) FROM dim_customer
UNION ALL
SELECT 'dim_product',              COUNT(*) FROM dim_product
UNION ALL
SELECT 'dim_seller',               COUNT(*) FROM dim_seller
UNION ALL
SELECT 'dim_date',                 COUNT(*) FROM dim_date;


-- ============================================================================
-- REPORTING LAYER — Monthly Revenue from the Star Schema
--    Demonstrates the clean analytical query the model enables
-- ============================================================================

SELECT
    d.year,
    d.month,
    d.month_name,
    COUNT(DISTINCT f.order_id)         AS total_orders,
    ROUND(SUM(f.price), 2)             AS product_revenue,
    ROUND(SUM(f.freight_value), 2)     AS freight_revenue,
    ROUND(SUM(f.total_value), 2)       AS total_revenue,
    ROUND(AVG(f.delivery_days), 1)     AS avg_delivery_days,
    ROUND(SUM(f.is_on_time::INT) * 100.0 / COUNT(*), 1) AS on_time_pct
FROM fact_sales   AS f
INNER JOIN dim_date AS d ON f.date_key = d.date_key
WHERE f.order_status = 'delivered'
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;


-- ============================================================================
-- REPORTING LAYER — Category Performance from the Star Schema
-- ============================================================================

SELECT
    p.category_en,
    COUNT(DISTINCT f.order_id)    AS total_orders,
    COUNT(f.sales_key)            AS total_items,
    ROUND(SUM(f.price), 2)        AS total_revenue,
    ROUND(AVG(f.price), 2)        AS avg_item_price,
    ROUND(AVG(f.delivery_days), 1) AS avg_delivery_days
FROM fact_sales    AS f
INNER JOIN dim_product AS p ON f.product_key = p.product_key
WHERE f.order_status = 'delivered'
GROUP BY p.category_en
ORDER BY total_revenue DESC
LIMIT 15;
