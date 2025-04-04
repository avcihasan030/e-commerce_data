-- Data Cleaning for E-commerce Transactions

-- Step 1: Preview the first 100 rows of the dataset
SELECT *
FROM transactions
LIMIT 100;

-- Step 2: Detect duplicate rows using ROW_NUMBER()
WITH detectDuplicateCTE AS (
    SELECT *,
           ROW_NUMBER() OVER (
               PARTITION BY InvoiceNo, StockCode, Description, Quantity,
                   InvoiceDate, UnitPrice, CustomerID, Country
               ) AS row_num
    FROM transactions
)
SELECT *
FROM detectDuplicateCTE
WHERE row_num > 1;

-- Step 3: Create a temporary table to store cleaned data
CREATE TABLE transactions_temp AS
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY InvoiceNo, StockCode, Description, Quantity,
               InvoiceDate, UnitPrice, CustomerID, Country
           ) AS row_num
FROM transactions;

-- Step 4: Identify duplicate rows in the temporary table
SELECT *
FROM transactions_temp
WHERE row_num > 1;

-- Step 5: Remove duplicate rows
DELETE FROM transactions_temp
WHERE row_num > 1;

-- Step 6: Verify that duplicates have been removed
SELECT COUNT(*)
FROM transactions_temp;

-- Step 7: Check for NULL values in critical columns
SELECT * FROM transactions_temp WHERE UnitPrice IS NULL OR Quantity IS NULL;
SELECT * FROM transactions_temp WHERE Country IS NULL;
SELECT * FROM transactions_temp WHERE InvoiceNo IS NULL AND CustomerID IS NULL;
SELECT * FROM transactions_temp2 WHERE InvoiceDate IS NULL;

-- Step 8: Standardizing Data
-- Ensuring consistency in key columns
SELECT DISTINCT InvoiceNo FROM transactions_temp ORDER BY InvoiceNo DESC;
SELECT DISTINCT StockCode FROM transactions_temp ORDER BY StockCode DESC;
SELECT DISTINCT Country FROM transactions_temp ORDER BY Country DESC;
SELECT DISTINCT CustomerID FROM transactions_temp ORDER BY CustomerID ASC;

-- Step 9: Standardize CustomerID format
UPDATE transactions_temp
SET CustomerID = SUBSTRING(CustomerID, 1, 5)
WHERE CustomerID IS NOT NULL AND CustomerID <> 'Nan';

-- Step 10: Remove invalid CustomerID values ('Nan')
DELETE FROM transactions_temp WHERE CustomerID = 'Nan';

-- Step 11: Remove the row_num column as it's no longer needed
ALTER TABLE transactions_temp DROP COLUMN row_num;

-- Final Step: Preview the cleaned dataset
SELECT * FROM transactions_temp;
