# 00 — Data Understanding

Before writing any analytical query, it is essential to understand the structure, quality, and relationships of the dataset. This section covers schema exploration, NULL analysis, value distributions, and referential integrity validation.

---

## Dataset

**Brazilian E-Commerce Public Dataset by Olist**
100,000+ orders placed between 2016 and 2018 across Brazil.

| Table                              | Rows    | Description                          |
|------------------------------------|---------|--------------------------------------|
| `olist_customers_dataset`          | 99,441  | Customer records with city and state |
| `olist_orders_dataset`             | 99,441  | Orders with status and timestamps    |
| `olist_order_items_dataset`        | 112,650 | Products sold within each order      |
| `olist_products_dataset`           | 32,951  | Product catalog with categories      |
| `olist_sellers_dataset`            | 3,095   | Marketplace seller information       |
| `olist_order_payments_dataset`     | 103,886 | Payment method and installments      |
| `olist_order_reviews_dataset`      | 99,224  | Customer satisfaction scores         |
| `product_category_name_translation`| 71      | Portuguese → English category names  |

---

## Schema Relationships

```
olist_customers_dataset
        │ customer_id
        ▼
olist_orders_dataset
        │ order_id
        ├──────────────────────────┬───────────────────────────┐
        ▼                          ▼                           ▼
olist_order_items_dataset  olist_order_payments_dataset  olist_order_reviews_dataset
   │ product_id
   │ seller_id
   ├────────────────────────────────────┐
   ▼                                    ▼
olist_products_dataset          olist_sellers_dataset
        │ product_category_name
        ▼
product_category_name_translation
```

---

## Files

### [data_understanding.sql](data_understanding.sql)
Schema exploration for all 8 tables:
- `DESCRIBE` to inspect column types
- Row counts and NULL checks per column
- Value distributions for key columns (status, payment type, review score, state)
- Date range of the dataset
- Items-per-order distribution

### [relationship_validation.sql](relationship_validation.sql)
Referential integrity and cardinality checks:
- Primary key uniqueness for all tables
- Orphan detection for every FK relationship
- Cardinality summary (1:1 vs 1:N)
- `customer_id` vs `customer_unique_id` — the key distinction for retention analysis

### [data_model.md](data_model.md)
Primary keys, foreign keys, fact table candidate, and target Star Schema layout.

### [business_questions.md](business_questions.md)
The analytical questions answered throughout this project, organized by topic.

---

## Key Finding: `customer_id` vs `customer_unique_id`

Olist assigns a new `customer_id` to each order placed. The stable identifier across orders is `customer_unique_id`. Using `customer_id` for retention analysis would overcount unique customers.

```sql
-- Always use customer_unique_id for retention and LTV analysis
SELECT COUNT(DISTINCT customer_unique_id) AS real_customer_count
FROM olist_customers_dataset;
```

---

## What Comes Next

The understanding built here informs every subsequent module:

- [01 — SELECT and Filtering](../01_select_and_filtering/) — query patterns using the explored columns
- [06 — Business Cases](../06_business_cases/) — KPIs answering the business questions listed here
- [07 — Analytics Engineering](../07_analytics_engineering/) — Star Schema built from the data model documented here
