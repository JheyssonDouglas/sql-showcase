-- Question: Which orders have no customer review?
-- Technique: LEFT JOIN — all orders retained; NULL in right table = no review

SELECT
    o.order_id,
    o.order_status,
    r.review_score,
    r.review_comment_title
FROM olist_orders_dataset              AS o
LEFT JOIN olist_order_reviews_dataset   AS r ON o.order_id = r.order_id
WHERE r.order_id IS NULL
ORDER BY o.order_purchase_timestamp DESC
LIMIT 20;
