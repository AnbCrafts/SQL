-- =====================================================================
-- SQL SERVER PRACTICE - DAY 4: AGGREGATE FUNCTIONS & SET OPERATORS
-- Domain: Retail Store - Products, Orders, & Customer Locations
-- =====================================================================

-- ---------------------------------------------------------------------
-- STEP 1: CREATE TABLES
-- ---------------------------------------------------------------------

-- Cleanup existing demo tables if any
DROP TABLE IF EXISTS StoreOrders;
DROP TABLE IF EXISTS StoreProducts;
DROP TABLE IF EXISTS OnlineCustomers;
DROP TABLE IF EXISTS StoreStaff;

-- 1. StoreProducts Table
CREATE TABLE StoreProducts (
    ProductId INT PRIMARY KEY IDENTITY(1,1),
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    StockQuantity INT NOT NULL
);

-- 2. StoreOrders Table
CREATE TABLE StoreOrders (
    OrderId INT PRIMARY KEY IDENTITY(5001,1),
    ProductId INT FOREIGN KEY REFERENCES StoreProducts(ProductId),
    QuantitySold INT NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL,
    OrderDate DATE NOT NULL,
    City VARCHAR(50) NOT NULL
);

-- 3. OnlineCustomers Table (For SET Operators)
CREATE TABLE OnlineCustomers (
    CustomerId INT PRIMARY KEY IDENTITY(1,1),
    FullName VARCHAR(100) NOT NULL,
    City VARCHAR(50) NOT NULL
);

-- 4. StoreStaff Table (For SET Operators)
CREATE TABLE StoreStaff (
    StaffId INT PRIMARY KEY IDENTITY(1,1),
    FullName VARCHAR(100) NOT NULL,
    City VARCHAR(50) NOT NULL
);


-- ---------------------------------------------------------------------
-- STEP 2: INSERT SAMPLE DATA
-- ---------------------------------------------------------------------

-- Insert Store Products
INSERT INTO StoreProducts (ProductName, Category, Price, StockQuantity) VALUES
('Wireless Mouse', 'Electronics', 800.00, 50),     -- ProductId 1
('Mechanical Keyboard', 'Electronics', 3500.00, 20),-- ProductId 2
('Gaming Monitor', 'Electronics', 15000.00, 10),   -- ProductId 3
('Ergonomic Chair', 'Furniture', 12000.00, 15),    -- ProductId 4
('Standing Desk', 'Furniture', 22000.00, 5),       -- ProductId 5
('USB-C Cable', 'Accessories', 300.00, 100),       -- ProductId 6
('Laptop Stand', 'Accessories', 1200.00, 30);      -- ProductId 7

-- Insert Store Orders
INSERT INTO StoreOrders (ProductId, QuantitySold, TotalAmount, OrderDate, City) VALUES
(1, 5, 4000.00, '2026-09-01', 'Mumbai'),
(1, 2, 1600.00, '2026-09-03', 'Delhi'),
(2, 3, 10500.00, '2026-09-05', 'Mumbai'),
(3, 1, 15000.00, '2026-09-10', 'Bangalore'),
(4, 2, 24000.00, '2026-09-12', 'Delhi'),
(4, 1, 12000.00, '2026-09-15', 'Mumbai'),
(6, 10, 3000.00, '2026-09-18', 'Bangalore'),
(7, 4, 4800.00, '2026-09-20', 'Delhi');

-- Insert Online Customers
INSERT INTO OnlineCustomers (FullName, City) VALUES
('Aarav Sharma', 'Mumbai'),
('Ananya Roy', 'Delhi'),
('Rohan Verma', 'Bangalore'),
('Priya Nair', 'Chennai'),
('Karan Patel', 'Mumbai');

-- Insert Store Staff
INSERT INTO StoreStaff (FullName, City) VALUES
('Aarav Sharma', 'Mumbai'),     -- Duplicate name & city (Customer + Staff)
('Ananya Roy', 'Delhi'),       -- Duplicate name & city (Customer + Staff)
('Vikram Singh', 'Kolkata'),
('Sanya Gupta', 'Hyderabad');


-- ---------------------------------------------------------------------
-- STEP 3: DEMO QUERIES FOR AGGREGATES & SET OPERATORS
-- ---------------------------------------------------------------------

-- 1. Basic Aggregate Functions (COUNT, SUM, AVG, MIN, MAX)
SELECT 
    COUNT(*) AS TotalProducts,
    SUM(StockQuantity) AS TotalStock,
    AVG(Price) AS AveragePrice,
    MIN(Price) AS CheapestPrice,
    MAX(Price) AS MostExpensivePrice
FROM StoreProducts;

-- 2. GROUP BY Clause
SELECT 
    Category,
    COUNT(ProductId) AS NumberOfProducts,
    AVG(Price) AS AverageCategoryPrice
FROM StoreProducts
GROUP BY Category;

-- 3. HAVING Clause (Filter aggregated groups)
-- Note: Must repeat aggregate expression in HAVING (cannot use column alias!)
SELECT 
    Category,
    AVG(Price) AS AvgPrice
FROM StoreProducts
GROUP BY Category
HAVING AVG(Price) > 1000;

-- 4. UNION (Combines results & removes duplicate rows)
SELECT FullName, City FROM OnlineCustomers
UNION
SELECT FullName, City FROM StoreStaff;

-- 5. UNION ALL (Combines results & retains duplicates - faster!)
SELECT FullName, City FROM OnlineCustomers
UNION ALL
SELECT FullName, City FROM StoreStaff;

-- 6. EXCEPT (Rows in 1st query NOT in 2nd query: Customers who are NOT Staff)
SELECT FullName, City FROM OnlineCustomers
EXCEPT
SELECT FullName, City FROM StoreStaff;

-- 7. INTERSECT (Rows common to BOTH queries: People who are BOTH Customers and Staff)
SELECT FullName, City FROM OnlineCustomers
INTERSECT
SELECT FullName, City FROM StoreStaff;


-- ---------------------------------------------------------------------
-- STEP 4: PRACTICE QUESTIONS FOR DAY 4
-- ---------------------------------------------------------------------


-- Q1. Write a query to find the total quantity sold (SUM) and total sales revenue (SUM) grouped by City from StoreOrders.

select s.City, sum(s.QuantitySold) as totalQuant, sum(s.TotalAmount) as totalAmount from StoreOrders as s group by s.City order by s.City

-- Q2. Write a query to find the Category and the maximum price (MAX) in each category, but ONLY show categories where the maximum price is greater than 5000 (Use HAVING).

select s.Category, MAX(s.Price) from StoreProducts as s group by s.Category having MAX(s.Price) >5000 order by s.Category

-- Q3. Write a query using UNION ALL to list all cities from OnlineCustomers and all cities from StoreStaff. Order the result by City.

select o.City from OnlineCustomers as o
union all 
select s.City from StoreStaff as s 


-- Q4. Write a query using EXCEPT to find all cities present in OnlineCustomers that are NOT present in StoreStaff.


select o.City from OnlineCustomers as o
except
select s.City from StoreStaff as s 

-- Q5. Write a query using INTERSECT to find all cities that are common to BOTH OnlineCustomers and StoreOrders.

select o.City from OnlineCustomers as o
intersect
select s.City from StoreStaff as s 


