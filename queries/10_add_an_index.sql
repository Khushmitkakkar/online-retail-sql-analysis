-- #10 Index optimization: customer order lookup
-- Question: does a nonclustered index speed up looking up one customer's orders?
-- Test customer: 14646 (2,085 rows).
--
-- Results (SET STATISTICS IO / TIME):
--   Before index: Table Scan, 6,400 logical reads, CPU 94 ms
--   After index:  Index Seek, 17 logical reads, CPU 0 ms

-- Step 1: measure before indexing
SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT InvoiceNo, InvoiceDate, Quantity, UnitPrice
FROM dbo.orders
WHERE CustomerID = 14646;

-- Step 2: covering nonclustered index (INCLUDE columns avoid a table lookup)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'ix_orders_customerid')
    CREATE NONCLUSTERED INDEX ix_orders_customerid
    ON dbo.orders (CustomerID)
    INCLUDE (InvoiceNo, InvoiceDate, Quantity, UnitPrice);
GO

-- Step 3: rerun the same query; compare logical reads and the execution plan
SELECT InvoiceNo, InvoiceDate, Quantity, UnitPrice
FROM dbo.orders
WHERE CustomerID = 14646;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
