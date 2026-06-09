-- Question: How does payment type affect order size and installment use?
-- Technique: GROUP BY with multiple aggregate functions

SELECT
    payment_type,
    COUNT(DISTINCT order_id)          AS total_orders,
    ROUND(AVG(payment_value), 2)      AS avg_payment_value,
    ROUND(SUM(payment_value), 2)      AS total_payment_value,
    ROUND(MAX(payment_value), 2)      AS max_payment_value,
    ROUND(AVG(payment_installments), 1) AS avg_installments
FROM olist_order_payments_dataset
GROUP BY payment_type
ORDER BY total_orders DESC;
