-- #4a Net revenue by country, with each country's share of total net revenue
-- Net revenue = sales minus cancellations (not profit).
-- All months included (Dec 2011 is partial).
SELECT
    Country,
    COUNT(DISTINCT CustomerID) AS Customer_count,
    SUM(Revenue) AS Net_Revenue,
    CAST(SUM(Revenue) * 100.0 / (SELECT SUM(Revenue) FROM clean_orders_all)
         AS NUMERIC(10,2)) AS [% of share]
FROM clean_orders_all
GROUP BY Country
ORDER BY Net_Revenue DESC;

-- #4b Same, excluding the United Kingdom: share among international markets only
SELECT
    Country,
    COUNT(DISTINCT CustomerID) AS Customer_count,
    SUM(Revenue) AS Net_Revenue,
    CAST(SUM(Revenue) * 100.0 /
         (SELECT SUM(Revenue) FROM clean_orders_all WHERE Country <> 'United Kingdom')
         AS NUMERIC(10,2)) AS [% of share]
FROM clean_orders_all
WHERE Country <> 'United Kingdom'
GROUP BY Country
ORDER BY Net_Revenue DESC;
