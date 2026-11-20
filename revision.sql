select * from labTest.QueryUser
order by Gender
offset 10 rows
--fetch Next 20 rows only
fetch first 20 rows only

--Pagination

declare @pageSize INT = 10
declare @pageNumber INT = 2
select * from labTest.QueryUser
order by Gender desc
offset (@pageNumber-1)*@pageSize rows
--fetch Next 20 rows only
fetch first @pageSize rows only


CREATE TABLE Store
(
    StoreID INT PRIMARY KEY,
    StoreName VARCHAR(100) NOT NULL,
    City VARCHAR(100) NOT NULL
);

GO

CREATE TABLE Staff
(
    StaffID INT PRIMARY KEY,
    StaffName VARCHAR(100) NOT NULL,
    Position VARCHAR(50) NOT NULL,
    StoreID INT NOT NULL,
    FOREIGN KEY (StoreID) REFERENCES Store(StoreID)
);

GO

CREATE TABLE [Order]
(
    OrderID INT PRIMARY KEY,
    OrderDate DATE NOT NULL,
    TotalAmount DECIMAL(10,2) NOT NULL,
    StoreID INT NOT NULL,
    StaffID INT NOT NULL,
    FOREIGN KEY (StoreID) REFERENCES Store(StoreID),
    FOREIGN KEY (StaffID) REFERENCES Staff(StaffID)
);

GO

INSERT INTO Store (StoreID, StoreName, City)
VALUES
(1, 'Central Store', 'Kolkata'),
(2, 'North Store', 'Delhi'),
(3, 'South Store', 'Chennai');

GO

INSERT INTO Staff (StaffID, StaffName, Position, StoreID)
VALUES
(101, 'Amit Sharma', 'Manager', 1),
(102, 'Riya Sen', 'Sales Executive', 1),
(103, 'Rahul Verma', 'Manager', 2),
(104, 'Sneha Gupta', 'Sales Executive', 2),
(105, 'Arjun Nair', 'Supervisor', 3);

GO

INSERT INTO [Order] (OrderID, OrderDate, TotalAmount, StoreID, StaffID)
VALUES
(1001, '2026-11-10', 1500.00, 1, 101),
(1002, '2026-11-11', 2200.00, 1, 102),
(1003, '2026-11-12', 1800.00, 2, 103),
(1004, '2026-11-13', 3500.00, 2, 104),
(1005, '2026-11-14', 2750.00, 3, 105),
(1006, '2026-11-15', 4100.00, 1, 101),
(1007, '2026-11-16', 900.00, 3, 105);

GO


-- USING CTE TO GET THE AVERGAE NUMBER OF ORDERS HANDLED BY STAFFS
select * from [Order]
select * from [Staff]
select * from [Store]
with OrderCountsCTE
as
(select COUNT(OrderID)as OrderCount, StaffID from [Order] group by StaffID)
select AVG(OrderCount)as averageOrdersCount from OrderCountsCTE


-- CTE1

;WITH StaffSalesRanked AS (
    SELECT 
        s.StoreID,
        st.StoreName,
        s.StaffID,
        s.StaffName,
        SUM(o.TotalAmount) AS TotalRevenue,
        -- Rank staff within their store based on total sales:
        DENSE_RANK() OVER (
            PARTITION BY s.StoreID 
            ORDER BY SUM(o.TotalAmount) DESC
        ) AS SalesRank
    FROM Staff s
    INNER JOIN [Order] o ON s.StaffID = o.StaffID
    INNER JOIN Store st  ON s.StoreID = st.StoreID
    GROUP BY 
        s.StoreID, 
        st.StoreName, 
        s.StaffID, 
        s.StaffName
)
SELECT 
    StoreID,
    StoreName,
    StaffID,
    StaffName,
    TotalRevenue
FROM StaffSalesRanked
WHERE SalesRank = 1; -- Filter for the #1 top performer per store



--2

;with cteGetTotalRevenue
as
(select SUM(TotalAmount) as totalRevenue, StoreID from [Order] group by StoreID),
cteGetIndividualStorePercentage
as 
(select s.StoreID,s.StoreName,o.TotalAmount as StoreTotalAmount from [Order] as o inner join Store as s on s.StoreID = o.StoreID)
select tr.StoreID, tp.StoreName, tp.StoreTotalAmount, SUM(((tr.totalRevenue-tp.StoreTotalAmount)/tr.totalRevenue)*100) as StorePercentage from cteGetTotalRevenue as tr inner join cteGetIndividualStorePercentage as tp on tr.StoreID = tp.StoreID