--5. Create a stored procedure with input student ID, course ID and enrolment date  to enrol a student in multiple courses simultaneously while ensuring that all enrollments are successful or rolled back in case of any failure.
select * from labTest.student
-- ============================================
-- STUDENT TABLE
-- ============================================
CREATE TABLE labTest.Students
(
    studentId INT IDENTITY(1,1) PRIMARY KEY,
    firstName VARCHAR(50) NOT NULL,
    lastName VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phoneNo VARCHAR(15),
    dateOfBirth DATE,
    registrationDate DATE DEFAULT GETDATE()
);

-- ============================================
-- ENROLLMENT TABLE
-- ============================================
CREATE TABLE labTest.Enrollment
(
    enrollmentId INT IDENTITY(1,1) PRIMARY KEY,
    studentId INT NOT NULL,
    courseId INT NOT NULL,
    enrollmentDate DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'Active',

    CONSTRAINT FK_Enrollment_Student
        FOREIGN KEY(studentId)
        REFERENCES labTest.Students(studentId),

    CONSTRAINT FK_Enrollment_Course
        FOREIGN KEY(courseId)
        REFERENCES labTest.Course(courseId)
);

-- ============================================
-- SAMPLE STUDENT DATA
-- ============================================
INSERT INTO labTest.Students
(firstName,lastName,email,phoneNo,dateOfBirth,registrationDate)
VALUES
('Rahul','Sharma','rahul.sharma@gmail.com','9876543210','2000-05-12','2026-11-01'),
('Priya','Das','priya.das@gmail.com','9876543211','2001-03-17','2026-11-02'),
('Amit','Roy','amit.roy@gmail.com','9876543212','1999-07-20','2026-11-04'),
('Sneha','Sen','sneha.sen@gmail.com','9876543213','2002-01-15','2026-11-05'),
('Arjun','Mitra','arjun.mitra@gmail.com','9876543214','2001-09-09','2026-11-06');

-- ============================================
-- SAMPLE ENROLLMENT DATA
-- (Assumes courseId 1-5 already exist)
-- ============================================
INSERT INTO labTest.Enrollment
(studentId,courseId,enrollmentDate,status)
VALUES
(1,1,'2026-11-08','Active'),
(1,2,'2026-11-08','Active'),

(2,1,'2026-11-09','Active'),
(2,3,'2026-11-09','Active'),

(3,2,'2026-11-10','Completed'),
(3,4,'2026-11-10','Active'),

(4,1,'2026-11-11','Active'),
(4,5,'2026-11-11','Active'),

(5,3,'2026-11-12','Active'),
(5,4,'2026-11-12','Completed');

-- ============================================
-- VERIFY DATA
-- ============================================
select * from labTest.Enrollment



CREATE PROCEDURE RegisterStudentInCourse
(
    @studentId INT,
    @courseID INT,
    @joinDate DATE
)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY

        BEGIN TRANSACTION;

        
        IF @studentId IS NULL
            THROW 50001, 'Student ID cannot be NULL.', 1;

        IF @courseID IS NULL
            THROW 50002, 'Course ID cannot be NULL.', 1;

        
        IF NOT EXISTS
        (
            SELECT 1
            FROM labTest.Students
            WHERE studentId = @studentId
        )
            THROW 50003, 'Student not found with this ID.', 1;

        
        IF NOT EXISTS
        (
            SELECT 1
            FROM labTest.Course
            WHERE courseId = @courseID
        )
            THROW 50004, 'Course not found with this ID.', 1;

       
        IF EXISTS
        (
            SELECT 1
            FROM labTest.Enrollment
            WHERE studentId = @studentId
              AND courseId = @courseID
        )
            THROW 50005, 'Student is already enrolled in this course.', 1;

     
        INSERT INTO labTest.Enrollment
        (
            studentId,
            courseId,
            enrollmentDate
        )
        VALUES
        (
            @studentId,
            @courseID,
            @joinDate
        );

        IF @@ROWCOUNT = 0
            THROW 50006, 'Student enrollment failed.', 1;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;   

    END CATCH
END;
GO

--invalid course id
EXEC RegisterStudentInCourse
    @studentId = 1,
    @courseID = 101,
    @joinDate = '2026-11-19';


