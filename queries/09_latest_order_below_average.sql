-- #9 Customers whose latest order is below their average previous order value
-- Uses clean_orders (purchases only). Order total = sum of all lines on one invoice.
-- Grouped by InvoiceNo, not InvoiceDate: some invoices span two timestamps.
-- Latest order = most recent date (InvoiceNo breaks ties).
-- Customers with only one order have no previous orders, so they are excluded.

WITH order_totals AS (
    -- One row per invoice
    SELECT
        CustomerID,
        InvoiceNo,
        MIN(InvoiceDate) AS Order_date,
        SUM(Revenue) AS Order_total
    FROM clean_orders
    GROUP BY CustomerID, InvoiceNo
),

latest_orders AS (
    -- Most recent order per customer
    SELECT CustomerID, InvoiceNo, Order_date, Order_total
    FROM (
        SELECT *,
               ROW_NUMBER() OVER (PARTITION BY CustomerID
                                  ORDER BY Order_date DESC, InvoiceNo DESC) AS rn
        FROM order_totals
    ) AS X
    WHERE rn = 1
),

previous_avg AS (
    -- Average order total over all orders except the latest one
    SELECT CustomerID, AVG(Order_total) AS Avg_previous_order_total
    FROM (
        SELECT CustomerID, InvoiceNo, Order_date, Order_total FROM order_totals
        EXCEPT
        SELECT CustomerID, InvoiceNo, Order_date, Order_total FROM latest_orders
    ) AS Y
    GROUP BY CustomerID
)

SELECT
    L.CustomerID,
    L.InvoiceNo AS Latest_InvoiceNo,
    L.Order_total AS Latest_order_total,
    CAST(P.Avg_previous_order_total AS NUMERIC(10,2)) AS Avg_previous_order_total
FROM latest_orders AS L
JOIN previous_avg AS P
    ON P.CustomerID = L.CustomerID
WHERE L.Order_total < P.Avg_previous_order_total;