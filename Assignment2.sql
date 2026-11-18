--Assignment 2 


--1.	Write a query to fetch each customer's name, last order date along with the total value of orders they have placed using inline sub query.


SELECT
    o1.customer_id as Customer,
    MAX(o1.order_date) AS LastOrderDate,
    (
        SELECT SUM(o2.order_amount)
        FROM labTest.orders o2
        WHERE o2.customer_id = o1.customer_id
    ) AS TotalOrderValue
FROM labTest.orders o1
GROUP BY
    o1.customer_id 

	select * from labTest.orders

--3.Write a SQL Query to find the first Week Day of the month 
DECLARE @MonthStart DATE = '2026-11-01';

SELECT DATENAME(weekday,DATEADD(
           DAY,
           CASE DATENAME(WEEKDAY, @MonthStart)
                WHEN 'Saturday' THEN 2
                WHEN 'Sunday'   THEN 1
                ELSE 0
           END,
           @MonthStart
       )) AS FirstWeekDay;

--4.Write a query to find the 3rd highest salary in each department from the Employee table 
WITH SalaryRank AS
(
    SELECT
        EmployeeId,
        Department,
        Salary,
        DENSE_RANK() OVER (partition by Department ORDER BY Salary DESC) AS SalRank
    FROM labTest.EmployeeData
)
SELECT *
FROM SalaryRank
WHERE SalRank = 3;

--5.Write a query by using ANY & ALL operator
select 
emp.FirstName, 
emp.Salary, 
emp.City 
from 
labTest.EmployeeData as emp 
where 
emp.Salary >  
ANY (
select 
Salary 
from labTest.EmployeeData 
where EmployeeId > 900000
);

select emp.FirstName, emp.Salary, emp.City from labTest.EmployeeData as emp where emp.Salary >  ALL (select Salary from labTest.EmployeeData where EmployeeId > 900000 and Salary =129984.00);


--6.Assign a rank to each movie based on the ordering of their release dates
with empJoinDateRank 
as 
(
select 
emp.EmployeeId, 
emp.JoiningDate, 
emp.FirstName, 
DENSE_RANK() OVER(order by emp.JoiningDate) as EmpRank 
from 
labTest.EmployeeData as emp
)
select 
* 
from 
empJoinDateRank 


--7.	Retrieve information about each book along with its author, publisher, and genre details using apply operator

-- Create Author Table
CREATE TABLE Author
(
    AuthorID INT PRIMARY KEY,
    AuthorName VARCHAR(100) NOT NULL,
    Country VARCHAR(50)
);

-- Create Publisher Table
CREATE TABLE Publisher
(
    PublisherID INT PRIMARY KEY,
    PublisherName VARCHAR(100) NOT NULL,
    City VARCHAR(50)
);

-- Create Genre Table
CREATE TABLE Genre
(
    GenreID INT PRIMARY KEY,
    GenreName VARCHAR(50) NOT NULL
);

-- Create Book Table
CREATE TABLE Book
(
    BookID INT PRIMARY KEY,
    BookName VARCHAR(200) NOT NULL,
    AuthorID INT,
    PublisherID INT,
    GenreID INT,
    Price DECIMAL(10,2),
    PublishedYear INT,

    FOREIGN KEY (AuthorID) REFERENCES Author(AuthorID),
    FOREIGN KEY (PublisherID) REFERENCES Publisher(PublisherID),
    FOREIGN KEY (GenreID) REFERENCES Genre(GenreID)
);

---------------------------------------------------
-- Insert Data into Author
---------------------------------------------------

INSERT INTO Author VALUES
(1, 'J.K. Rowling', 'United Kingdom'),
(2, 'George Orwell', 'United Kingdom'),
(3, 'Chetan Bhagat', 'India'),
(4, 'Paulo Coelho', 'Brazil'),
(5, 'Dan Brown', 'United States');

---------------------------------------------------
-- Insert Data into Publisher
---------------------------------------------------

INSERT INTO Publisher VALUES
(1, 'Bloomsbury', 'London'),
(2, 'Penguin Books', 'New York'),
(3, 'HarperCollins', 'Delhi'),
(4, 'Simon & Schuster', 'New York'),
(5, 'Jaico Publishing', 'Mumbai');

---------------------------------------------------
-- Insert Data into Genre
---------------------------------------------------

INSERT INTO Genre VALUES
(1, 'Fantasy'),
(2, 'Political Fiction'),
(3, 'Romance'),
(4, 'Adventure'),
(5, 'Thriller');

