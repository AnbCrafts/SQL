-- 1. CREATE SCHEMA
CREATE SCHEMA practiceProjects;
GO

-- 2. Stores Table (Matches Store.cs)
CREATE TABLE practiceProjects.Stores (
    StoreId INT PRIMARY KEY IDENTITY(1,1),
    StoreName VARCHAR(100) NOT NULL,
    Location VARCHAR(100) NOT NULL,
    ContactNumber VARCHAR(20) NOT NULL
);

-- 3. Employees Table (Matches Employee.cs)
CREATE TABLE practiceProjects.Employees (
    EmployeeId INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(100) NOT NULL,
    Designation VARCHAR(50) NOT NULL,
    Salary DECIMAL(10,2) NOT NULL,
    Department VARCHAR(50) NOT NULL,
    StoreId INT NULL,
    CONSTRAINT FK_Employees_Stores FOREIGN KEY (StoreId) 
        REFERENCES practiceProjects.Stores(StoreId) ON DELETE SET NULL
);

-- 4. Customers Table (Matches Customer.cs)
CREATE TABLE practiceProjects.Customers (
    CustomerId INT PRIMARY KEY IDENTITY(1,1),
    Name VARCHAR(100) NOT NULL,
    Email VARCHAR(100) NOT NULL,
    Phone VARCHAR(20) NOT NULL,
    Address VARCHAR(200) NOT NULL,
    StoreId INT NULL,
    CONSTRAINT FK_Customers_Stores FOREIGN KEY (StoreId) 
        REFERENCES practiceProjects.Stores(StoreId) ON DELETE SET NULL
);

-- 5. Products Table (Matches Products.cs)
CREATE TABLE practiceProjects.Products (
    ProductId INT PRIMARY KEY IDENTITY(101,1),
    ProductName VARCHAR(100) NOT NULL,
    Category VARCHAR(50) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    StockQuantity INT NOT NULL DEFAULT 0,
    StoreId INT NULL,
    CONSTRAINT FK_Products_Stores FOREIGN KEY (StoreId) 
        REFERENCES practiceProjects.Stores(StoreId) ON DELETE SET NULL
);

-- 6. Orders Table (Matches Order.cs)
CREATE TABLE practiceProjects.Orders (
    OrderId INT PRIMARY KEY IDENTITY(5001,1),
    CustomerId INT NULL,
    StoreId INT NULL,
    OrderDate DATETIME NOT NULL DEFAULT GETDATE(),
    TotalAmount DECIMAL(10,2) NOT NULL,
    Status VARCHAR(50) NOT NULL DEFAULT 'Pending',
    CONSTRAINT FK_Orders_Customers FOREIGN KEY (CustomerId) 
        REFERENCES practiceProjects.Customers(CustomerId) ON DELETE SET NULL,
    CONSTRAINT FK_Orders_Stores FOREIGN KEY (StoreId) 
        REFERENCES practiceProjects.Stores(StoreId) ON DELETE SET NULL
);

-- 7. OrderProducts Junction Table (For Order.Products List relationship)
CREATE TABLE practiceProjects.OrderProducts (
    OrderId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    PRIMARY KEY (OrderId, ProductId),
    CONSTRAINT FK_OrderProducts_Orders FOREIGN KEY (OrderId) 
        REFERENCES practiceProjects.Orders(OrderId) ON DELETE CASCADE,
    CONSTRAINT FK_OrderProducts_Products FOREIGN KEY (ProductId) 
        REFERENCES practiceProjects.Products(ProductId) ON DELETE CASCADE
);
GO