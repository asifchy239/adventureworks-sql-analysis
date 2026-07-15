🔵 Tier 1 — Foundational Queries


Q1 — Total Revenue by Year
SELECT 
    YEAR(OrderDate) AS Year,
    COUNT(SalesOrderID) AS Total_Orders,
    ROUND(SUM(SubTotal), 2) AS Total_Revenue,
    ROUND(SUM(TaxAmt), 2) AS Total_Tax,
    ROUND(SUM(Freight), 2) AS Total_Freight,
    ROUND(SUM(TotalDue), 2) AS Total_Billed,
    ROUND(AVG(SubTotal), 2) AS Avg_Order_Value
FROM sales_salesorderheader
GROUP BY YEAR(OrderDate)
ORDER BY Year;

Q2 — Top 10 Products by Revenue

SELECT 
    p.Name AS Product_Name,
    p.ProductNumber,
    SUM(sod.OrderQty) AS Units_Sold,
    ROUND(SUM(sod.LineTotal), 2) AS Total_Revenue
FROM sales_salesorderdetail sod
JOIN production_product p ON sod.ProductID = p.ProductID
GROUP BY p.ProductID, p.Name, p.ProductNumber
ORDER BY Total_Revenue DESC
LIMIT 10;

Q3 — Sales by Country/Region
SELECT 
    st.Name AS Territory,
    st.CountryRegionCode AS Country,
    COUNT(soh.SalesOrderID) AS Total_Orders,
    ROUND(SUM(soh.TotalDue), 2) AS Total_Revenue
FROM sales_salesorderheader soh
JOIN sales_salesterritory st ON soh.TerritoryID = st.TerritoryID
GROUP BY st.TerritoryID, st.Name, st.CountryRegionCode
ORDER BY Total_Revenue DESC;

Q4 — Monthly Revenue Trend
SELECT 
    DATE_FORMAT(OrderDate, '%Y-%m') AS Month,
    COUNT(SalesOrderID) AS Orders,
    ROUND(SUM(TotalDue), 2) AS Revenue
FROM sales_salesorderheader
GROUP BY DATE_FORMAT(OrderDate, '%Y-%m')
ORDER BY Month;

🟡 Tier 2 — Intermediate Queries

Q5 — Customer Lifetime Value (Top 20)
SELECT 
    c.CustomerID,
    COUNT(soh.SalesOrderID) AS Total_Orders,
    ROUND(SUM(soh.TotalDue), 2) AS Lifetime_Value,
    ROUND(AVG(soh.TotalDue), 2) AS Avg_Order_Value,
    MIN(soh.OrderDate) AS First_Order,
    MAX(soh.OrderDate) AS Last_Order
FROM sales_customer c
JOIN sales_salesorderheader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID
ORDER BY Lifetime_Value DESC
LIMIT 20;

Q6 — Product Profitability by Category
SELECT 
    pc.Name AS Category,
    COUNT(DISTINCT p.ProductID) AS Products,
    SUM(sod.OrderQty) AS Units_Sold,
    ROUND(SUM(sod.LineTotal), 2) AS Revenue,
    ROUND(SUM(sod.OrderQty * p.StandardCost), 2) AS Total_Cost,
    ROUND(SUM(sod.LineTotal) - SUM(sod.OrderQty * p.StandardCost), 2) AS Gross_Profit,
    ROUND((SUM(sod.LineTotal) - SUM(sod.OrderQty * p.StandardCost)) 
          / SUM(sod.LineTotal) * 100, 2) AS Profit_Margin_Pct
FROM sales_salesorderdetail sod
JOIN production_product p ON sod.ProductID = p.ProductID
JOIN production_productsubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN production_productcategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY pc.ProductCategoryID, pc.Name
ORDER BY Gross_Profit DESC;

Q7 — Sales Rep Performance vs Average
SELECT 
    sp.BusinessEntityID AS SalesRep_ID,
    COUNT(soh.SalesOrderID) AS Total_Orders,
    ROUND(SUM(soh.TotalDue), 2) AS Total_Sales,
    ROUND(AVG(soh.TotalDue), 2) AS Avg_Deal_Size,
    ROUND(sp.SalesQuota, 2) AS Sales_Quota,
    ROUND(SUM(soh.TotalDue) - sp.SalesQuota, 2) AS Quota_Variance
FROM sales_salesperson sp
JOIN sales_salesorderheader soh ON sp.BusinessEntityID = soh.SalesPersonID
GROUP BY sp.BusinessEntityID, sp.SalesQuota
ORDER BY Total_Sales DESC;

Q8 — Discount Impact Analysis
SELECT 
    sod.SpecialOfferID,
    so.Description AS Offer_Description,
    so.DiscountPct,
    COUNT(sod.SalesOrderDetailID) AS Times_Applied,
    SUM(sod.OrderQty) AS Units_Sold,
    ROUND(SUM(sod.LineTotal), 2) AS Actual_Revenue,
    ROUND(SUM(sod.OrderQty * sod.UnitPrice), 2) AS Revenue_Without_Discount,
    ROUND(SUM(sod.OrderQty * sod.UnitPrice) - SUM(sod.LineTotal), 2) AS Discount_Cost
FROM sales_salesorderdetail sod
JOIN sales_specialoffer so ON sod.SpecialOfferID = so.SpecialOfferID
GROUP BY sod.SpecialOfferID, so.Description, so.DiscountPct
ORDER BY Discount_Cost DESC;

🔴 Tier 3 — Advanced Queries (Window Functions & CTEs)

