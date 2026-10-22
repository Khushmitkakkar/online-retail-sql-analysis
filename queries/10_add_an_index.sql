/*========================================================
  Q10: Index Optimization — Customer Order Lookup
========================================================*/

-- Step 1: Measure query performance before indexing
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT InvoiceNo, InvoiceDate, Quantity, UnitPrice
FROM dbo.orders
WHERE CustomerID = 14646;

-- Step 2: Create a covering nonclustered index
CREATE NONCLUSTERED INDEX ix_orders_customerid
ON dbo.orders (CustomerID)
INCLUDE (InvoiceNo, InvoiceDate, Quantity, UnitPrice);

-- Step 3: Rerun the same SELECT query and inspect
-- logical reads, CPU/elapsed time, and actual execution plan

SELECT InvoiceNo, InvoiceDate, Quantity, UnitPrice
FROM dbo.orders
WHERE CustomerID = 14646;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;