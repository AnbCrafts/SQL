-- 1. Create the Expenses Table
CREATE TABLE Expenses (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeName NVARCHAR(100) NOT NULL,
    Category NVARCHAR(50) NOT NULL,
    Amount DECIMAL(10, 2) NOT NULL,
    ExpenseDate DATE NOT NULL,
    PaymentMethod NVARCHAR(50) NOT NULL,
    HasReceipt BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

-- 2. Insert Sample Records
INSERT INTO Expenses (EmployeeName, Category, Amount, ExpenseDate, PaymentMethod, HasReceipt)
VALUES 
('Alex Rivera', 'Travel', 450.00, DATEADD(DAY, -5, CAST(GETDATE() AS DATE)), 'Corporate Card', 1),
('Maria Chen', 'Software', 89.99, DATEADD(DAY, -3, CAST(GETDATE() AS DATE)), 'Personal Card', 1),
('John Doe', 'Meals', 35.50, DATEADD(DAY, -1, CAST(GETDATE() AS DATE)), 'Cash', 0),
('Sophia Patel', 'Office Supplies', 120.25, CAST(GETDATE() AS DATE), 'Corporate Card', 1),
('Liam Wilson', 'Travel', 275.00, CAST(GETDATE() AS DATE), 'Personal Card', 1);
GO

-- 3. Verify the records
SELECT * FROM Expenses;



-- 1. Create the Users Table
CREATE TABLE Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    Password NVARCHAR(100) NOT NULL, -- In production, use hashed passwords
    Role NVARCHAR(20) DEFAULT 'Employee', -- 'Employee' or 'Admin'
    CreatedAt DATETIME DEFAULT GETDATE()
);
GO

-- 2. Insert Sample Users
INSERT INTO Users (FullName, Email, Password, Role)
VALUES 
('Alex Rivera', 'alex@example.com', 'Alex@123', 'Employee'),
('Maria Chen', 'maria@example.com', 'Maria@123', 'Employee'),
('Admin User', 'admin@example.com', 'Admin@123', 'Admin');
GO

-- 3. Add UserId column to Expenses table (Foreign Key)
USE Practice;
GO

-- 1. Create the Users table inside Practice DB
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
BEGIN
    CREATE TABLE dbo.Users (
        UserId INT IDENTITY(1,1) PRIMARY KEY,
        FullName NVARCHAR(100) NOT NULL,
        Email NVARCHAR(100) NOT NULL UNIQUE,
        Password NVARCHAR(100) NOT NULL,
        Role NVARCHAR(20) DEFAULT 'Employee',
        CreatedAt DATETIME DEFAULT GETDATE()
    );

    -- Insert Sample Users
    INSERT INTO dbo.Users (FullName, Email, Password, Role)
    VALUES 
    ('Alex Rivera', 'alex@example.com', 'Alex@123', 'Employee'),
    ('Maria Chen', 'maria@example.com', 'Maria@123', 'Employee'),
    ('Admin User', 'admin@example.com', 'Admin@123', 'Admin');
END
GO

-- 2. Now add the Foreign Key constraint
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE name = 'FK_Expenses_Users')
BEGIN
    ALTER TABLE dbo.Expenses 
    ADD CONSTRAINT FK_Expenses_Users FOREIGN KEY (UserId) REFERENCES dbo.Users(UserId);
END
GO

-- 3. Verify both tables
SELECT * FROM dbo.Users;
SELECT * FROM dbo.Expenses;

-- 4. Check the results
SELECT * FROM Users;
SELECT * FROM Expenses;