--invalid student id
EXEC RegisterStudentInCourse
    @studentId = 100,
    @courseID = 2,
    @joinDate = '2026-11-19';

-- duplicate enrollment

EXEC RegisterStudentInCourse
    @studentId = 1,
    @courseID = 1,
    @joinDate = '2026-11-19';

-- successful enrollment

EXEC RegisterStudentInCourse
    @studentId = 1,
    @courseID = 8,
    @joinDate = '2026-11-19';


	select * from labTest.Students
	select * from labTest.Enrollment
	select * from labTest.Course


--6


CREATE TABLE labTest.Client
(
    clientId INT PRIMARY KEY,
    clientName VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20)
);
GO
CREATE TABLE labTest.Stock
(
    stockId INT PRIMARY KEY,
    productName VARCHAR(100) NOT NULL,
    unitPrice DECIMAL(10,2) NOT NULL,
    quantityAvailable INT NOT NULL
);
GO

CREATE TABLE labTest.[Order]
(
    orderId INT IDENTITY(1,1) PRIMARY KEY,
    clientId INT NOT NULL,
    orderDate DATE NOT NULL,
    totalAmount DECIMAL(10,2) NOT NULL
);
GO
CREATE TABLE labTest.OrderItems
(
    orderItemId INT PRIMARY KEY,
    orderId INT NOT NULL,
    stockId INT NOT NULL,
    quantity INT NOT NULL,
    unitPrice DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (orderId) REFERENCES labTest.[Order](orderId),
    FOREIGN KEY (stockId) REFERENCES labTest.Stock(stockId)
);
GO
INSERT INTO labTest.Client
VALUES
(1,'ABC Technologies','abc@tech.com','9876543210'),
(2,'XYZ Solutions','xyz@solutions.com','9876543211'),
(3,'Global Systems','global@systems.com','9876543212');
GO
INSERT INTO labTest.Stock
VALUES
(1,'Laptop',55000.00,50),
(2,'Mouse',500.00,300),
(3,'Keyboard',1200.00,200),
(4,'Monitor',10000.00,100),
(5,'Printer',8000.00,25);
GO
INSERT INTO labTest.[Order]
VALUES
(101,1,'2026-11-15',56000.00),
(102,2,'2026-11-16',11200.00),
(103,3,'2026-11-17',17200.00);
GO
INSERT INTO labTest.OrderItems
VALUES
(1,101,1,1,55000.00),
(2,101,2,2,500.00),
(3,102,4,1,10000.00),
(4,102,3,1,1200.00),
(5,103,5,2,8000.00),
(6,103,2,2,500.00);
GO

SELECT * FROM labTest.Client;
SELECT * FROM labTest.Stock;
SELECT * FROM labTest.[Order];
SELECT * FROM labTest.OrderItems;

CREATE OR ALTER PROCEDURE createOrderProcedure3
(
    @clientID INT,
    @stockID INT,
    @quantity INT
)
AS
BEGIN

    BEGIN TRY

        BEGIN TRANSACTION;

        IF @clientID IS NULL
            THROW 50001, 'Client ID cannot be NULL.', 1;

        IF @stockID IS NULL
            THROW 50002, 'Stock ID cannot be NULL.', 1;

        IF @quantity IS NULL OR @quantity <= 0
            THROW 50003, 'Quantity must be greater than 0.', 1;

        IF NOT EXISTS
        (
            SELECT 1
            FROM labTest.Client
            WHERE clientId = @clientID
        )
            THROW 50004, 'Client not found.', 1;

        IF NOT EXISTS
        (
            SELECT 1
            FROM labTest.Stock
            WHERE stockId = @stockID
        )
            THROW 50005, 'Stock item not found.', 1;

        DECLARE @stockAvailable INT;
        DECLARE @price DECIMAL(10,2);
        DECLARE @orderId INT;
        DECLARE @orderItemId INT;

        SELECT
            @stockAvailable = quantityAvailable,
            @price = unitPrice
        FROM labTest.Stock
        WHERE stockId = @stockID;

        IF @stockAvailable < @quantity
            THROW 50006, 'Required quantity is not available in stock.', 1;

        SELECT @orderId = ISNULL(MAX(orderId), 0) + 1
        FROM labTest.[Order];

        INSERT INTO labTest.[Order]
        (
            orderId,
            clientId,
            orderDate,
            totalAmount
        )
        VALUES
        (
            @orderId,
            @clientID,
            GETDATE(),
            @price * @quantity
        );

        IF @@ROWCOUNT = 0
            THROW 50007, 'Order creation failed.', 1;

        SELECT @orderItemId = ISNULL(MAX(orderItemId), 0) + 1
        FROM labTest.OrderItems;

        INSERT INTO labTest.OrderItems
        (
            orderItemId,
            orderId,
            stockId,
            quantity,
            unitPrice
        )
        VALUES
        (
            @orderItemId,
            @orderId,
            @stockID,
            @quantity,
            @price
        );

        IF @@ROWCOUNT = 0
            THROW 50008, 'Order item creation failed.', 1;

        UPDATE labTest.Stock
        SET quantityAvailable = quantityAvailable - @quantity
        WHERE stockId = @stockID;

        IF @@ROWCOUNT = 0
            THROW 50009, 'Stock update failed.', 1;

        COMMIT TRANSACTION;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH

