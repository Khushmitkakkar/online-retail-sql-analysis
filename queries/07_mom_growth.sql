-- #7 Month-over-month revenue growth
-- Net revenue (clean_orders_all): sales minus cancellations. This is not profit.
-- Dec 2011 excluded: data ends 9 Dec, so the month is incomplete.
-- The first month (Dec 2010) has no previous month, so its growth is NULL.

WITH monthly AS (
    -- One row per month with total net revenue
    SELECT
        DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1) AS Month_start,
        SUM(Revenue) AS Revenue
    FROM clean_orders_all
    WHERE InvoiceDate < '2011-12-01'
    GROUP BY DATEFROMPARTS(YEAR(InvoiceDate), MONTH(InvoiceDate), 1)
),

with_prev AS (
    -- Attach the previous month's revenue to each row
    SELECT
        Month_start,
        Revenue,
        LAG(Revenue) OVER (ORDER BY Month_start) AS Prev_month_revenue
    FROM monthly
)

SELECT
    Month_start,
    Revenue,
    Prev_month_revenue,
    CAST((Revenue - Prev_month_revenue) * 100.0
         / NULLIF(Prev_month_revenue, 0) AS NUMERIC(10,2)) AS [MoM_growth_%]
FROM with_prev
ORDER BY Month_start;