---------------------------------------------------
-- Insert Data into Book
---------------------------------------------------

INSERT INTO Book VALUES
(101, 'Harry Potter and the Philosopher''s Stone', 1, 1, 1, 499.00, 1997),
(102, '1984', 2, 2, 2, 350.00, 1949),
(103, 'Five Point Someone', 3, 3, 3, 299.00, 2004),
(104, 'The Alchemist', 4, 5, 4, 399.00, 1988),
(105, 'The Da Vinci Code', 5, 4, 5, 599.00, 2003),
(106, 'Harry Potter and the Chamber of Secrets', 1, 1, 1, 550.00, 1998),
(107, 'Animal Farm', 2, 2, 2, 250.00, 1945),
(108, '2 States', 3, 3, 3, 320.00, 2009);

---------------------------------------------------
-- Verify Data
---------------------------------------------------

SELECT * FROM Author;
SELECT * FROM Publisher;
SELECT * FROM Genre;
SELECT * FROM Book;


select 
b.BookName , 
a.AuthorName, 
p.PublisherName, 
g.GenreName 
from 
Book as b 
CROSS APPLY
(select a.AuthorName from Author as a where b.AuthorID = a.AuthorID) a
cross apply
(select p.PublisherName from Publisher as p where b.PublisherID = p.PublisherID) p
cross apply
(select g.GenreName from Genre as g where b.GenreID = g.GenreID) g

--8.	Write a query to retrieve each customer along with the total amount of all their orders using cross apply with derived table

CREATE TABLE labTest.Customer
(
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(15),
    city VARCHAR(50)
);

INSERT INTO labTest.Customer
(customer_id, customer_name, email, phone, city)
VALUES
(1, 'Rahul Sharma', 'rahul@gmail.com', '9876543210', 'Kolkata'),
(2, 'Priya Singh', 'priya@gmail.com', '9876543211', 'Delhi'),
(3, 'Amit Kumar', 'amit@gmail.com', '9876543212', 'Mumbai'),
(4, 'Sneha Das', 'sneha@gmail.com', '9876543213', 'Bangalore'),
(5, 'Vikas Patel', 'vikas@gmail.com', '9876543214', 'Chennai');

-- Optional Foreign Key
ALTER TABLE labTest.orders
ADD CONSTRAINT FK_Orders_Customer
FOREIGN KEY (customer_id)
REFERENCES labTest.Customer(customer_id);


create function 
getAllOrders
()
returns Table 
as 
return
(
select 
* 
from 
labTest.orders
)

create function 
getAllCustomers
()
returns Table 
as 
return
(
select 
* 
from 
labTest.Customer
)

select 
oc.customer_name as CustomerName, 
oc.customer_id, 
SUM(o.order_amount) as totalOrder 
from 
getAllOrders() as o
CROSS APPLY
(
select 
c.customer_name, 
c.customer_id 
from 
getAllCustomers() as  c 
where 
o.customer_id = c.customer_id
) oc
group by 
oc.customer_id ,
oc.customer_name 
order by totalOrder


--9

select 
MAX(p.first_name) as PatientName, 
MAX(dep.department_name) as DepartmentName ,
count(p.patient_id) as TotalPatientsVisited,
DATENAME(month,a.appointment_date) as Month 
from 
labTest.Appointments as a
inner join 
labTest.Doctors as d
on a.doctor_id = d.doctor_id
inner join 
labTest.Patients as p
on p.patient_id = a.patient_id
inner join 
labTest.Departments as dep 
on d.department_id = dep.department_id
group by 
p.patient_id,dep.department_id, 
DATENAME(month,a.appointment_date), 
d.specialization

--10

select
'XXXXXX'+RIGHT(qu.MobileNo,4) as MaskedContactNumber, 
LEFT(qu.QueryText,20) as ShortDescription 
from 
labTest.QueryUser as qu

