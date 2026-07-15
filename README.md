A structured SQL business analysis project using Microsoft's AdventureWorks2019 database — a manufacturing and sales company dataset with 71 tables and 31,000+ orders. 15 business questions answered across 4 tiers of SQL complexity, from foundational aggregations to advanced window functions and CTEs.


📌 Database Overview

MetricValueDatabaseAdventureWorks2019 (OLTP)Total Tables71Sales Orders31,465Products504Customers19,820Data Period2011 – 2014SQL DialectMySQL 8.0


🗂️ Project Structure

adventureworks-sql-analysis/
│
├── Queries/
│   └── adventureworks_analysis.sql    # All 15 queries in one file
│
├── Results/
│   ├── Q01_revenue_by_year.csv
│   ├── Q02_top_products.csv
│   ├── Q03_sales_by_country.csv
│   ├── Q04_monthly_trend.csv
│   ├── Q05_customer_ltv.csv
│   ├── Q06_category_profitability.csv
│   ├── Q07_sales_rep_performance.csv
│   ├── Q08_discount_impact.csv
│   ├── Q09_mom_growth.csv
│   ├── Q10_running_total.csv
│   ├── Q11_top3_per_category.csv
│   ├── Q12_customer_segments.csv
│   ├── Q13_churn_risk.csv
│   ├── Q14_inventory_turnover.csv
│   └── Q15_executive_kpi.csv
│
└── README.md


📊 Key Business Findings (Q15 — Executive KPI)

KPIValueTotal Revenue (SubTotal)$109.8MTotal Orders31,465Unique Customers19,119Average Order Value$3,490Revenue Per Customer$5,738Data PeriodMay 2011 – Jun 2014


🔵 Tier 1 — Foundational Queries

#Business QuestionKey InsightQ01Total revenue by yearRevenue grew from $7.8M (2011) to $48.9M (2013)Q02Top 10 products by revenueMountain-200 Black leads at $4.4MQ03Sales by country/territoryUSA dominates at 39% of total revenueQ04Monthly revenue trendStrong seasonality — peaks in May–Jun each year


🟡 Tier 2 — Intermediate Queries (JOINs & Aggregations)

#Business QuestionKey InsightQ05Customer lifetime value (Top 20)Top customer generated $430K+ in LTVQ06Profitability by product categoryBikes = 88% of revenue; Clothing = highest marginQ07Sales rep performance vs quota3 of 17 reps exceeded their sales quotaQ08Discount impact analysisVolume discounts cost $2.1M in revenue leakage


🔴 Tier 3 — Advanced Queries (Window Functions & CTEs)

#Business QuestionSQL Feature UsedQ09Month-over-Month revenue growth %LAG() window functionQ10Running total of revenue by quarterSUM() OVER (PARTITION BY)Q11Top 3 products per categoryRANK() OVER (PARTITION BY)Q12Customer segmentation (RFM-style)NTILE(4) — Platinum/Gold/Silver/Bronze


🟣 Tier 4 — Business Insight Queries

#Business QuestionBusiness ValueQ13Churn risk customers (365+ days inactive)1,247 high-value customers at churn riskQ14Inventory turnover by categoryAccessories = highest turnover (7.2x)Q15Executive KPI summarySingle-query C-suite dashboard


💡 Notable SQL Techniques

sql-- Window Function: Month-over-Month Growth (Q09)
LAG(Revenue) OVER (ORDER BY Month)

-- CTE + RANK: Top 3 Products Per Category (Q11)
WITH product_revenue AS (...)
SELECT * FROM product_revenue WHERE Revenue_Rank <= 3

-- Customer Segmentation with NTILE (Q12)
NTILE(4) OVER (ORDER BY Monetary DESC)

-- Financial Accuracy: SubTotal vs TotalDue
-- TotalDue = SubTotal + TaxAmt + Freight
-- SubTotal used for pure revenue analysis


▶️ How to Run

Prerequisites


MySQL 8.0+
MySQL Workbench (or any MySQL client)
AdventureWorks2019 MySQL dump


Setup

sql-- 1. Create database
CREATE DATABASE adventureworks;
USE adventureworks;

-- 2. Import dump via terminal
-- mysql -u root -p adventureworks < AdventureWorks2019.sql

-- 3. Verify import
SHOW TABLES; -- Should return 71 tables
SELECT COUNT(*) FROM sales_salesorderheader; -- Should return 31,465

Run Analysis

Open Queries/adventureworks_analysis.sql in MySQL Workbench and execute queries individually or all at once.


🗺️ Database Exploration Approach

Before writing any analysis query, I followed a structured database exploration process:

sql-- 1. Map all tables and row counts
SELECT TABLE_NAME, TABLE_ROWS
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'adventureworks'
ORDER BY TABLE_ROWS DESC;

-- 2. Understand table structure
DESCRIBE sales_salesorderheader;

-- 3. Verify financial column definitions
SELECT SubTotal, TaxAmt, Freight, TotalDue,
       (SubTotal + TaxAmt + Freight) - TotalDue AS Variance
FROM sales_salesorderheader LIMIT 10;

-- 4. Check data quality and date range
SELECT MIN(OrderDate), MAX(OrderDate),
       COUNT(*), COUNT(DISTINCT CustomerID)
FROM sales_salesorderheader;


🛠️ Technical Skills Demonstrated

SkillImplementationMulti-table JOINsUp to 4-way joins across Sales, Production, Person schemasAggregationsSUM, COUNT, AVG, MIN, MAX with GROUP BYWindow FunctionsLAG, RANK, NTILE, SUM OVER PARTITION BYCTEsWITH clause for readable multi-step queriesSubqueriesNested SELECT for filtering and comparisonDate FunctionsYEAR, MONTH, DATE_FORMAT, DATEDIFFData ValidationNULL checks, formula verification, range checksBusiness LogicRFM segmentation, churn detection, quota variance


💼 Industry Relevance

This project demonstrates SQL skills directly applicable to:


Finance & MIS roles — P&L analysis, KPI reporting, variance analysis
Business Analyst roles — Customer segmentation, sales performance, churn analysis
Data Analyst roles — Window functions, trend analysis, executive reporting



👤 Author

Asif Mahmud Chowdhury
