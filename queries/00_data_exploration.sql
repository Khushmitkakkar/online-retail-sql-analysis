-- 00. Data exploration: the checks behind the cleaning rules
-- Run against the raw table `orders` in RetailDB before the views were built.
-- Each result is recorded in a comment below its query.

USE RetailDB;
GO

-- Check 1: how many rows have no CustomerID?
-- Result: 541,909 rows in total; 135,080 (24.93%) have no CustomerID.
-- Decision: treated as guest checkouts and excluded from every query, so all
-- figures come from one consistent population.
SELECT
    COUNT(*) AS Total_rows,
    SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) AS Null_customer_rows,
    CAST(SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS NUMERIC(5,2)) AS [Null_customer_%]
FROM orders;

-- Check 1b: how much sales revenue sits in rows without a CustomerID?
-- Result: 1,511,052.22 of 10,272,118.87 gross sales (14.71%).
-- This is the revenue left out by the decision above; stated in the README.
SELECT
    CAST(SUM(CASE WHEN CustomerID IS NULL THEN Quantity * UnitPrice ELSE 0 END) AS NUMERIC(12,2)) AS Revenue_no_customer,
    CAST(SUM(Quantity * UnitPrice) AS NUMERIC(12,2)) AS Revenue_all_rows,
    CAST(SUM(CASE WHEN CustomerID IS NULL THEN Quantity * UnitPrice ELSE 0 END) * 100.0
         / SUM(Quantity * UnitPrice) AS NUMERIC(5,2)) AS [No_customer_%]
FROM orders
WHERE Quantity > 0 AND UnitPrice > 0
  AND StockCode NOT IN ('POST','DOT','M','C2','D','S','BANK CHARGES','AMAZONFEE','CRUK','B');

-- Check 2: do invoices starting with 'C' match negative quantities?
-- Result: all 9,288 rows on C-invoices have negative quantity;
--         1,336 rows have negative quantity without a C prefix;
--         531,285 rows have positive quantity.
-- Decision: a cancellation is identified by Quantity < 0.
SELECT
    CASE WHEN InvoiceNo LIKE 'C%' THEN 'Starts with C' ELSE 'Does not start with C' END AS Invoice_type,
    CASE WHEN Quantity < 0 THEN 'Negative qty' ELSE 'Positive/zero qty' END AS Qty_type,
    COUNT(*) AS Row_count
FROM orders
GROUP BY
    CASE WHEN InvoiceNo LIKE 'C%' THEN 'Starts with C' ELSE 'Does not start with C' END,
    CASE WHEN Quantity < 0 THEN 'Negative qty' ELSE 'Positive/zero qty' END;

-- Check 2b: what are the negative-quantity rows that are NOT C-invoices?
-- Result: all 1,336 rows have price 0 and no CustomerID (stock adjustments, not customer cancellations).
-- Already removed by the views' UnitPrice > 0 and CustomerID IS NOT NULL filters,
-- so cancellation counts contain real cancellation invoices only.
SELECT
    COUNT(*) AS Rows_,
    SUM(CASE WHEN UnitPrice = 0 THEN 1 ELSE 0 END) AS Zero_price_rows,
    SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END) AS No_customer_rows
FROM orders
WHERE Quantity < 0 AND InvoiceNo NOT LIKE 'C%';

-- Check 3: non-product stock codes (anything that is not a normal numeric product code)
-- Result: POST (postage, 1,256 rows), DOT (dotcom postage, 710), M (manual, 572),
-- C2 (carriage, 144), D (discount, 77), S (samples, 63), BANK CHARGES (37),
-- AMAZONFEE (34), CRUK (commission, 16), B (bad debt adjustment).
-- Decision: these ten codes are not products and are excluded from the views.
-- Other non-numeric codes (party bags such as DCGSSGIRL/DCGSSBOY, gift vouchers)
-- are real sales and are kept.
SELECT StockCode, MAX(Description) AS Description, COUNT(*) AS Row_count
FROM orders
WHERE StockCode NOT LIKE '[0-9][0-9][0-9][0-9][0-9]%'
GROUP BY StockCode
ORDER BY Row_count DESC;

-- Check 4: zero and negative prices
-- Result: 2,515 rows with price 0, 2 rows with a negative price.
-- Decision: rows with UnitPrice <= 0 are excluded (not real sales).
SELECT
    SUM(CASE WHEN UnitPrice = 0 THEN 1 ELSE 0 END) AS Zero_price_rows,
    SUM(CASE WHEN UnitPrice < 0 THEN 1 ELSE 0 END) AS Negative_price_rows
FROM orders;

-- Check 5: invoices with more than one timestamp
-- Result: 43 invoices carry two different InvoiceDate values.
-- Decision: order-level metrics group by InvoiceNo, never by InvoiceDate
-- (grouping by date would split one invoice into two orders).
SELECT COUNT(*) AS Invoices_with_multiple_timestamps
FROM (
    SELECT InvoiceNo
    FROM orders
    GROUP BY InvoiceNo
    HAVING COUNT(DISTINCT InvoiceDate) > 1
) AS X;

-- Check 6: date range
-- Result: 2010-12-01 08:26 to 2011-12-09 12:50.
-- Decision: Dec 2011 is a partial month (9 days), so month-to-month queries
-- exclude it and cohorts stop before it.
SELECT MIN(InvoiceDate) AS First_date, MAX(InvoiceDate) AS Last_date FROM orders;

-- Check 7: reconciliation of the cleaned views
-- Result: gross sales 8,761,066.65; cancelled -474,403.33; net 8,286,663.32.
-- Net revenue = sales minus cancellations. It is not profit.
SELECT
    CAST(SUM(CASE WHEN Quantity > 0 THEN Revenue END) AS NUMERIC(12,2)) AS Gross_sales,
    CAST(SUM(CASE WHEN Quantity < 0 THEN Revenue END) AS NUMERIC(12,2)) AS Cancelled,
    CAST(SUM(Revenue) AS NUMERIC(12,2)) AS Net
FROM clean_orders_all;