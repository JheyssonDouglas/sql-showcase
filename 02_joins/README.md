# 02 — JOINs

Combining data across multiple tables using different join strategies.

---

## Concepts Covered

| Concept           | Description                                                         |
|-------------------|---------------------------------------------------------------------|
| `INNER JOIN`      | Returns only rows with matches in both tables                       |
| `LEFT JOIN`       | Returns all left rows; NULLs for unmatched right rows               |
| Anti-JOIN         | `LEFT JOIN ... WHERE right.id IS NULL` — find unmatched rows        |
| Multi-table JOIN  | Chaining 3 or more joins in one query                               |
| JOIN + GROUP BY   | Combining joins with aggregation for summary metrics                |
| `COALESCE`        | Fallback value when a joined column is NULL                         |

---

## Queries

| File | Question |
|------|----------|
| [01_orders_with_customer_location.sql](01_orders_with_customer_location.sql) | What city and state did each order come from? |
| [02_orders_missing_reviews.sql](02_orders_missing_reviews.sql) | Which orders have no customer review? |
| [03_orders_without_payment.sql](03_orders_without_payment.sql) | Are there orders with no payment record? |
| [04_order_items_detail.sql](04_order_items_detail.sql) | What product and seller details belong to each item? |
| [05_full_order_detail.sql](05_full_order_detail.sql) | What is the full picture of an order in one query? |
| [06_revenue_per_seller.sql](06_revenue_per_seller.sql) | What is each seller's total revenue and order count? |
| [07_products_in_english.sql](07_products_in_english.sql) | What are product categories in English? |
| [08_approved_but_not_shipped.sql](08_approved_but_not_shipped.sql) | Which orders were approved but never shipped? |
