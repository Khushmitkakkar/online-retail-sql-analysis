-- #2 Top 10 products by net revenue (net revenue = sales minus cancellations, not profit)
-- StockCode identifies the product; Description is only a label (MAX picks one per code).
SELECT TOP 10 WITH TIES
    StockCode,
    CAST(SUM(Revenue) AS NUMERIC(10,2)) AS Net_Revenue,
    MAX(Description) AS Description
FROM clean_orders_all
GROUP BY StockCode
ORDER BY Net_Revenue DESC;
