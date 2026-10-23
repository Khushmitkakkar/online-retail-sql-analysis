# Online Retail Sales Analysis (SQL Server)

SQL-only analysis of a UK online retailer's transactions: revenue trends, top customers and products, cancellations, repeat buying, cohort retention and index tuning.

**Tools:** SQL Server Express, SSMS, T-SQL (CTEs, window functions, views, indexing)
**Dataset:** [Online Retail, UCI / Kaggle](https://archive.ics.uci.edu/dataset/352/online+retail), 541,909 rows, single table, 1 Dec 2010 to 9 Dec 2011

## Business problem
A retailer wants to know where its revenue comes from, how much it loses to cancellations, whether customers come back, and whether growth is steady or seasonal.

## Key questions
1. How does revenue, order count and customer count change by month?
2. Which products and customers drive the most net revenue?
3. Which countries matter beyond the UK?
4. How often are orders cancelled?
5. What share of customers buy more than once?
6. How fast is revenue growing month over month?
7. Of the customers acquired in a month, how many come back later (cohort retention)?
8. Which customers' latest order is below their usual order value?
9. Does an index speed up a customer lookup?

## Data cleaning rules
Two views sit on top of the raw `orders` table (`queries/00_clean_orders_view.sql`):

| View | Use | Rules |
|---|---|---|
| `clean_orders` | Counts and behaviour (customers, orders, cohorts) | Real purchases only |
| `clean_orders_all` | Net revenue and rankings | Same, but keeps cancellations as negative revenue |

Both exclude: rows with no CustomerID, zero or negative prices, and non-product codes (POST, DOT, M, C2, D, S, BANK CHARGES, AMAZONFEE, CRUK, B).

## Assumptions
- **Net revenue = sales minus cancellations. It is not profit**, because the data has no cost information.
- Rows without a CustomerID are treated as guest checkouts and excluded.
- A cancellation is a row with negative quantity.
- Dec 2011 is incomplete (data ends 9 Dec), so month-to-month queries exclude it and cohorts stop before it.
- Product is identified by StockCode; Description is only a label.
- Some invoices carry two timestamps, so order-level metrics group by InvoiceNo, never by InvoiceDate.
- Repeat customer = 2 or more distinct invoices.
- Active in a month = at least one order in that calendar month (not required to be consecutive).
- Dec 2010 is the first month of the data, so that cohort includes customers who were not truly new.

## Queries
| # | File | What it answers |
|---|---|---|
| 00 | `00_clean_orders_view.sql` | Cleaning views |
| 01 | `01_monthly_revenue.sql` | Monthly revenue, orders, customers |
| 02 | `02_top_products.sql` | Top 10 products by net revenue |
| 03 | `03_top_customers.sql` | Top 10 customers and their share of revenue |
| 04 | `04_revenue_by_country.sql` | Net revenue by country, with and without the UK |
| 05 | `05_cancellation_rate.sql` | Monthly cancellation rate |
| 06 | `06_repeat_customers.sql` | One-time vs repeat customers |
| 07 | `07_mom_growth.sql` | Month-over-month growth (LAG) |
| 08 | `08_cohort_retention.sql` | Month +1 retention per cohort |
| 09 | `09_latest_order_below_average.sql` | Latest order below the customer's previous average |
| 10 | `10_add_an_index.sql` | Index before and after |
| 11 | `11_cohort_retention_triangle.sql` | Full cohort retention triangle |

## Findings
- **Net revenue is 8.30M** (gross 8.91M, cancellations -0.61M, about 6.9% of gross).
- **Revenue is concentrated in a few customers**: the top 3 customers (14646, 18102, 17450) account for about 8.8% of net revenue.
- **Top product:** 22423 REGENCY CAKESTAND 3 TIER, 132,870 net revenue.
- **The UK is 82.34% of net revenue.** Netherlands, EIRE and Australia have only a handful of customers each but large revenue, which looks like wholesale buying.
- **About 14 to 20% of invoices each month are cancellations.**
- **65.27% of customers placed more than one order.**
- **Revenue is seasonal:** it climbs from September to a peak of 1.12M in Nov 2011 (+50.5% in Sep, then up again into Nov).
- **Retention:** only about 22 to 37% of a cohort buys again in the next month, then it flattens around 35%. The Dec 2010 cohort rises to 50.2% in Nov 2011, driven by the seasonal peak rather than loyalty.
- **Indexing:** a covering nonclustered index on CustomerID changed the lookup from a table scan (6,400 logical reads) to an index seek (17 logical reads).

## Recommendations
- Protect the largest accounts: a few customers carry a visible share of revenue.
- Investigate cancellations, especially large bulk orders cancelled minutes after being placed, since they inflate gross figures.
- Plan stock and staffing for the Sep to Nov peak.
- Focus retention effort on the first month after a customer's first order, where most customers drop off.

## Results
Screenshots of each query's output are in [`results/`](results).

## Limitations
- One year of data, so seasonality cannot be separated from growth.
- No cost data, so no profit or margin analysis.
- Guest checkouts (no CustomerID) are excluded from all customer metrics.
