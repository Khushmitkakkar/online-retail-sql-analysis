-- #3 Top 10 customers by net revenue and their share of total net revenue
-- Net revenue = sales minus cancellations (not profit).
-- All months included (Dec 2011 is partial).
SELECT TOP 10 WITH TIES
    CustomerID,
    SUM(Revenue) AS Net_Revenue,
    CAST(SUM(Revenue) * 100.0 / (SELECT SUM(Revenue) FROM clean_orders_all)
         AS NUMERIC(10,2)) AS [% of share]
FROM clean_orders_all
GROUP BY CustomerID
ORDER BY Net_Revenue DESC;
