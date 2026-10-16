SELECT	DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1) AS Month_start,
	CAST(SUM(Revenue) AS NUMERIC(10,2)) AS Total_Revenue,
	COUNT(DISTINCT InvoiceNo) AS Order_count,
	COUNT(DISTINCT CustomerID) AS Customer_count
FROM clean_orders
WHERE InvoiceDate < '2011-12-01'
GROUP BY DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1)
ORDER BY Month_start;