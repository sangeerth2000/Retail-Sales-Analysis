-- Create database
CREATE DATABASE online_retail_db;
-- Use the database
USE online_retail_db;
-- create table
CREATE TABLE online_retail (
    -- Primary transaction identifiers
    Invoice VARCHAR(20) NOT NULL,
    StockCode VARCHAR(20) NOT NULL,
    Description VARCHAR(500),
    
    -- Transaction details
    Quantity INT NOT NULL,
    InvoiceDate DATETIME NOT NULL,
    Price DECIMAL(10, 2) NOT NULL,
    
    -- Customer information
    CustomerID INT,
    Country VARCHAR(100) NOT NULL,
    
    -- Calculated fields
    TransactionType VARCHAR(10),
    TotalAmount DECIMAL(10, 2),
    Year INT,
    Month INT,
    Day INT,
    SELECT @@hostname;
    -- Add auto-increment ID for unique row identification
    id INT AUTO_INCREMENT PRIMARY KEY
);
-- describe table(field/type)
describe online_retail;

     -- 1st loading data 
     
  LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/online_retail_cleaning 2009-2010.csv'
INTO TABLE online_retail
CHARACTER SET latin1
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Invoice, StockCode, Description, Quantity, TransactionType, InvoiceDate, Price, CustomerID, Country, TotalAmount, Year, Month, Day);

    -- 2nd sheet loaded data

 LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/online_retail_cleaning 2010-2011.csv'
INTO TABLE online_retail
CHARACTER SET latin1
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Invoice, StockCode, Description, Quantity, TransactionType, InvoiceDate, Price, CustomerID, Country, TotalAmount, Year, Month, Day);
--  count the rows

SELECT COUNT(*) as total_rows FROM online_retail;
select * from online_retail limit 10;

-- Check date range

SELECT 
    MIN(InvoiceDate) as earliest_date,
    MAX(InvoiceDate) as latest_date
FROM online_retail;
-- Check for data from all years
SELECT Year, COUNT(*) as transaction_count
FROM online_retail
GROUP BY Year
ORDER BY Year;

-- Find duplicate transactions (same invoice + stockcode + quantity + date)

SELECT 
    Invoice, 
    StockCode, 
    Quantity, 
    InvoiceDate, 
    COUNT(*) as duplicate_count
FROM online_retail
GROUP BY Invoice, StockCode, Quantity, InvoiceDate
HAVING COUNT(*) > 1
ORDER BY duplicate_count DESC;
-- Count total duplicates
SELECT COUNT(*) as total_duplicates
FROM (
    SELECT Invoice, StockCode, Description, Quantity, InvoiceDate, Price, CustomerID, Country, TransactionType, TotalAmount, Year, Month, Day
    FROM online_retail
    GROUP BY Invoice, StockCode, Description, Quantity, InvoiceDate, Price, CustomerID, Country, TransactionType, TotalAmount, Year, Month, Day
    HAVING COUNT(*) > 1
) as duplicates;
-- Create a new table with only unique records
CREATE TABLE online_retail_clean AS
SELECT DISTINCT Invoice, StockCode, Description, Quantity, InvoiceDate, Price, CustomerID, Country, TransactionType,
                 TotalAmount, Year, Month, Day
FROM online_retail;

-- Drop old table and rename new one
DROP TABLE online_retail;
ALTER TABLE online_retail_clean RENAME TO online_retail;
Describe online_retail;
-- The difference is your actual duplicate rows
SELECT 
    COUNT(*) as total_rows,
    COUNT(DISTINCT Invoice, StockCode, Description, Quantity, InvoiceDate, Price, CustomerID, Country, TransactionType, TotalAmount, Year, Month, Day) as unique_rows,
    COUNT(*) - COUNT(DISTINCT Invoice, StockCode, Description, Quantity, InvoiceDate, Price, CustomerID, Country, TransactionType, TotalAmount, Year, Month, Day) as actual_duplicate_rows
FROM online_retail;

-- Check for NULL values in critical columns
SELECT 
    'Invoice' as column_name,
    SUM(CASE WHEN Invoice IS NULL THEN 1 ELSE 0 END) as null_count
FROM online_retail

UNION ALL

SELECT 
    'StockCode',
    SUM(CASE WHEN StockCode IS NULL THEN 1 ELSE 0 END)
FROM online_retail

UNION ALL

SELECT 
    'Quantity',
    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END)
FROM online_retail

UNION ALL

SELECT 
    'InvoiceDate',
    SUM(CASE WHEN InvoiceDate IS NULL THEN 1 ELSE 0 END)
FROM online_retail

UNION ALL

