-- #6 Repeat customer rate
-- Repeat customer = placed more than one distinct order (InvoiceNo).
-- Counted at customer level, so the denominator is customers, not invoices.
-- Uses clean_orders (real purchases only).
WITH customer_orders AS (
    SELECT CustomerID, COUNT(DISTINCT InvoiceNo) AS Order_count
    FROM clean_orders
    GROUP BY CustomerID
)
SELECT
    COUNT(*) AS Total_customers,
    COUNT(CASE WHEN Order_count > 1 THEN 1 END) AS Repeat_customers,
    CAST(COUNT(CASE WHEN Order_count > 1 THEN 1 END) * 100.0 / COUNT(*)
         AS NUMERIC(5,2)) AS [Repeat_rate_%]
FROM customer_orders;
