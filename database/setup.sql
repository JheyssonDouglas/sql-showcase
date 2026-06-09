/*
===============================================================================
  DuckDB Setup Script — Olist E-Commerce Database
===============================================================================

  Run this script once to create and populate all tables from CSV files.

  Usage:
    duckdb database/olist.duckdb < database/setup.sql

  Requirements:
    - DuckDB CLI installed
    - CSV files present in datasets/ folder
===============================================================================
*/

-- ============================================================================
-- CUSTOMERS
-- ============================================================================

CREATE OR REPLACE TABLE olist_customers_dataset AS
SELECT * FROM read_csv_auto('datasets/olist_customers_dataset.csv');

-- ============================================================================
-- ORDERS
-- ============================================================================

CREATE OR REPLACE TABLE olist_orders_dataset AS
SELECT * FROM read_csv_auto('datasets/olist_orders_dataset.csv');

-- ============================================================================
-- ORDER ITEMS
-- ============================================================================

CREATE OR REPLACE TABLE olist_order_items_dataset AS
SELECT * FROM read_csv_auto('datasets/olist_order_items_dataset.csv');

-- ============================================================================
-- PRODUCTS
-- ============================================================================

CREATE OR REPLACE TABLE olist_products_dataset AS
SELECT * FROM read_csv_auto('datasets/olist_products_dataset.csv');

-- ============================================================================
-- SELLERS
-- ============================================================================

CREATE OR REPLACE TABLE olist_sellers_dataset AS
SELECT * FROM read_csv_auto('datasets/olist_sellers_dataset.csv');

-- ============================================================================
-- ORDER PAYMENTS
-- ============================================================================

CREATE OR REPLACE TABLE olist_order_payments_dataset AS
SELECT * FROM read_csv_auto('datasets/olist_order_payments_dataset.csv');

-- ============================================================================
-- ORDER REVIEWS
-- ============================================================================

CREATE OR REPLACE TABLE olist_order_reviews_dataset AS
SELECT * FROM read_csv_auto('datasets/olist_order_reviews_dataset.csv');

-- ============================================================================
-- PRODUCT CATEGORY TRANSLATION
-- ============================================================================

CREATE OR REPLACE TABLE product_category_name_translation AS
SELECT * FROM read_csv_auto('datasets/product_category_name_translation.csv');

-- ============================================================================
-- VALIDATION
-- ============================================================================

SELECT 'customers'       AS table_name, COUNT(*) AS row_count FROM olist_customers_dataset
UNION ALL
SELECT 'orders',                         COUNT(*) FROM olist_orders_dataset
UNION ALL
SELECT 'order_items',                    COUNT(*) FROM olist_order_items_dataset
UNION ALL
SELECT 'products',                       COUNT(*) FROM olist_products_dataset
UNION ALL
SELECT 'sellers',                        COUNT(*) FROM olist_sellers_dataset
UNION ALL
SELECT 'order_payments',                 COUNT(*) FROM olist_order_payments_dataset
UNION ALL
SELECT 'order_reviews',                  COUNT(*) FROM olist_order_reviews_dataset
UNION ALL
SELECT 'category_translation',           COUNT(*) FROM product_category_name_translation
ORDER BY table_name;
