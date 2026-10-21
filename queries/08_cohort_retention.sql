-- #8 Cohort retention, month +1
-- Cohort    = the month of a customer's first order.
-- Retained  = the customer bought again in the next calendar month.
-- Uses clean_orders (real purchases only, no cancellations).
-- Cohorts from Nov 2011 onward are excluded: their next month (Dec 2011) is incomplete.

WITH cohorts AS (
    -- One row per customer with their first order month
    SELECT
        CustomerID,
        DATEFROMPARTS(YEAR(MIN(InvoiceDate)), MONTH(MIN(InvoiceDate)), 1) AS Cohort_month
    FROM clean_orders
    WHERE InvoiceDate < '2011-11-01'
    GROUP BY CustomerID
),

activity AS (
    -- One row per customer per month in which they bought
    SELECT DISTINCT
        CustomerID,
        DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1) AS Purchase_month
    FROM clean_orders
)

SELECT
    C.Cohort_month,
    COUNT(*) AS Cohort_size,
    COUNT(A.CustomerID) AS Retained_customers,
    CAST(COUNT(A.CustomerID) * 100.0 / COUNT(*) AS NUMERIC(5,2)) AS [Retention_%]
FROM cohorts AS C
LEFT JOIN activity AS A                  -- LEFT JOIN keeps customers who did not return
    ON  A.CustomerID = C.CustomerID
    AND A.Purchase_month = DATEADD(MONTH, 1, C.Cohort_month)
GROUP BY C.Cohort_month
ORDER BY C.Cohort_month;