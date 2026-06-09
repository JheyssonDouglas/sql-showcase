# Data Model

The Olist dataset follows a normalized operational schema. This document maps the entities, keys, and relationships used throughout this project.

---

## Main Business Flow

```
Customer
    │
    └── Order
            │
            ├── Order Item ──── Product
            │         │
            │         └──────── Seller
            │
            ├── Payment
            │
            └── Review
```

---

## Tables and Primary Keys

| Table                           | Primary Key          | Rows    |
|---------------------------------|----------------------|---------|
| `olist_customers_dataset`       | `customer_id`        | 99,441  |
| `olist_orders_dataset`          | `order_id`           | 99,441  |
| `olist_order_items_dataset`     | `order_id + order_item_id` | 112,650 |
| `olist_products_dataset`        | `product_id`         | 32,951  |
| `olist_sellers_dataset`         | `seller_id`          | 3,095   |
| `olist_order_payments_dataset`  | `order_id + payment_sequential` | 103,886 |
| `olist_order_reviews_dataset`   | `review_id`          | 99,224  |
| `product_category_name_translation` | `product_category_name` | 71 |

---

## Foreign Key Relationships

```
olist_orders_dataset.customer_id
    → olist_customers_dataset.customer_id

olist_order_items_dataset.order_id
    → olist_orders_dataset.order_id

olist_order_items_dataset.product_id
    → olist_products_dataset.product_id

olist_order_items_dataset.seller_id
    → olist_sellers_dataset.seller_id

olist_order_payments_dataset.order_id
    → olist_orders_dataset.order_id

olist_order_reviews_dataset.order_id
    → olist_orders_dataset.order_id
```

---

## Important Note: `customer_id` vs `customer_unique_id`

`customer_id` in Olist is **order-scoped** — the same physical customer gets a new `customer_id` for each order. `customer_unique_id` is the stable identifier for a returning customer.

For retention and LTV analysis, always use `customer_unique_id`.

---

## Fact Table Candidate

`olist_order_items_dataset` is the natural fact table because:
- Each row represents a single product sold within an order (most granular level)
- It holds all measures: `price`, `freight_value`
- It connects to all dimension-like entities via foreign keys

**Grain:** one row per product sold per order

### Measures
- `price` — product price
- `freight_value` — shipping cost

### Dimension Keys
- `order_id` → orders → customers, payments, reviews
- `product_id` → products → categories
- `seller_id` → sellers

---

## Target Star Schema (built in Module 07)

```
                   dim_date
                      │
dim_customer ──── fact_sales ──── dim_seller
                      │
                 dim_product
```

| Model          | Source Table(s)                                         |
|----------------|---------------------------------------------------------|
| `fact_sales`   | `order_items` + `orders` + `customers`                  |
| `dim_customer` | `customers` (deduplicated on `customer_unique_id`)       |
| `dim_product`  | `products` + `product_category_name_translation`        |
| `dim_seller`   | `sellers`                                               |
| `dim_date`     | Generated date spine from order date range              |
