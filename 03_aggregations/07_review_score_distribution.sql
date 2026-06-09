-- Question: How are customer review scores distributed across the platform?
-- Technique: GROUP BY with window function percentage

SELECT
    review_score,
    COUNT(*)                                                          AS total_reviews,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2)               AS pct_of_total
FROM olist_order_reviews_dataset
GROUP BY review_score
ORDER BY review_score;
