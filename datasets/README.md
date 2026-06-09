# Datasets

The CSV files used in this project are **not committed to this repository** to keep the repo lightweight.

## Download

Download the **Brazilian E-Commerce Public Dataset by Olist** from Kaggle:

[https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)

## Required Files

Place the following files in this `datasets/` folder after downloading:

| File                                    | Size  | Description                    |
|-----------------------------------------|-------|--------------------------------|
| `olist_customers_dataset.csv`           | 8.6MB | Customer records               |
| `olist_orders_dataset.csv`              | 17MB  | Orders with status/timestamps  |
| `olist_order_items_dataset.csv`         | 15MB  | Products sold within orders    |
| `olist_products_dataset.csv`            | 2.3MB | Product catalog with categories|
| `olist_sellers_dataset.csv`             | 172KB | Seller information             |
| `olist_order_payments_dataset.csv`      | 5.5MB | Payment method and values      |
| `olist_order_reviews_dataset.csv`       | 14MB  | Customer satisfaction scores   |
| `product_category_name_translation.csv` | 4KB   | PT → EN category translation   |

> `olist_geolocation_dataset.csv` is not used in this project.

## Load into DuckDB

After placing the CSV files here, run from the project root:

```bash
duckdb database/olist.duckdb < database/setup.sql
```
