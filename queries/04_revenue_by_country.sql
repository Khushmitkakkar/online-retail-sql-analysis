SELECT 
	Country,
	COUNT(DISTINCT CustomerID) AS CUSTOMER_COUNT,
	SUM(Revenue) AS Net_Revenue,
	CAST(SUM(Revenue) * 100.0 / (SELECT SUM(Revenue) FROM clean_orders_all) AS NUMERIC(10,2)) AS [% of share]
FROM clean_orders_all
GROUP BY Country
ORDER BY Net_Revenue DESC

-- share of all-country revenue except united kingdom
-- all months included (Dec 2011 partial)
SELECT 
	Country,
	COUNT(DISTINCT CustomerID) AS CUSTOMER_COUNT,
	SUM(Revenue) AS Net_Revenue,
	CAST(SUM(Revenue) * 100.0 / (SELECT SUM(Revenue) FROM clean_orders_all WHERE Country <> 'United Kingdom') AS NUMERIC(10,2)) AS [% of share]
FROM clean_orders_all
WHERE Country <> 'United Kingdom'
GROUP BY Country
ORDER BY Net_Revenue DESC;