SELECT 
    'Price',
    SUM(CASE WHEN Price IS NULL THEN 1 ELSE 0 END)
FROM online_retail

UNION ALL

SELECT 
    'CustomerID',
    SUM(CASE WHEN CustomerID IS NULL THEN 1 ELSE 0 END)
FROM online_retail

UNION ALL

SELECT 
    'Country',
    SUM(CASE WHEN Country IS NULL THEN 1 ELSE 0 END)
FROM online_retail;
-- Check for invalid prices (negative or zero)
SELECT COUNT(*) as invalid_prices
FROM online_retail
WHERE Price <= 0;
-- Check quantity range
SELECT 
    MIN(Quantity) as min_qty,
    MAX(Quantity) as max_qty,
    AVG(Quantity) as avg_qty
FROM online_retail;
-- Find unusually large quantities
SELECT Invoice, StockCode, Description, Quantity, Price
FROM online_retail
WHERE ABS(Quantity) > 10000
ORDER BY ABS(Quantity) DESC
LIMIT 20;
-- Find unusually high prices
SELECT Invoice, StockCode, Description, Quantity, Price
FROM online_retail
WHERE Price > 1000
ORDER BY Price DESC
LIMIT 20;
-- Check if TotalAmount = Quantity * Price
SELECT 
    Invoice,
    StockCode,
    Quantity,
    Price,
    TotalAmount,
    (Quantity * Price) as calculated_amount,
    (TotalAmount - (Quantity * Price)) as difference
FROM online_retail
WHERE ABS(TotalAmount - (Quantity * Price)) > 0.01
LIMIT 20;
UPDATE online_retail
SET TotalAmount = Quantity * Price;

-- Verify Year, Month, Day columns

SELECT 
    InvoiceDate,
    Year,
    Month,
    Day,
    YEAR(InvoiceDate) as correct_year,
    MONTH(InvoiceDate) as correct_month,
    DAY(InvoiceDate) as correct_day
FROM online_retail
WHERE Year != YEAR(InvoiceDate) 
   OR Month != MONTH(InvoiceDate)
   OR Day != DAY(InvoiceDate)
LIMIT 20;
-- rechanged the year
UPDATE online_retail
SET 
    Year = YEAR(InvoiceDate),
    Month = MONTH(InvoiceDate),
    Day = DAY(InvoiceDate)
WHERE Year != YEAR(InvoiceDate)
   OR Month != MONTH(InvoiceDate)
   OR Day != DAY(InvoiceDate);
   -- Check TransactionType logic
-- All negative quantities should be RETURN
SELECT COUNT(*) as incorrect_returns
FROM online_retail
WHERE Quantity < 0 AND TransactionType != 'Return';
-- All positive quantities should be SALE
SELECT COUNT(*) as incorrect_sales
FROM online_retail
WHERE Quantity > 0 AND TransactionType != 'SALE';

-- Index on Invoice (for invoice-level analysis)
CREATE INDEX idx_invoice ON online_retail(Invoice);

-- Index on CustomerID (for customer analysis)
CREATE INDEX idx_customer ON online_retail(CustomerID);

-- Index on InvoiceDate (for time-series analysis)
CREATE INDEX idx_date ON online_retail(InvoiceDate);

-- Index on Country (for geographic analysis)
CREATE INDEX idx_country ON online_retail(Country);

-- Index on StockCode (for product analysis)
CREATE INDEX idx_stockcode ON online_retail(StockCode);

-- Composite index for common queries
CREATE INDEX idx_date_country ON online_retail(InvoiceDate, Country);
SHOW INDEX FROM online_retail;
-- Overall summary
SELECT 
    COUNT(*) as total_transactions,
    COUNT(DISTINCT Invoice) as total_invoices,
    COUNT(DISTINCT CustomerID) as total_customers,
    COUNT(DISTINCT StockCode) as total_products,
    COUNT(DISTINCT Country) as total_countries,
    MIN(InvoiceDate) as first_transaction,
    MAX(InvoiceDate) as last_transaction
FROM online_retail;

-- Transaction type breakdown
SELECT 
    TransactionType,
    COUNT(*) as transaction_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM online_retail), 2) as percentage
FROM online_retail
GROUP BY TransactionType;
-- Sales summary
SELECT 
    SUM(CASE WHEN TransactionType = 'SALE' THEN TotalAmount ELSE 0 END) as total_sales,
    SUM(CASE WHEN TransactionType = 'RETURN' THEN TotalAmount ELSE 0 END) as total_returns,
    SUM(TotalAmount) as net_revenue
FROM online_retail;
-- Top 10 customers by revenue
SELECT 
    CustomerID,
    COUNT(*) as total_transactions,
    SUM(TotalAmount) as total_spent,
    AVG(TotalAmount) as avg_transaction_value
