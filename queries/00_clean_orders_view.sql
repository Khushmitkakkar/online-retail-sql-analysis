USE RetailDB;
GO

-- clean_orders: real purchases only (used for counts of customers, orders, cohorts)
-- Excludes: rows without CustomerID, cancellations/returns (Quantity <= 0),
-- zero or negative prices, and non-product stock codes (postage, fees, manual entries).
CREATE OR ALTER VIEW clean_orders AS
SELECT InvoiceNo, StockCode, Description, Quantity, InvoiceDate,
       CAST(UnitPrice AS NUMERIC(10,2)) AS UnitPrice, CustomerID, Country,
       CAST(Quantity * UnitPrice AS NUMERIC(10,2)) AS Revenue
FROM orders
WHERE CustomerID IS NOT NULL
  AND Quantity > 0
  AND UnitPrice > 0
  AND StockCode NOT IN ('POST','DOT','M','C2','D','S','BANK CHARGES','AMAZONFEE','CRUK','B');
GO

-- clean_orders_all: same rules but keeps cancellations as negative revenue.
-- Used for net revenue (sales minus cancellations). Net revenue is not profit.
CREATE OR ALTER VIEW clean_orders_all AS
SELECT InvoiceNo, StockCode, Description, Quantity, InvoiceDate,
       CAST(UnitPrice AS NUMERIC(10,2)) AS UnitPrice, CustomerID, Country,
       CAST(Quantity * UnitPrice AS NUMERIC(10,2)) AS Revenue
FROM orders
WHERE CustomerID IS NOT NULL
  AND UnitPrice > 0
  AND StockCode NOT IN ('POST','DOT','M','C2','D','S','BANK CHARGES','AMAZONFEE','CRUK','B');
GO