--11
------------------------------------------------------------
-- DEALER
------------------------------------------------------------
CREATE TABLE Dealer
(
    DealerID INT PRIMARY KEY,
    DealerName VARCHAR(100),
    City VARCHAR(50)
);
GO
INSERT INTO Dealer VALUES
(1, 'Eastern Paints Distributor', 'Kolkata'),
(2, 'Color World Traders', 'Delhi'),
(3, 'Rainbow Supplies', 'Mumbai'),
(4, 'Prime Coatings', 'Chennai');
GO
------------------------------------------------------------
-- PAINT
------------------------------------------------------------
CREATE TABLE Paint
(
    PaintID INT PRIMARY KEY,
    PaintName VARCHAR(100),
    PaintType VARCHAR(50),
    UnitPrice DECIMAL(10,2)
);
GO
INSERT INTO Paint VALUES
(101, 'Weather Shield', 'Exterior', 1200.00),
(102, 'Easy Clean', 'Interior', 950.00),
(103, 'Luxol Satin', 'Emulsion', 1500.00),
(104, 'Bison Acrylic', 'Exterior', 1500.00),
(105, 'Silk Glamour', 'Premium Interior', 1800.00);
GO
------------------------------------------------------------
-- SALES ORDER
------------------------------------------------------------
CREATE TABLE SalesOrder
(
    OrderID INT PRIMARY KEY,
    DealerID INT,
    PaintID INT,
    OrderDate DATE,
    Quantity INT,

    FOREIGN KEY (DealerID) REFERENCES Dealer(DealerID),
    FOREIGN KEY (PaintID) REFERENCES Paint(PaintID)
);
GO
INSERT INTO SalesOrder VALUES
(1001, 1, 101, '2024-01-10', 10),
(1002, 1, 102, '2024-02-15', 15),
(1003, 1, 103, '2024-03-20', 8),
(1004, 1, 101, '2024-04-25', 12),

(1005, 2, 104, '2024-01-05', 14),
(1006, 2, 102, '2024-02-18', 22),
(1007, 2, 105, '2024-03-28', 6),

(1008, 3, 103, '2024-01-12', 9),
(1009, 3, 101, '2024-02-07', 20),
(1010, 3, 104, '2024-03-21', 8),
(1011, 3, 102, '2024-04-04', 18),

(1012, 4, 105, '2024-01-15', 5),
(1013, 4, 103, '2024-02-22', 6),
(1014, 4, 101, '2024-03-10', 15),
(1015, 4, 104, '2024-04-18', 12);

------------------------------------------------------------
-- SAMPLE DATA CHECK
------------------------------------------------------------

SELECT * FROM Paint;
SELECT * FROM SalesOrder;
SELECT * FROM Dealer as d

WITH DealerOrders AS
(
    SELECT
        d.DealerID,
        d.DealerName,
        s.OrderID,
        s.OrderDate,
        s.PaintID,
        s.Quantity,
        ROW_NUMBER() OVER
        (
            PARTITION BY d.DealerID
            ORDER BY s.OrderDate
        ) AS OrderSequence
    FROM Dealer d
    INNER JOIN SalesOrder s
        ON d.DealerID = s.DealerID
),
PaintSales AS
(
    SELECT
        p.PaintID,
        p.PaintName,
        SUM(s.Quantity * p.UnitPrice) AS TotalSalesAmount
    FROM Paint p
    INNER JOIN SalesOrder s
        ON p.PaintID = s.PaintID
    GROUP BY
        p.PaintID,
        p.PaintName
),
PaintRank AS
(
    SELECT
        PaintID,
        PaintName,
        TotalSalesAmount,
        DENSE_RANK() OVER
        (
            ORDER BY TotalSalesAmount DESC
        ) AS PaintRank
    FROM PaintSales
)

SELECT
    do.DealerID,
    do.DealerName,
    do.OrderID,
    do.OrderDate,
    do.OrderSequence,
    pr.PaintName,
    pr.TotalSalesAmount,
    pr.PaintRank
FROM DealerOrders do
INNER JOIN PaintRank pr
    ON do.PaintID = pr.PaintID
ORDER BY
    do.DealerID,
    do.OrderSequence;


--12
CREATE FUNCTION getSalesSummary()
RETURNS TABLE
AS
RETURN
(
    SELECT
        d.DealerID,
        d.DealerName,
        COUNT(s.OrderID) AS TotalOrders,
        SUM(s.Quantity * p.UnitPrice) AS TotalSales
    FROM Dealer d
    INNER JOIN SalesOrder s
        ON d.DealerID = s.DealerID
    INNER JOIN Paint p
        ON s.PaintID = p.PaintID
    GROUP BY
        d.DealerID,
        d.DealerName
);


SELECT *
FROM dbo.getSalesSummary();


--2
DECLARE @i INT = 1;

WHILE @i <= 5
BEGIN
    PRINT REPLICATE('*', @i);
    SET @i = @i + 1;
END


DECLARE @i INT = 10;

WHILE @i >= 1
BEGIN
    PRINT REPLICATE('*', @i);
    SET @i = @i - 1;
END