FROM online_retail
WHERE CustomerID != 0  -- Exclude guests
GROUP BY CustomerID
ORDER BY total_spent DESC
LIMIT 10;
-- Top 10 products by quantity sold
SELECT 
    StockCode,
    Description,
    SUM(CASE WHEN TransactionType = 'SALE' THEN Quantity ELSE 0 END) as total_sold,
    SUM(CASE WHEN TransactionType = 'RETURN' THEN ABS(Quantity) ELSE 0 END) as total_returned,
    SUM(CASE WHEN TransactionType = 'SALE' THEN TotalAmount ELSE 0 END) as revenue
FROM online_retail
GROUP BY StockCode, Description
ORDER BY total_sold DESC
LIMIT 10;
-- Top 10 products by quantity sold
SELECT 
    StockCode,
    Description,
    SUM(CASE WHEN TransactionType = 'SALE' THEN Quantity ELSE 0 END) as total_sold,
    SUM(CASE WHEN TransactionType = 'RETURN' THEN ABS(Quantity) ELSE 0 END) as total_returned,
    SUM(CASE WHEN TransactionType = 'SALE' THEN TotalAmount ELSE 0 END) as revenue
FROM online_retail
GROUP BY StockCode, Description
ORDER BY total_sold DESC
LIMIT 10;
-- Sales by country
SELECT 
    Country,
    COUNT(*) as transactions,
    COUNT(DISTINCT CustomerID) as customers,
    SUM(CASE WHEN TransactionType = 'SALE' THEN TotalAmount ELSE 0 END) as revenue
FROM online_retail
GROUP BY Country
ORDER BY revenue DESC;
-- Monthly sales trend
SELECT 
    Year,
    Month,
    COUNT(*) as transactions,
    SUM(CASE WHEN TransactionType = 'SALE' THEN TotalAmount ELSE 0 END) as monthly_revenue,
    COUNT(DISTINCT CustomerID) as active_customers
FROM online_retail
GROUP BY Year, Month
ORDER BY Year, Month;


-- Customer segmentation by purchase frequency
SELECT 
    purchase_frequency,
    COUNT(*) as customer_count
FROM (
    SELECT 
        CustomerID,
        COUNT(DISTINCT Invoice) as purchase_frequency
    FROM online_retail
    WHERE CustomerID != 0
    GROUP BY CustomerID
) as customer_freq
GROUP BY purchase_frequency
ORDER BY purchase_frequency;

-- View 1: Sales only (exclude returns)

CREATE VIEW sales_only AS
SELECT *
FROM online_retail
WHERE TransactionType = 'SALE';
-- return view

CREATE VIEW returns_only AS
SELECT * 
FROM online_retail
WHERE TransactionType = 'RETURN' OR Quantity < 0;

-- View 2: Monthly summary

CREATE VIEW monthly_summary AS
SELECT 
    Year,
    Month,
    COUNT(*) as total_transactions,
    SUM(TotalAmount) as revenue,
    COUNT(DISTINCT CustomerID) as unique_customers,
    COUNT(DISTINCT StockCode) as unique_products
FROM online_retail
WHERE TransactionType = 'SALE'
GROUP BY Year, Month;

-- View 3: Customer summary
CREATE OR REPLACE VIEW customer_summary AS
SELECT 
    CustomerID,
    MIN(InvoiceDate) as first_purchase,
    MAX(InvoiceDate) as last_purchase,
    COUNT(DISTINCT Invoice) as total_orders,
    COUNT(*) as total_transactions,
    DATEDIFF(MAX(InvoiceDate), MIN(InvoiceDate)) as customer_lifetime_days,
    SUM(CASE WHEN TransactionType = 'SALE' THEN TotalAmount ELSE 0 END) as total_spent,
    AVG(CASE WHEN TransactionType = 'SALE' THEN TotalAmount ELSE 0 END) as avg_transaction_value
FROM online_retail
WHERE CustomerID != 0
GROUP BY CustomerID;


-- product performance view

CREATE VIEW product_performance AS
SELECT 
    StockCode,
    MAX(Description) as description,
    COUNT(*) as total_transactions,
    SUM(CASE WHEN TransactionType = 'SALE' THEN Quantity ELSE 0 END) as units_sold,
    SUM(CASE WHEN TransactionType = 'RETURN' THEN ABS(Quantity) ELSE 0 END) as units_returned,
    SUM(CASE WHEN TransactionType = 'SALE' THEN TotalAmount ELSE 0 END) as total_revenue,
    AVG(Price) as avg_price,
    COUNT(DISTINCT CustomerID) as unique_customers
