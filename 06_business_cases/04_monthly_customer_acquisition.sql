-- Question: How many new customers are acquired each month?
-- Case: Customer Analysis (2a)

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
