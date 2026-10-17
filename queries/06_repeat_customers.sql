-- Excludes Dec 2011: data ends 9 Dec 2011, so that month is incomplete.
SELECT 
	DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1) AS [MONTH],
	COUNT(DISTINCT InvoiceNo) as total_orders,
	COUNT(DISTINCT CASE WHEN Quantity < 0 THEN InvoiceNo END) AS cancelled_orders,
	CAST(COUNT(DISTINCT CASE WHEN Quantity < 0 THEN InvoiceNo END) * 100.0 / COUNT(DISTINCT InvoiceNo) AS NUMERIC(10,2))  AS Cancellation_rate_pct
FROM clean_orders_all
WHERE InvoiceDate < '2011-12-01'
GROUP BY DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1)
ORDER BY [MONTH]