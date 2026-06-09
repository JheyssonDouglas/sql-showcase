-- Question: How do sellers rank by revenue? What happens to the ranking when there are ties?
-- Technique: RANK() vs DENSE_RANK() — rank with gaps vs rank without gaps

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
    RANK()       OVER (ORDER BY total_revenue DESC) AS rank_with_gap,
    DENSE_RANK() OVER (ORDER BY total_revenue DESC) AS rank_no_gap
FROM seller_revenue
ORDER BY total_revenue DESC
LIMIT 20;