END;
GO


-- Invalid Client ID
EXEC createOrderProcedure3
    @clientID = 100,
    @stockID = 1,
    @quantity = 5;

-- Invalid Stock ID
EXEC createOrderProcedure3
    @clientID = 1,
    @stockID = 100,
    @quantity = 5;

-- NULL Client ID
EXEC createOrderProcedure3
    @clientID = NULL,
    @stockID = 1,
    @quantity = 5;

-- NULL Stock ID
EXEC createOrderProcedure3
    @clientID = 1,
    @stockID = NULL,
    @quantity = 5;

-- NULL Quantity
EXEC createOrderProcedure3
    @clientID = 1,
    @stockID = 1,
    @quantity = NULL;

-- Invalid Quantity
EXEC createOrderProcedure3
    @clientID = 1,
    @stockID = 1,
    @quantity = -5;

-- Insufficient Stock
EXEC createOrderProcedure3
    @clientID = 1,
    @stockID = 1,
    @quantity = 1000;

-- Successful Order
EXEC createOrderProcedure3
    @clientID = 1,
    @stockID = 1,
    @quantity = 5;

SELECT * FROM labTest.Client;
SELECT * FROM labTest.Stock;
SELECT * FROM labTest.[Order];
SELECT * FROM labTest.OrderItems;

--7 Create stored procedure to take input parameter passenger id to retrieve booking details for a specific passenger and returns output parameters to provide information about the number of bookings and the total amount spent by the passenger.        

select * from labTest.[Order]
CREATE OR ALTER PROCEDURE getClientPurchaseDetails
(
    @clientID INT,
    @totalOrdersCount INT OUTPUT,
    @totalAmountSpent DECIMAL(18,2) OUTPUT
)
AS
BEGIN

    SELECT
        @totalOrdersCount = COUNT(o.orderId),
        @totalAmountSpent = ISNULL(SUM(o.totalAmount), 0)
    FROM labTest.[Order] AS o
    WHERE o.clientId = @clientID;

END;
GO
DECLARE @orderCount INT;
DECLARE @amountSpent DECIMAL(18,2);

EXEC getClientPurchaseDetails
    @clientID = 1,
    @totalOrdersCount = @orderCount OUTPUT,
    @totalAmountSpent = @amountSpent OUTPUT;

SELECT
    @orderCount AS TotalOrders,
    @amountSpent AS TotalAmountSpent;



	--1

BEGIN TRANSACTION;
SELECT *
FROM labTest.Employee;
TRUNCATE TABLE labTest.Employee;
SELECT *
FROM labTest.Employee;
ROLLBACK TRANSACTION;
--END TRANSACTION
SELECT *
FROM labTest.Employee;

--2

DECLARE @str VARCHAR(50) = 'CAPONE';

WITH Numbers AS
(
    SELECT 1 AS N
    UNION ALL
    SELECT N + 1
    FROM Numbers
    WHERE N < LEN(@str)
)
SELECT
    SUBSTRING(@str, N, 1) AS Character
FROM Numbers
OPTION (MAXRECURSION 100);


