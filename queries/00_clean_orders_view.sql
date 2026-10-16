USE RetailDB;
GO

CREATE VIEW clean_orders AS
SELECT InvoiceNo, StockCode, Description, Quantity, InvoiceDate,
       UnitPrice, CustomerID, Country,
       Quantity * UnitPrice AS Revenue
FROM orders
WHERE CustomerID IS NOT NULL
  AND Quantity > 0
  AND UnitPrice > 0;