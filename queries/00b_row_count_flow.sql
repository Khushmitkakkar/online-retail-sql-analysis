WITH Row_Count AS(SELECT 1 AS step_no, 'Raw orders' AS step_name, COUNT(*) AS row_count
FROM orders
UNION ALL
SELECT 2, 'CustomerID not NULL', COUNT(*)
FROM orders
WHERE CustomerID IS NOT NULL
UNION ALL
SELECT 3, 'UnitPrice > 0', COUNT(*)
FROM orders
WHERE CustomerID IS NOT NULL AND UnitPrice > 0
UNION ALL
SELECT 4, 'clean_orders_all (net view)', COUNT(*)
FROM clean_orders_all
WHERE CustomerID IS NOT NULL
UNION ALL
SELECT 5, 'Purchases only (Quantity > 0)', COUNT(*)
FROM clean_orders
WHERE CustomerID IS NOT NULL)

SELECT *,
LAG(row_count) OVER(ORDER BY step_no) - row_count AS rows_removed
FROM Row_Count;