WITH inv AS (
    SELECT InvoiceNo,
           SUM(Quantity) AS units,
           SUM(Revenue)  AS invoice_value
    FROM clean_orders
    GROUP BY InvoiceNo
)
SELECT DISTINCT
    COUNT(*) OVER ()                                              AS invoices,
    AVG(units * 1.0) OVER ()                                      AS avg_units,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY units) OVER ()    AS median_units,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY invoice_value) OVER () AS median_invoice_value,
    SUM(CASE WHEN units >= 50 THEN 1 ELSE 0 END) OVER () * 100.0 / COUNT(*) OVER () AS pct_invoices_50plus_units
FROM inv;