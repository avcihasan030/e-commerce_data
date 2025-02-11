-- Data Analysis for E-commerce Transactions

-- Step 1: Preview the cleaned dataset
SELECT * FROM transactions_temp;

-- Step 2: Calculate Total Revenue
SELECT SUM(Quantity * UnitPrice) AS total_revenue FROM transactions_temp;

-- Step 3: Identify Top-Selling Products
SELECT Description, SUM(Quantity) AS TotalQuantitySold
FROM transactions_temp
GROUP BY Description
ORDER BY TotalQuantitySold DESC
LIMIT 10;

-- Step 4: Identify Most Valuable Customers
SELECT CustomerID, SUM(Quantity * UnitPrice) as TotalSpent
FROM transactions_temp
GROUP BY CustomerID
ORDER BY TotalSpent DESC
LIMIT 10;

-- Step 5: Analyze Sales by Country
-- Top 10 Countries by Sales
SELECT Country, SUM(Quantity * UnitPrice) AS TotalSales
FROM transactions_temp
GROUP BY Country
ORDER BY TotalSales DESC
LIMIT 10;

-- Bottom 10 Countries by Sales
SELECT Country, SUM(Quantity * UnitPrice) AS TotalSales
FROM transactions_temp
GROUP BY Country
ORDER BY TotalSales ASC
LIMIT 10;

-- Step 6: Analyze Monthly Sales Trends
SELECT DATE_FORMAT(InvoiceDate, '%Y-%m') AS Month, SUM(Quantity * UnitPrice) AS MonthlySales
FROM transactions_temp
GROUP BY Month
ORDER BY Month;

-- Step 7: Perform Customer Segmentation using RFM Analysis
WITH RFM AS (
    SELECT CustomerID,
           DATEDIFF('2011-12-09', MAX(InvoiceDate)) AS Recency,
           COUNT(DISTINCT InvoiceNo) AS Frequency,
           SUM(Quantity * UnitPrice) AS Monetary
    FROM transactions_temp
    GROUP BY CustomerID
)
SELECT CustomerID,
       Recency,
       Frequency,
       Monetary,
       NTILE(4) OVER (ORDER BY Recency DESC) AS R_Score,
       NTILE(4) OVER (ORDER BY Frequency) AS F_Score,
       NTILE(4) OVER (ORDER BY Monetary) AS M_Score,
       CONCAT(NTILE(4) OVER (ORDER BY Recency DESC),
              NTILE(4) OVER (ORDER BY Frequency),
              NTILE(4) OVER (ORDER BY Monetary)) AS RFM_Score
FROM RFM
ORDER BY RFM_Score;
