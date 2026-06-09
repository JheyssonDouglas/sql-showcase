-- Question: How does total revenue accumulate month over month?
-- Technique: SUM() OVER with ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW

WITH monthly_revenue AS (
    SELECT
        DATE_TRUNC('month', o.order_purchase_timestamp) AS order_month,
        ROUND(SUM(oi.price), 2)                         AS monthly_revenue
    FROM olist_orders_dataset            AS o
    INNER JOIN olist_order_items_dataset  AS oi ON o.order_id = oi.order_id
    WHERE o.order_status = 'delivered'
    GROUP BY order_month
)
SELECT
    order_month,
    monthly_revenue,
    ROUND(SUM(monthly_revenue) OVER (
        ORDER BY order_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ), 2)                                AS cumulative_revenue
FROM monthly_revenue
ORDER BY order_month;