FROM online_retail
GROUP BY StockCode;

-- Query the view instead of the table

SELECT * FROM monthly_summary ORDER BY Year, Month;

-- Return trend
SELECT 
    Year,
    Month,
    SUM(CASE WHEN TransactionType = 'SALE' THEN Quantity ELSE 0 END) as units_sold,
    SUM(CASE WHEN TransactionType = 'RETURN' THEN ABS(Quantity) ELSE 0 END) as units_returned,
    ROUND(SUM(CASE WHEN TransactionType = 'RETURN' THEN ABS(Quantity) ELSE 0 END) * 100.0 / 
          NULLIF(SUM(CASE WHEN TransactionType = 'SALE' THEN Quantity ELSE 0 END), 0), 2) as return_rate_percentage
FROM online_retail
GROUP BY Year, Month
ORDER BY Year, Month;
 
 -- customer segmentation
 
SELECT 
    CASE 
        WHEN total_orders >= 10 THEN 'VIP'
        WHEN total_orders >= 5 THEN 'Regular'
        WHEN total_orders >= 2 THEN 'Occasional'
        ELSE 'One-time'
    END as customer_segment,
    COUNT(*) as customer_count,
    AVG(Total_Spent) as avg_revenue_per_customer,
    SUM(Total_Spent) as total_segment_revenue
FROM customer_summary
GROUP BY customer_segment
ORDER BY avg_revenue_per_customer DESC


-- Final Data Quality Report

SELECT 'Total Records' as Metric,
    COUNT(*) as Value
FROM online_retail

UNION ALL

SELECT 
    'Unique Invoices',
    COUNT(DISTINCT Invoice)
FROM online_retail

UNION ALL

SELECT 
    'Unique Customers',
    COUNT(DISTINCT CustomerID)
FROM online_retail
WHERE CustomerID != 0

UNION ALL

SELECT 
    'Guest Purchases',
    COUNT(*)
FROM online_retail
WHERE CustomerID = 0

UNION ALL

SELECT 
    'Unique Products',
    COUNT(DISTINCT StockCode)
FROM online_retail

UNION ALL

SELECT 
    'Unique Countries',
    COUNT(DISTINCT Country)
FROM online_retail

UNION ALL

SELECT 
    'Total Sales Transactions',
    COUNT(*)
FROM online_retail
WHERE TransactionType = 'SALE'

UNION ALL

SELECT 
    'Total Return Transactions',
    COUNT(*)
FROM online_retail
WHERE TransactionType = 'RETURN'

UNION ALL

SELECT 
    'Date Range (Days)',
    DATEDIFF(MAX(InvoiceDate), MIN(InvoiceDate))
FROM online_retail

UNION ALL

SELECT 
    'Total Revenue',
    ROUND(SUM(CASE WHEN TransactionType = 'SALE' THEN TotalAmount ELSE 0 END), 2)
FROM online_retail

UNION ALL

SELECT 
    'Total Returns Value',
    ROUND(SUM(CASE WHEN TransactionType = 'RETURN' THEN ABS(TotalAmount) ELSE 0 END), 2)
FROM online_retail

UNION ALL

SELECT 
    'Net Revenue',
    ROUND(SUM(TotalAmount), 2)
FROM online_retail;
show full tables from online_retail_db where table_type='VIEW'
use online_retail_db
SELECT StockCode, COUNT(*) AS CountRows
FROM online_retail
GROUP BY StockCode
HAVING COUNT(*) > 1;


CREATE TABLE Dim_Product AS
SELECT
    StockCode,
    MIN(Description) AS Description
FROM online_retail
WHERE StockCode IS NOT NULL
GROUP BY StockCode;
SELECT * FROM Dim_Product LIMIT 10;


SELECT StockCode, COUNT(*)
FROM Dim_Product
GROUP BY StockCode
HAVING COUNT(*) > 1;

SELECT StockCode, COUNT(*) AS cnt
FROM Dim_Product
GROUP BY StockCode
HAVING COUNT(*) > 1;

SELECT
    CONCAT('|', StockCode, '|') AS VisibleValue,
    LENGTH(StockCode) AS Len
FROM Dim_Product
WHERE StockCode LIKE '%47503%';

DROP TABLE IF EXISTS Dim_Product;

CREATE TABLE Dim_Product AS
SELECT
    TRIM(StockCode) AS StockCode,
    MIN(Description) AS Description
FROM online_retail
WHERE StockCode IS NOT NULL
GROUP BY TRIM(StockCode);


SELECT StockCode, COUNT(*)
FROM Dim_Product
GROUP BY StockCode
HAVING COUNT(*) > 1;