Q9 — Month-over-Month Revenue Growth %
WITH monthly_revenue AS (
    SELECT 
        DATE_FORMAT(OrderDate, '%Y-%m') AS Month,
        ROUND(SUM(TotalDue), 2) AS Revenue
    FROM sales_salesorderheader
    GROUP BY DATE_FORMAT(OrderDate, '%Y-%m')
)
SELECT 
    Month,
    Revenue,
    LAG(Revenue) OVER (ORDER BY Month) AS Prev_Month_Revenue,
    ROUND((Revenue - LAG(Revenue) OVER (ORDER BY Month)) 
          / LAG(Revenue) OVER (ORDER BY Month) * 100, 2) AS MoM_Growth_Pct
FROM monthly_revenue
ORDER BY Month;

Q10 — Running Total of Revenue by Quarter
WITH quarterly AS (
    SELECT 
        YEAR(OrderDate) AS Year,
        QUARTER(OrderDate) AS Quarter,
        ROUND(SUM(TotalDue), 2) AS Quarterly_Revenue
    FROM sales_salesorderheader
    GROUP BY YEAR(OrderDate), QUARTER(OrderDate)
)
SELECT 
    Year,
    Quarter,
    Quarterly_Revenue,
    ROUND(SUM(Quarterly_Revenue) OVER (
        PARTITION BY Year ORDER BY Quarter
    ), 2) AS Running_Total
FROM quarterly
ORDER BY Year, Quarter;

Q11 — Top 3 Products Per Category (RANK)
WITH product_revenue AS (
    SELECT 
        pc.Name AS Category,
        p.Name AS Product,
        ROUND(SUM(sod.LineTotal), 2) AS Revenue,
        RANK() OVER (
            PARTITION BY pc.ProductCategoryID 
            ORDER BY SUM(sod.LineTotal) DESC
        ) AS Revenue_Rank
    FROM sales_salesorderdetail sod
    JOIN production_product p ON sod.ProductID = p.ProductID
    JOIN production_productsubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
    JOIN production_productcategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
    GROUP BY pc.ProductCategoryID, pc.Name, p.ProductID, p.Name
)
SELECT Category, Product, Revenue, Revenue_Rank
FROM product_revenue
WHERE Revenue_Rank <= 3
ORDER BY Category, Revenue_Rank;

Q12 — Customer Percentile Segmentation (RFM-Style)
WITH customer_stats AS (
    SELECT 
        CustomerID,
        COUNT(SalesOrderID) AS Frequency,
        ROUND(SUM(TotalDue), 2) AS Monetary,
        DATEDIFF('2014-06-30', MAX(OrderDate)) AS Recency_Days
    FROM sales_salesorderheader
    GROUP BY CustomerID
)
SELECT 
    CustomerID,
    Frequency,
    Monetary,
    Recency_Days,
    NTILE(4) OVER (ORDER BY Monetary DESC) AS Value_Quartile,
    CASE 
        WHEN NTILE(4) OVER (ORDER BY Monetary DESC) = 1 THEN 'Platinum'
        WHEN NTILE(4) OVER (ORDER BY Monetary DESC) = 2 THEN 'Gold'
        WHEN NTILE(4) OVER (ORDER BY Monetary DESC) = 3 THEN 'Silver'
        ELSE 'Bronze'
    END AS Customer_Segment
FROM customer_stats
ORDER BY Monetary DESC
LIMIT 50;

🟣 Tier 4 — Business Insight Queries

Q13 — Churn Risk: Customers With No Order in 12+ Months
SELECT 
    c.CustomerID,
    COUNT(soh.SalesOrderID) AS Total_Orders,
    ROUND(SUM(soh.TotalDue), 2) AS Lifetime_Value,
    MAX(soh.OrderDate) AS Last_Order_Date,
    DATEDIFF('2014-06-30', MAX(soh.OrderDate)) AS Days_Since_Last_Order
FROM sales_customer c
JOIN sales_salesorderheader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID
HAVING Days_Since_Last_Order >= 365
ORDER BY Lifetime_Value DESC
LIMIT 20;

Q14 — Inventory Turnover by Product Category
SELECT 
    pc.Name AS Category,
    SUM(sod.OrderQty) AS Units_Sold,
    ROUND(AVG(pi.Quantity), 0) AS Avg_Inventory,
    ROUND(SUM(sod.OrderQty) / NULLIF(AVG(pi.Quantity), 0), 2) AS Inventory_Turnover,
    CASE 
        WHEN SUM(sod.OrderQty) / NULLIF(AVG(pi.Quantity), 0) > 5 THEN 'High Turnover'
        WHEN SUM(sod.OrderQty) / NULLIF(AVG(pi.Quantity), 0) > 2 THEN 'Medium Turnover'
        ELSE 'Low Turnover'
    END AS Turnover_Rating
FROM sales_salesorderdetail sod
JOIN production_product p ON sod.ProductID = p.ProductID
JOIN production_productsubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN production_productcategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
JOIN production_productinventory pi ON p.ProductID = pi.ProductID
GROUP BY pc.ProductCategoryID, pc.Name
ORDER BY Inventory_Turnover DESC;

Q15 — Executive KPI Summary
SELECT 
    ROUND(SUM(TotalDue), 2) AS Total_Revenue,
    COUNT(SalesOrderID) AS Total_Orders,
    COUNT(DISTINCT CustomerID) AS Unique_Customers,
    ROUND(AVG(TotalDue), 2) AS Avg_Order_Value,
    ROUND(SUM(TotalDue) / COUNT(DISTINCT CustomerID), 2) AS Revenue_Per_Customer,
    ROUND(SUM(TotalDue) / COUNT(DISTINCT YEAR(OrderDate)), 2) AS Avg_Annual_Revenue,
    MIN(OrderDate) AS Data_From,
    MAX(OrderDate) AS Data_To
FROM sales_salesorderheader;