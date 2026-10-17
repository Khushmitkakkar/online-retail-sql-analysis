USE RetailDB;
GO

CREATE VIEW clean_orders AS
SELECT InvoiceNo, StockCode, Description, Quantity, InvoiceDate,
       cast(UnitPrice as numeric(10,2)) as UnitPrice, CustomerID, Country,
       cast((Quantity * UnitPrice) as numeric(10,2)) AS Revenue
FROM orders
WHERE CustomerID IS NOT NULL
  AND Quantity > 0
  AND UnitPrice > 0
  AND StockCode NOT IN ('POST','DOT','M','C2','D','S','BANK CHARGES','AMAZONFEE','CRUK','B')


GO

   CREATE VIEW clean_orders_all AS
   SELECT InvoiceNo, StockCode, Description, Quantity, InvoiceDate,
       cast(UnitPrice as numeric(10,2)) as UnitPrice, CustomerID, Country,
       cast((Quantity * UnitPrice) as numeric(10,2)) AS Revenue
FROM orders
WHERE CustomerID IS NOT NULL
  AND StockCode NOT IN ('POST','DOT','M','C2','D','S','BANK CHARGES','AMAZONFEE','CRUK','B')
  AND UnitPrice > 0;
