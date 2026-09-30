-- =====================================================================
-- SQL SERVER PRACTICE - DAY 8: CASE STATEMENTS & WHILE LOOPS
-- Domain: E-Commerce Orders & Inventory Processing
-- =====================================================================

-- ---------------------------------------------------------------------
-- STEP 1: CREATE TABLES
-- ---------------------------------------------------------------------

-- Cleanup existing demo objects if any
DROP TABLE IF EXISTS CustomerOrders;
DROP TABLE IF EXISTS ProductInventory;
DROP TABLE IF EXISTS DailySalesReport;

-- 1. CustomerOrders Table
CREATE TABLE CustomerOrders (
    OrderId INT PRIMARY KEY IDENTITY(1001,1),
    CustomerName VARCHAR(100) NOT NULL,
    OrderTotal DECIMAL(10,2) NOT NULL,
    OrderStatus INT NOT NULL, -- 1: Pending, 2: Processing, 3: Shipped, 4: Delivered, 5: Cancelled
    OrderDate DATE NOT NULL
);

-- 2. ProductInventory Table
CREATE TABLE ProductInventory (
    ProductId INT PRIMARY KEY IDENTITY(1,1),
    ProductName VARCHAR(100) NOT NULL,
    StockQuantity INT NOT NULL,
    ReorderLevel INT NOT NULL
);

-- 3. DailySalesReport Table (For Loop Insert Demo)
CREATE TABLE DailySalesReport (
    ReportId INT PRIMARY KEY IDENTITY(1,1),
    ReportDate DATE NOT NULL,
    TotalOrders INT NOT NULL,
    TotalRevenue DECIMAL(12,2) NOT NULL
);


-- ---------------------------------------------------------------------
-- STEP 2: INSERT SAMPLE DATA
-- ---------------------------------------------------------------------

-- Insert Customer Orders
INSERT INTO CustomerOrders (CustomerName, OrderTotal, OrderStatus, OrderDate) VALUES
('Rahul Sharma', 450.00, 1, '2026-09-01'),   -- 1: Pending
('Anita Verma', 1200.00, 2, '2026-09-01'),   -- 2: Processing
('Vikram Patel', 5500.00, 3, '2026-09-02'),  -- 3: Shipped
('Sonia Kapoor', 15000.00, 4, '2026-09-02'), -- 4: Delivered
('Amit Kumar', 250.00, 5, '2026-09-03'),     -- 5: Cancelled
('Neha Gupta', 8500.00, 4, '2026-09-03'),    -- 4: Delivered
('Karan Singh', 11000.00, 1, '2026-09-04');  -- 1: Pending

-- Insert Product Inventory
INSERT INTO ProductInventory (ProductName, StockQuantity, ReorderLevel) VALUES
('Gaming Laptop', 8, 10),
('USB Mouse', 45, 15),
('HD Monitor', 12, 10),
('Wireless Earbuds', 3, 5),
('Mechanical Keyboard', 25, 10);


-- ---------------------------------------------------------------------
-- STEP 3: DEMO EXAMPLES FOR CASE & WHILE LOOPS
-- ---------------------------------------------------------------------

-- 1. Simple CASE Expression (Translating numeric OrderStatus to text)
SELECT 
    OrderId,
    CustomerName,
    OrderTotal,
    CASE OrderStatus
        WHEN 1 THEN 'Pending'
        WHEN 2 THEN 'Processing'
        WHEN 3 THEN 'Shipped'
        WHEN 4 THEN 'Delivered'
        WHEN 5 THEN 'Cancelled'
        ELSE 'Unknown'
    END AS OrderStatusText
FROM CustomerOrders;

-- 2. Searched CASE Expression (Categorizing Order Priority based on OrderTotal)
SELECT 
    OrderId,
    CustomerName,
    OrderTotal,
    CASE 
        WHEN OrderTotal < 500 THEN 'Low Value'
        WHEN OrderTotal >= 500 AND OrderTotal < 5000 THEN 'Medium Value'
        WHEN OrderTotal >= 5000 AND OrderTotal < 10000 THEN 'High Value'
        ELSE 'VIP Platinum'
    END AS PriorityCategory
FROM CustomerOrders;