--3

select * from labTest.Course 
DECLARE @i INT = 1;
DECLARE @CourseListCount INT;
DECLARE @ConcatinatedCourseList VARCHAR(MAX) = '';

SELECT @CourseListCount = COUNT(*)
FROM labTest.Course;

WHILE @i <= @CourseListCount
BEGIN
    SELECT @ConcatinatedCourseList =
        @ConcatinatedCourseList +
        CASE WHEN @ConcatinatedCourseList = '' THEN '' ELSE ', ' END +
        courseName
    FROM
    (
        SELECT
            ROW_NUMBER() OVER(ORDER BY courseId) AS rn,
            courseName
        FROM labTest.Course
    ) c
    WHERE c.rn = @i;

    SET @i = @i + 1;
END

SELECT @ConcatinatedCourseList;

--8 Suppose there is table named sales that stores information about sales transactions, including the sales ID, Sales Date, Customer ID, Product ID, and the Total Amount. Create indexes on the columns frequently used in the WHERE clause or JOIN conditions like sales date, customer id, product id using covering index.

CREATE TABLE labTest.Sales (
    SalesID INT IDENTITY(1,1) PRIMARY KEY,
    SalesDate DATE NOT NULL,
    CustomerID INT NOT NULL,
    ProductID INT NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL
);
CREATE NONCLUSTERED INDEX IX_Sales_SalesDate
ON labTest.Sales (SalesDate)
INCLUDE (CustomerID, ProductID, TotalAmount);

CREATE NONCLUSTERED INDEX IX_Sales_CustomerID
ON labTest.Sales (CustomerID)
INCLUDE (SalesDate, ProductID, TotalAmount);

CREATE NONCLUSTERED INDEX IX_Sales_ProductID
ON labTest.Sales (ProductID)
INCLUDE (SalesDate, CustomerID, TotalAmount);


INSERT INTO labTest.Sales (SalesDate, CustomerID, ProductID, TotalAmount)
VALUES
('2026-01-05', 101, 1, 250.00),
('2026-01-08', 102, 2, 1250.50),
('2026-01-10', 103, 3, 799.99),
('2026-01-12', 101, 2, 500.00),
('2026-01-15', 104, 1, 300.75),
('2026-01-18', 105, 4, 1500.00),
('2026-01-20', 106, 5, 99.99),
('2026-01-22', 102, 3, 450.25),
('2026-01-25', 107, 2, 2100.00),
('2026-01-28', 103, 5, 650.50),
('2026-02-01', 108, 1, 1200.00),
('2026-02-03', 109, 4, 850.00),
('2026-02-05', 101, 3, 320.00),
('2026-02-08', 110, 2, 1750.25),
('2026-02-10', 105, 1, 450.00);

SELECT SalesID, TotalAmount
FROM labTest.Sales
WHERE SalesDate BETWEEN '2026-01-01' AND '2026-12-31'
  AND CustomerID = 101
  AND ProductID = 5;


  --10

  CREATE CLUSTERED INDEX IX_Sales_CustomerID
ON labTest.Sales (CustomerID);
CREATE NONCLUSTERED INDEX IX_Sales_CustomerID_SalesDate_ProductID
ON labTest.Sales (CustomerID, SalesDate, ProductID);


--9

CREATE TABLE labTest.AccountTransaction(
    TransactionID INT IDENTITY PRIMARY KEY,
    AccountID INT NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    TransactionDate DATE NOT NULL
);

BEGIN TRY
    BEGIN TRANSACTION;

    INSERT INTO labTest.AccountTransaction(AccountID, Amount, TransactionDate)
    VALUES (101, 1000, GETDATE());

    INSERT INTO labTest.AccountTransaction(AccountID, Amount, TransactionDate)
    VALUES (102, 500, GETDATE());

    INSERT INTO labTest.AccountTransaction(AccountID, Amount, TransactionDate)
    VALUES (103, 750, GETDATE());

    COMMIT TRANSACTION;
    PRINT 'All transactions inserted successfully.';
END TRY
BEGIN CATCH

    ROLLBACK TRANSACTION;

    PRINT 'Transaction failed.';
    PRINT ERROR_MESSAGE();

END CATCH;