-- #5 Monthly cancellation rate
-- Cancelled order = invoice with negative quantity (clean_orders_all keeps these).
-- Rate = cancelled invoices / total invoices in the month.
-- Dec 2011 excluded: data ends 9 Dec, so the month is incomplete.
SELECT
    DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1) AS [Month],
    COUNT(DISTINCT InvoiceNo) AS Total_orders,
    COUNT(DISTINCT CASE WHEN Quantity < 0 THEN InvoiceNo END) AS Cancelled_orders,
    CAST(COUNT(DISTINCT CASE WHEN Quantity < 0 THEN InvoiceNo END) * 100.0
         / COUNT(DISTINCT InvoiceNo) AS NUMERIC(10,2)) AS [Cancellation_rate_%]
FROM clean_orders_all
WHERE InvoiceDate < '2011-12-01'
GROUP BY DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1)
ORDER BY [Month];
