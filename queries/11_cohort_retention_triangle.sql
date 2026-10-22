-- 11. Cohort retention triangle
-- Business question: of the customers who first bought in a given month,
-- what % came back to buy in each following month?
-- Active = placed at least one order in that calendar month (not required to be consecutive).
-- Dec 2011 is excluded because the data ends on 9 Dec 2011 (partial month).
-- Note: Dec 2010 is the first month of the data, so that cohort includes
-- customers who were not truly new.

WITH cohorts AS (
    -- each customer's cohort = month of their first order
    SELECT
        CustomerID,
        DATEFROMPARTS(YEAR(MIN(InvoiceDate)), MONTH(MIN(InvoiceDate)), 1) AS cohort_month
    FROM clean_orders
    WHERE InvoiceDate < '2011-12-01'
    GROUP BY CustomerID
),

activity AS (
    -- one row per customer per month in which they bought
    SELECT DISTINCT
        CustomerID,
        DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1) AS purchase_month
    FROM clean_orders
    WHERE InvoiceDate < '2011-12-01'
),

cohort_offsets AS (
    -- months elapsed between a customer's cohort month and each active month
    SELECT
        C.cohort_month,
        C.CustomerID,
        DATEDIFF(MONTH, C.cohort_month, A.purchase_month) AS month_offset
    FROM activity AS A
    JOIN cohorts AS C
        ON A.CustomerID = C.CustomerID
),

retained AS (
    -- distinct customers active in each cohort and offset
    SELECT
        cohort_month,
        month_offset,
        COUNT(DISTINCT CustomerID) AS retained_customers
    FROM cohort_offsets
    GROUP BY cohort_month, month_offset
)

SELECT
    cohort_month,
    month_offset,
    retained_customers,
    -- offset 0 = every customer in the cohort, so it gives the cohort size
    MAX(CASE WHEN month_offset = 0 THEN retained_customers END)
        OVER (PARTITION BY cohort_month) AS cohort_size,
    CAST(retained_customers * 100.0
         / MAX(CASE WHEN month_offset = 0 THEN retained_customers END)
               OVER (PARTITION BY cohort_month) AS NUMERIC(5,2)) AS [retention_%]
FROM retained
ORDER BY cohort_month, month_offset;