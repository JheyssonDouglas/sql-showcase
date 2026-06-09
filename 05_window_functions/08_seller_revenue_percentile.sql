-- Question: What revenue percentile is each seller at relative to all sellers?
-- Technique: PERCENT_RANK() — returns a 0 to 1 relative rank

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