-- 3. CASE inside Aggregate Functions (Pivot-like counts in 1 row)
SELECT 
    COUNT(*) AS TotalOrders,
    SUM(CASE WHEN OrderStatus = 1 THEN 1 ELSE 0 END) AS PendingOrders,
    SUM(CASE WHEN OrderStatus = 2 THEN 1 ELSE 0 END) AS ProcessingOrders,
    SUM(CASE WHEN OrderStatus = 3 THEN 1 ELSE 0 END) AS ShippedOrders,
    SUM(CASE WHEN OrderStatus = 4 THEN 1 ELSE 0 END) AS DeliveredOrders,
    SUM(CASE WHEN OrderStatus = 5 THEN 1 ELSE 0 END) AS CancelledOrders
FROM CustomerOrders;

-- 4. Simple WHILE Loop (Counting from 1 to 5)
DECLARE @counter INT = 1;
WHILE @counter <= 5
BEGIN
    PRINT 'Loop Counter Value: ' + CAST(@counter AS VARCHAR);
    SET @counter = @counter + 1;
END;

-- 5. WHILE Loop to iterate through Table records row-by-row
DECLARE @currId INT, @maxId INT;
DECLARE @prodName VARCHAR(100), @stock INT;

SELECT @currId = MIN(ProductId), @maxId = MAX(ProductId) FROM ProductInventory;

WHILE (@currId IS NOT NULL AND @currId <= @maxId)
BEGIN
    SELECT @prodName = ProductName, @stock = StockQuantity 
    FROM ProductInventory 
    WHERE ProductId = @currId;

    PRINT 'Product ID ' + CAST(@currId AS VARCHAR) + ': ' + @prodName + ' (Stock: ' + CAST(@stock AS VARCHAR) + ')';
    
    SET @currId = @currId + 1;
END;

-- 6. WHILE Loop with Dates (Generate 5 daily report dates)
DECLARE @startDate DATE = '2026-09-01';
DECLARE @endDate DATE = '2026-09-05';
DECLARE @currDate DATE = @startDate;

WHILE @currDate <= @endDate
BEGIN
    INSERT INTO DailySalesReport (ReportDate, TotalOrders, TotalRevenue)
    VALUES (@currDate, 10, 5000.00);

    SET @currDate = DATEADD(DAY, 1, @currDate);
END;

SELECT * FROM DailySalesReport;

-- 7. WHILE Loop with CONTINUE & BREAK
DECLARE @num INT = 0;
WHILE @num < 10
BEGIN
    SET @num = @num + 1;

    -- Skip printing when num is 5 (CONTINUE)
    IF @num = 5
        CONTINUE;

    -- Stop loop completely when num reaches 8 (BREAK)
    IF @num = 8
        BREAK;

    PRINT 'Number: ' + CAST(@num AS VARCHAR);
END;


-- ---------------------------------------------------------------------
-- STEP 4: PRACTICE QUESTIONS FOR DAY 8
-- ---------------------------------------------------------------------

/*
Q1. Simple CASE: Write a query on ProductInventory to display ProductId, ProductName, StockQuantity, ReorderLevel, and a column 'StockStatus' using a searched CASE statement:
    - If StockQuantity <= 5 -> 'Critical Low'
    - If StockQuantity <= ReorderLevel -> 'Reorder Needed'
    - Else -> 'Sufficient Stock'

Q2. CASE in Aggregate: Write a query on CustomerOrders to compute:
    - Total Revenue for Delivered orders: SUM(CASE WHEN OrderStatus = 4 THEN OrderTotal ELSE 0 END)
    - Total Revenue for Pending/Processing orders: SUM(CASE WHEN OrderStatus IN (1, 2) THEN OrderTotal ELSE 0 END)

Q3. WHILE Loop: Write a WHILE loop to print even numbers from 2 to 20 on the console using PRINT.

Q4. WHILE Loop with BREAK: Write a WHILE loop starting from 1 to 50, but BREAK (terminate) the loop immediately if the loop counter reaches 13.

Q5. WHILE Loop over Table: Write a WHILE loop to iterate through CustomerOrders row-by-row (from MIN OrderId to MAX OrderId) and PRINT the CustomerName and OrderTotal for each order.
*/
