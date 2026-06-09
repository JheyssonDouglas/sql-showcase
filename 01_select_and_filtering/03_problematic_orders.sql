-- Question: Which orders are in a non-final state (canceled, unavailable, or processing)?
-- Technique: IN / NOT IN operator

-- Orders in non-final states
SELECT
    order_id,
    order_status,
    order_purchase_timestamp
FROM olist_orders_dataset
WHERE order_status IN ('canceled', 'unavailable', 'processing')
ORDER BY order_purchase_timestamp DESC;


-- Orders excluding the two main final states
SELECT
    order_id,
    order_status
FROM olist_orders_dataset
WHERE order_status NOT IN ('delivered', 'shipped')
ORDER BY order_status;
