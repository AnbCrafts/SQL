-- =====================================================================
-- SQL SERVER PRACTICE: RECURSIVE COMMON TABLE EXPRESSIONS (CTE)
-- Dialect: T-SQL (Microsoft SQL Server)
-- =====================================================================

/*
========================================================================
THEORY & STRUCTURE OF A RECURSIVE CTE
========================================================================

A Recursive CTE is a CTE that references itself. It is commonly used to:
1. Generate series (numbers, dates, intervals).
2. Traverse hierarchical data (Employee -> Manager, Categories -> Subcategories).
3. Bill of Materials (BOM) and dependency trees.
4. Graph traversal (routes, flights, paths).

BASIC SYNTAX PATTERN:
---------------------
WITH CTE_Name AS (
    -- 1. ANCHOR MEMBER (Base query - runs once at Iteration 0)
    SELECT ...
    FROM TableName
    WHERE <base_condition>

    UNION ALL

    -- 2. RECURSIVE MEMBER (References CTE_Name - runs repeatedly)
    SELECT ...
    FROM TableName
    INNER JOIN CTE_Name ON <join_condition>
    WHERE <termination_condition>
)
-- 3. OUTER QUERY (Consumes the final aggregated result set)
SELECT * FROM CTE_Name
OPTION (MAXRECURSION 100); -- Safety limit (Default is 100 in SQL Server, 0 = unlimited)
========================================================================
*/


-- =====================================================================
-- PART 1: GENERATING SEQUENCES & DATE RANGES
-- =====================================================================

-- ---------------------------------------------------------------------
-- Example 1.1: Generate a Number Series (1 to 10)
-- ---------------------------------------------------------------------
WITH NumberSeriesCTE AS (
    -- Anchor: Start value
    SELECT 1 AS Number

    UNION ALL

    -- Recursive: Increment until condition is met
    SELECT Number + 1
    FROM NumberSeriesCTE
    WHERE Number < 10
)
SELECT 
    Number,
    Number * Number AS Square,
    POWER(Number, 3) AS Cube
FROM NumberSeriesCTE;


-- ---------------------------------------------------------------------
-- Example 1.2: Generate a Date Range (Calendar Table on the fly)
-- Practical scenario: Filling missing sales/attendance dates
-- ---------------------------------------------------------------------
DECLARE @StartDate DATE = '2026-10-01';
DECLARE @EndDate   DATE = '2026-10-15';

WITH DateDimensionCTE AS (
    -- Anchor: First day
    SELECT @StartDate AS CalendarDate

    UNION ALL

    -- Recursive: Add 1 day until reaching @EndDate
    SELECT DATEADD(DAY, 1, CalendarDate)
    FROM DateDimensionCTE
    WHERE CalendarDate < @EndDate
)
SELECT 
    CalendarDate,
    DATENAME(WEEKDAY, CalendarDate) AS DayName,
    CASE 
        WHEN DATEPART(WEEKDAY, CalendarDate) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS DayType
FROM DateDimensionCTE
OPTION (MAXRECURSION 1000);



-- =====================================================================
-- PART 2: HIERARCHICAL DATA (ORGANIZATION CHART / MANAGEMENT TREE)
-- =====================================================================

-- ---------------------------------------------------------------------
-- STEP 2.1: CREATE TABLES & INSERT DATA
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS Employees;

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    FirstName  VARCHAR(50) NOT NULL,
    LastName   VARCHAR(50) NOT NULL,
    Title      VARCHAR(100) NOT NULL,
    Department VARCHAR(50) NOT NULL,
    ManagerID  INT NULL FOREIGN KEY REFERENCES Employees(EmployeeID)
);

-- Organization Structure:
-- Rajesh Sharma (CEO - Top Level)
--   ├── Priya Nair (VP Engineering)
--   │     ├── Amit Patel (Tech Lead)
--   │     │     ├── Rohit Sen (Senior Dev)
--   │     │     └── Sneha Roy (Junior Dev)
--   │     └── Neha Verma (QA Lead)
--   └── Vikram Malhotra (VP Sales)
--         └── Ananya Sen (Sales Manager)
--               └── Kunal Das (Account Executive)

INSERT INTO Employees (EmployeeID, FirstName, LastName, Title, Department, ManagerID) VALUES
(1,  'Rajesh', 'Sharma',   'Chief Executive Officer', 'Executive',   NULL),
(2,  'Priya',  'Nair',     'VP of Engineering',       'Engineering', 1),
(3,  'Vikram', 'Malhotra', 'VP of Sales',             'Sales',       1),
(4,  'Amit',   'Patel',    'Engineering Lead',        'Engineering', 2),
(5,  'Neha',   'Verma',    'QA Lead',                 'Engineering', 2),
(6,  'Ananya', 'Sen',      'Sales Manager',           'Sales',       3),
(7,  'Rohit',  'Sen',      'Senior Software Engineer','Engineering', 4),
(8,  'Sneha',  'Roy',      'Software Engineer',       'Engineering', 4),
(9,  'Kunal',  'Das',      'Account Executive',       'Sales',       6);


-- ---------------------------------------------------------------------
-- Example 2.2: Top-Down Hierarchy (Find all reports & hierarchy level)
-- ---------------------------------------------------------------------
WITH OrgHierarchyCTE AS (
    -- Anchor Member: Root / Top level (CEO, ManagerID is NULL)
    SELECT 
        EmployeeID,
        FirstName + ' ' + LastName AS EmployeeName,
        Title,
        ManagerID,
        1 AS HierarchyLevel,
        CAST(FirstName + ' ' + LastName AS VARCHAR(500)) AS ReportingChain
    FROM Employees
    WHERE ManagerID IS NULL

    UNION ALL

    -- Recursive Member: Join employee where ManagerID = previous EmployeeID
    SELECT 
        e.EmployeeID,
        e.FirstName + ' ' + e.LastName AS EmployeeName,
        e.Title,
        e.ManagerID,
        cte.HierarchyLevel + 1 AS HierarchyLevel,
        CAST(cte.ReportingChain + ' -> ' + e.FirstName + ' ' + e.LastName AS VARCHAR(500)) AS ReportingChain
    FROM Employees e
    INNER JOIN OrgHierarchyCTE cte 
        ON e.ManagerID = cte.EmployeeID
)
SELECT 
    HierarchyLevel,
    REPLICATE('    ', HierarchyLevel - 1) + EmployeeName AS IndentedOrgChart,
    Title,
    ReportingChain
FROM OrgHierarchyCTE
ORDER BY ReportingChain;


-- ---------------------------------------------------------------------
-- Example 2.3: Subtree / Downward Hierarchy for a Specific Manager
-- Find everyone who reports directly or indirectly to Priya Nair (ID = 2)
-- ---------------------------------------------------------------------
WITH DownwardSubtreeCTE AS (
    -- Anchor: Specific Manager
    SELECT 
        EmployeeID,
        FirstName + ' ' + LastName AS EmployeeName,
        Title,
        ManagerID,
        0 AS SubLevel
    FROM Employees
    WHERE EmployeeID = 2 -- Priya Nair

    UNION ALL

    -- Recursive: Subordinates
    SELECT 
        e.EmployeeID,
        e.FirstName + ' ' + e.LastName AS EmployeeName,
        e.Title,
        e.ManagerID,
        cte.SubLevel + 1 AS SubLevel
    FROM Employees e
    INNER JOIN DownwardSubtreeCTE cte 
        ON e.ManagerID = cte.EmployeeID
)
SELECT 
    SubLevel,
    EmployeeID,
    EmployeeName,
    Title
FROM DownwardSubtreeCTE;


-- ---------------------------------------------------------------------
-- Example 2.4: Bottom-Up Hierarchy (Management Chain of an Employee)
-- Find the entire management chain above Sneha Roy (ID = 8)
-- ---------------------------------------------------------------------
WITH ManagementChainCTE AS (
    -- Anchor: The target employee
    SELECT 
        EmployeeID,
        FirstName + ' ' + LastName AS EmployeeName,
        Title,
        ManagerID,
        1 AS StepFromEmployee
    FROM Employees
    WHERE EmployeeID = 8 -- Sneha Roy

    UNION ALL

    -- Recursive: Walk up to the manager
    SELECT 
        mgr.EmployeeID,
        mgr.FirstName + ' ' + mgr.LastName AS EmployeeName,
        mgr.Title,
        mgr.ManagerID,
        cte.StepFromEmployee + 1 AS StepFromEmployee
    FROM Employees mgr
    INNER JOIN ManagementChainCTE cte 
        ON mgr.EmployeeID = cte.ManagerID
)
SELECT 
    StepFromEmployee,
    EmployeeID,
    EmployeeName,
    Title
FROM ManagementChainCTE
ORDER BY StepFromEmployee;



-- =====================================================================
-- PART 3: MULTI-LEVEL BILL OF MATERIALS (BOM) & COST ROLLUP
-- =====================================================================

-- ---------------------------------------------------------------------
-- STEP 3.1: CREATE BOM TABLES & DATA
-- ---------------------------------------------------------------------
DROP TABLE IF EXISTS BillOfMaterials;
DROP TABLE IF EXISTS Parts;

CREATE TABLE Parts (
    PartID INT PRIMARY KEY,
    PartName VARCHAR(100) NOT NULL,
    UnitCost DECIMAL(10,2) NOT NULL
);

CREATE TABLE BillOfMaterials (
    ParentPartID INT NOT NULL FOREIGN KEY REFERENCES Parts(PartID),
    ChildPartID  INT NOT NULL FOREIGN KEY REFERENCES Parts(PartID),
    QuantityRequired INT NOT NULL,
    PRIMARY KEY (ParentPartID, ChildPartID)
);

-- Parts definition
INSERT INTO Parts (PartID, PartName, UnitCost) VALUES
(100, 'Electric Bicycle', 0.00),     -- Final Assembly
(200, 'Frame Assembly',  120.00),    -- Sub-assembly
(201, 'Battery Pack',    350.00),    -- Component
(202, 'Electric Motor',  220.00),    -- Component
(300, 'Wheel Set',        80.00),    -- Sub-assembly
(401, 'Tire',             25.00),    -- Raw Part
(402, 'Rim & Spokes',     45.00),    -- Raw Part
(403, 'Brake Rotor',      15.00);    -- Raw Part

-- Bill of Materials Relationships
-- Electric Bicycle (100) requires:
--   - 1 Frame Assembly (200)
--   - 1 Battery Pack (201)
--   - 1 Electric Motor (202)
--   - 2 Wheel Sets (300)
--       Each Wheel Set (300) requires:
--         - 1 Tire (401)
--         - 1 Rim & Spokes (402)
--         - 1 Brake Rotor (403)
INSERT INTO BillOfMaterials (ParentPartID, ChildPartID, QuantityRequired) VALUES
(100, 200, 1),
(100, 201, 1),
(100, 202, 1),
(100, 300, 2),
(300, 401, 1),
(300, 402, 1),
(300, 403, 1);


-- ---------------------------------------------------------------------
-- Example 3.2: Explode Bill of Materials & Calculate Total Quantities
-- ---------------------------------------------------------------------
WITH BOM_ExplosionCTE AS (
    -- Anchor: Top assembly items directly under 'Electric Bicycle' (100)
    SELECT 
        bom.ParentPartID,
        bom.ChildPartID,
        p.PartName AS ComponentName,
        bom.QuantityRequired AS QuantityPerUnit,
        bom.QuantityRequired AS TotalQuantityRequired,
        p.UnitCost,
        1 AS BOM_Level
    FROM BillOfMaterials bom
    INNER JOIN Parts p ON bom.ChildPartID = p.PartID
    WHERE bom.ParentPartID = 100

    UNION ALL

    -- Recursive: Children of sub-assemblies
    SELECT 
        bom.ParentPartID,
        bom.ChildPartID,
        p.PartName AS ComponentName,
        bom.QuantityRequired AS QuantityPerUnit,
        cte.TotalQuantityRequired * bom.QuantityRequired AS TotalQuantityRequired,
        p.UnitCost,
        cte.BOM_Level + 1 AS BOM_Level
    FROM BillOfMaterials bom
    INNER JOIN Parts p ON bom.ChildPartID = p.PartID
    INNER JOIN BOM_ExplosionCTE cte ON bom.ParentPartID = cte.ChildPartID
)
SELECT 
    BOM_Level,
    ComponentName,
    QuantityPerUnit,
    TotalQuantityRequired,
    UnitCost,
    (TotalQuantityRequired * UnitCost) AS TotalLineCost
FROM BOM_ExplosionCTE
ORDER BY BOM_Level, ComponentName;



-- =====================================================================
-- PART 4: SAFEGUARDING & RECURSION PITFALLS
-- =====================================================================

/*
Key Rules to Remember:
1. MAXRECURSION Hint:
   - Default limit is 100 iterations.
   - If a query hits 100 loops without terminating, SQL Server raises error 530.
   - Use `OPTION (MAXRECURSION 0)` to allow infinite recursion (be careful!).
   - Use `OPTION (MAXRECURSION 500)` to set a custom safe threshold.

2. Unsupported operations inside the Recursive Member:
   - DISTINCT
   - GROUP BY / HAVING
   - Window Functions (OVER clause)
   - OUTER JOINs (LEFT/RIGHT JOINs referencing the CTE directly)
   - TOP with no ORDER BY / Subqueries referencing the recursive member

3. Preventing Circular References:
   - If Employee A manages B, and B manages A, recursion will loop infinitely.
   - Track paths as strings and check `CHARINDEX` / string containment, 
     or maintain a visited list to detect cycles.
*/

-- ---------------------------------------------------------------------
-- Example 4.1: Custom MAXRECURSION setting demo
-- ---------------------------------------------------------------------
WITH SafeSeriesCTE AS (
    SELECT 1 AS StepNum
    UNION ALL
    SELECT StepNum + 1
    FROM SafeSeriesCTE
    WHERE StepNum < 250
)
SELECT COUNT(*) AS TotalStepsCount
FROM SafeSeriesCTE
OPTION (MAXRECURSION 300); -- Necessary because 250 > default 100



-- =====================================================================
-- PART 5: DATE & CALENDAR PRACTICE EXERCISES
-- =====================================================================

/*
------------------------------------------------------------------------
EXERCISE 1: Find All Mondays in Q4 2026
Task: List all Mondays between '2026-10-01' and '2026-12-31' with their
      sequential week index.
------------------------------------------------------------------------
*/
-- Write your solution for Exercise 1 here:
WITH MondaysCTE AS (
    -- 1. Anchor: First Monday in Q4 2026
    SELECT 
        1 AS WeekNumber,
        CAST('2026-10-05' AS DATE) AS MondayDate

    UNION ALL

    -- 2. Recursive Member: Add 7 days each loop
    SELECT 
        WeekNumber + 1,
        DATEADD(DAY, 7, MondayDate)
    FROM MondaysCTE
    -- 3. Termination Condition: End of Q4
    WHERE DATEADD(DAY, 7, MondayDate) <= '2026-12-31'
)
SELECT 
    WeekNumber,
    MondayDate,
    DATENAME(WEEKDAY, MondayDate) AS DayName
FROM MondaysCTE;




/*
------------------------------------------------------------------------
EXERCISE 2: Missing Sales Dates (Zero-Revenue Gap Filling)
Task: Display every date from '2026-10-01' to '2026-10-10' alongside total
      orders and revenue. Show 0 for days with no orders.
------------------------------------------------------------------------
*/
DROP TABLE IF EXISTS StoreOrders;
CREATE TABLE StoreOrders (
    OrderID INT PRIMARY KEY IDENTITY(1,1),
    OrderDate DATE NOT NULL,
    Amount DECIMAL(10,2) NOT NULL
);

INSERT INTO StoreOrders (OrderDate, Amount) VALUES
('2026-10-01', 1500.00),
('2026-10-02', 2300.00),
('2026-10-05', 4100.00),
('2026-10-06', 1200.00),
('2026-10-10', 3500.00);

-- Write your solution for Exercise 2 here:
WITH CalendarCTE AS (
    SELECT CAST('2026-10-01' AS DATE) AS CalendarDate
    UNION ALL
    SELECT DATEADD(DAY, 1, CalendarDate)
    FROM CalendarCTE
    WHERE CalendarDate < '2026-10-10'
)
SELECT 
    c.CalendarDate AS ReportDate,
    DATENAME(WEEKDAY, c.CalendarDate) AS DayName,
    COUNT(o.OrderID) AS TotalOrders,
    ISNULL(SUM(o.Amount), 0.00) AS TotalRevenue
FROM CalendarCTE c
LEFT JOIN StoreOrders o 
    ON c.CalendarDate = o.OrderDate
GROUP BY c.CalendarDate
ORDER BY c.CalendarDate;




/*
------------------------------------------------------------------------
EXERCISE 3: Business Days (Excluding Weekends & Official Holidays)
Task: Generate dates between '2026-10-01' and '2026-10-20'. Exclude 
      Saturdays, Sundays, and entries in CompanyHolidays. Assign a
      sequential WorkingDayIndex.
------------------------------------------------------------------------
*/
DROP TABLE IF EXISTS CompanyHolidays;
CREATE TABLE CompanyHolidays (
    HolidayDate DATE PRIMARY KEY,
    HolidayName VARCHAR(50) NOT NULL
);

INSERT INTO CompanyHolidays (HolidayDate, HolidayName) VALUES
('2026-10-02', 'Gandhi Jayanti'),
('2026-10-20', 'Dussehra');

-- Write your solution for Exercise 3 here:
WITH cte_GetCompanyWorkingDays AS (
    SELECT CAST('2026-10-01' AS DATE) AS CalendarDate
    UNION ALL
    SELECT DATEADD(DAY, 1, CalendarDate) 
    FROM cte_GetCompanyWorkingDays
    WHERE CalendarDate < CAST('2026-10-20' AS DATE)
)
SELECT 
    ROW_NUMBER() OVER (ORDER BY c.CalendarDate) AS WorkingDayIndex,
    c.CalendarDate AS WorkDate,
    DATENAME(WEEKDAY, c.CalendarDate) AS DayName
FROM cte_GetCompanyWorkingDays c
LEFT JOIN CompanyHolidays h 
    ON c.CalendarDate = h.HolidayDate
WHERE h.HolidayDate IS NULL
  AND DATENAME(WEEKDAY, c.CalendarDate) NOT IN ('Saturday', 'Sunday');




/*
------------------------------------------------------------------------
EXERCISE 4: 6-Month Loan EMI Repayment Schedule
Task: Starting from loan date '2026-10-15', generate a 6-month repayment
      schedule starting on '2026-11-15' with flat amount 15000.00.
------------------------------------------------------------------------
*/
-- Write your solution for Exercise 4 here:
WITH cte_GetLoanRepaymentSchedule AS (
    SELECT 
        1 AS InstallmentNumber,
        CAST('2026-11-15' AS DATE) AS DueDate,
        CAST(15000.00 AS DECIMAL(10,2)) AS EMIAmount
    UNION ALL
    SELECT 
        InstallmentNumber + 1,
        DATEADD(MONTH, 1, DueDate),
        EMIAmount
    FROM cte_GetLoanRepaymentSchedule
    WHERE InstallmentNumber < 6
)
SELECT 
    InstallmentNumber,
    DueDate,
    DATENAME(WEEKDAY, DueDate) AS DueDay,
    EMIAmount
FROM cte_GetLoanRepaymentSchedule;




/*
------------------------------------------------------------------------
EXERCISE 5: Hotel Stay Date Explosion
Task: Explode room reservations into individual night stays (each night
      from CheckInDate up to but excluding CheckOutDate).
------------------------------------------------------------------------
*/
DROP TABLE IF EXISTS RoomReservations;
CREATE TABLE RoomReservations (
    ReservationID INT PRIMARY KEY,
    GuestName VARCHAR(50) NOT NULL,
    RoomNumber INT NOT NULL,
    CheckInDate DATE NOT NULL,
    CheckOutDate DATE NOT NULL
);

INSERT INTO RoomReservations (ReservationID, GuestName, RoomNumber, CheckInDate, CheckOutDate) VALUES
(101, 'Aditya Rao', 301, '2026-10-01', '2026-10-04'),
(102, 'Rohan Mehra', 302, '2026-10-02', '2026-10-05');

-- Write your solution for Exercise 5 here:
WITH StayDatesCTE AS (
    SELECT 
        ReservationID,
        GuestName,
        RoomNumber,
        CheckInDate AS StayDate,
        CheckOutDate
    FROM RoomReservations

    UNION ALL

    SELECT 
        ReservationID,
        GuestName,
        RoomNumber,
        DATEADD(DAY, 1, StayDate) AS StayDate,
        CheckOutDate
    FROM StayDatesCTE
    WHERE DATEADD(DAY, 1, StayDate) < CheckOutDate
)
SELECT 
    ReservationID,
    GuestName,
    RoomNumber,
    StayDate
FROM StayDatesCTE
ORDER BY 
    ReservationID, 
    StayDate;



-- =====================================================================
-- PART 6: FINAL MASTERY CHALLENGES
-- =====================================================================

/*
------------------------------------------------------------------------
CHALLENGE 1: 5 Agile Sprint Windows (14-day cycles)
Start: 2026-10-01. Output: SprintNumber, SprintStartDate, SprintEndDate
------------------------------------------------------------------------
*/
-- Write your solution for Challenge 1 here:
WITH AgileSprintsCTE AS (
    -- 1. Anchor: Sprint 1 (14 days inclusive: Oct 1 to Oct 14)
    SELECT 
        1 AS SprintNumber,
        CAST('2026-10-01' AS DATE) AS SprintStartDate,
        CAST('2026-10-14' AS DATE) AS SprintEndDate

    UNION ALL

    -- 2. Recursive Member: Next sprint starts the day after previous sprint ends
    SELECT 
        SprintNumber + 1,
        DATEADD(DAY, 1, SprintEndDate) AS SprintStartDate,
        DATEADD(DAY, 14, SprintEndDate) AS SprintEndDate
    FROM AgileSprintsCTE
    -- 3. Termination Condition: Stop after 5 sprints
    WHERE SprintNumber < 5
)
-- 4. Final Output
SELECT 
    SprintNumber,
    SprintStartDate,
    SprintEndDate,
    DATEDIFF(DAY, SprintStartDate, SprintEndDate) + 1 AS TotalSprintDays
FROM AgileSprintsCTE;
/*
------------------------------------------------------------------------
CHALLENGE 2: Find the Ultimate Boss (CEO) for Every Employee
Using table: Employees (from Part 2)
Output: EmployeeID, EmployeeName, Title, UltimateBossName, DistanceToCEO
------------------------------------------------------------------------
*/
-- Write your solution for Challenge 2 here:
WITH cte_GetUltimateBossAndDistance AS (
    SELECT 
        e.EmployeeID AS EmpId, 
        e.FirstName + ' ' + e.LastName AS EmployeeName, 
        e.Title AS Post,
        e.FirstName + ' ' + e.LastName AS UltimateBossName,
        0 AS DistanceFromCEO 
    FROM Employees AS e
    WHERE e.ManagerID IS NULL

    UNION ALL

    SELECT 
        e.EmployeeID AS EmpId, 
        e.FirstName + ' ' + e.LastName AS EmployeeName, 
        e.Title AS Post, 
        cte.UltimateBossName, 
        cte.DistanceFromCEO + 1 
    FROM cte_GetUltimateBossAndDistance AS cte 
    INNER JOIN Employees AS e 
        ON cte.EmpId = e.ManagerID
)
SELECT 
    EmpId,
    EmployeeName,
    Post,
    UltimateBossName,
    DistanceFromCEO
FROM cte_GetUltimateBossAndDistance
ORDER BY DistanceFromCEO, EmpId;




/*
------------------------------------------------------------------------
CHALLENGE 3: Delimited String Splitter (No STRING_SPLIT)
Input: 'SQL,Python,PowerBI,Tableau,Snowflake'
Output: ItemOrder, SkillName
------------------------------------------------------------------------
*/
DECLARE @Tags VARCHAR(MAX) = 'SQL,Python,PowerBI,Tableau,Snowflake';

-- Write your solution for Challenge 3 here:
WITH StringSplitterCTE AS (
    SELECT 
        1 AS ItemOrder,
        CAST(SUBSTRING(@Tags + ',', 1, CHARINDEX(',', @Tags + ',') - 1) AS VARCHAR(100)) AS SkillName,
        CAST(SUBSTRING(@Tags + ',', CHARINDEX(',', @Tags + ',') + 1, LEN(@Tags + ',')) AS VARCHAR(MAX)) AS RemainingString

    UNION ALL

    SELECT 
        ItemOrder + 1,
        CAST(SUBSTRING(RemainingString, 1, CHARINDEX(',', RemainingString) - 1) AS VARCHAR(100)) AS SkillName,
        CAST(SUBSTRING(RemainingString, CHARINDEX(',', RemainingString) + 1, LEN(RemainingString)) AS VARCHAR(MAX)) AS RemainingString
    FROM StringSplitterCTE
    WHERE LEN(RemainingString) > 0
)
SELECT 
    ItemOrder,
    SkillName
FROM StringSplitterCTE;
-- =====================================================================
-- PART 7: NON-DATE HIERARCHY & GRAPH CHALLENGES
-- =====================================================================

/*
------------------------------------------------------------------------
EXERCISE 6: E-Commerce Category Breadcrumbs
Task: Generate full breadcrumb path (e.g. 'Electronics > Computers > Laptops')
      and DepthLevel for every category.
------------------------------------------------------------------------
*/
DROP TABLE IF EXISTS ProductCategories;
CREATE TABLE ProductCategories (
    CategoryID INT PRIMARY KEY,
    CategoryName VARCHAR(50) NOT NULL,
    ParentCategoryID INT NULL
);

INSERT INTO ProductCategories (CategoryID, CategoryName, ParentCategoryID) VALUES
(1, 'Electronics', NULL),
(2, 'Computers', 1),
(3, 'Laptops', 2),
(4, 'Gaming Laptops', 3),
(5, 'Smartphones', 1),
(6, 'Accessories', 1),
(7, 'Keyboards', 6),
(8, 'Mechanical Keyboards', 7);

-- Write your solution for Exercise 6 here:
WITH cte_GetProductDepthLevel AS (
    -- 1. Anchor: Top-level root categories (ParentCategoryID is NULL)
    SELECT 
        p.CategoryID AS Id, 
        p.CategoryName AS Category, 
        1 AS DepthLevel,
        CAST(p.CategoryName AS VARCHAR(500)) AS BreadcrumbPath
    FROM ProductCategories AS p 
    WHERE p.ParentCategoryID IS NULL

    UNION ALL

    -- 2. Recursive Member: Join parent (cte) to child (p)
    SELECT 
        p.CategoryID AS Id, 
        p.CategoryName AS Category, 
        cte.DepthLevel + 1,
        CAST(cte.BreadcrumbPath + ' > ' + p.CategoryName AS VARCHAR(500))
    FROM cte_GetProductDepthLevel AS cte  
    INNER JOIN ProductCategories AS p 
        ON cte.Id = p.ParentCategoryID
)
-- 3. Final Output
SELECT 
    Id,
    Category,
    DepthLevel,
    BreadcrumbPath
FROM cte_GetProductDepthLevel
ORDER BY BreadcrumbPath;
/*
------------------------------------------------------------------------
EXERCISE 7: Flight Route Pathfinding (DEL to LHR)
Task: Find all flight routes from 'DEL' to 'LHR', number of hops/stops,
      and total ticket price. Order by cheapest first.
------------------------------------------------------------------------
*/
DROP TABLE IF EXISTS Flights;
CREATE TABLE Flights (
    FlightID INT PRIMARY KEY,
    DepartureCity VARCHAR(3) NOT NULL,
    ArrivalCity VARCHAR(3) NOT NULL,
    Price DECIMAL(10,2) NOT NULL
);

INSERT INTO Flights (FlightID, DepartureCity, ArrivalCity, Price) VALUES
(101, 'DEL', 'DXB', 18000.00),
(102, 'DXB', 'LHR', 32000.00),
(103, 'DEL', 'DOH', 17000.00),
(104, 'DOH', 'LHR', 31000.00),
(105, 'DEL', 'BOM',  5000.00),
(106, 'BOM', 'DXB', 16000.00),
(107, 'DEL', 'LHR', 58000.00);

-- Write your solution for Exercise 7 here:
WITH FlightPathsCTE AS (
    -- 1. Anchor Member: All flights departing from 'DEL'
    SELECT 
        DepartureCity AS OriginCity,
        ArrivalCity AS CurrentCity,
        CAST(DepartureCity + ' -> ' + ArrivalCity AS VARCHAR(500)) AS RoutePath,
        1 AS FlightsCount,
        Price AS TotalPrice
    FROM Flights
    WHERE DepartureCity = 'DEL'

    UNION ALL

    -- 2. Recursive Member: Connect from CurrentCity to next flight's DepartureCity
    SELECT 
        cte.OriginCity,
        f.ArrivalCity AS CurrentCity,
        CAST(cte.RoutePath + ' -> ' + f.ArrivalCity AS VARCHAR(500)) AS RoutePath,
        cte.FlightsCount + 1 AS FlightsCount,
        CAST(cte.TotalPrice + f.Price AS DECIMAL(10,2)) AS TotalPrice
    FROM FlightPathsCTE cte
    INNER JOIN Flights f 
        ON cte.CurrentCity = f.DepartureCity
    -- 3. Safety: Stop if already reached LHR, and avoid cycles
    WHERE cte.CurrentCity != 'LHR'
      AND CHARINDEX(f.ArrivalCity, cte.RoutePath) = 0
)
-- 4. Final Output: Show completed journeys to LHR, cheapest first!
SELECT 
    RoutePath,
    (FlightsCount - 1) AS LayoversCount,
    TotalPrice
FROM FlightPathsCTE
WHERE CurrentCity = 'LHR'
ORDER BY TotalPrice ASC;
/*
------------------------------------------------------------------------
EXERCISE 8: Referral Downline Network Size
Task: Find the count of all direct and indirect users referred by UserID = 1.
------------------------------------------------------------------------
*/
DROP TABLE IF EXISTS UserReferrals;
CREATE TABLE UserReferrals (
    UserID INT PRIMARY KEY,
    UserName VARCHAR(50) NOT NULL,
    ReferredByUserID INT NULL
);

INSERT INTO UserReferrals (UserID, UserName, ReferredByUserID) VALUES
(1, 'Aarav (Top Influencer)', NULL),
(2, 'Bhavna', 1),
(3, 'Chirag', 1),
(4, 'Deepak', 2),
(5, 'Esha', 2),
(6, 'Farhan', 4),
(7, 'Gaurav', 6),
(8, 'Hari (Independent User)', NULL);

-- Write your solution for Exercise 8 here:
WITH cte_GetAllReferredUsers AS (
    -- 1. Anchor: Direct referrals of UserID = 1
    SELECT 
        u.UserID,
        u.UserName,
        1 AS ReferralLevel
    FROM UserReferrals AS u
    WHERE u.ReferredByUserID = 1

    UNION ALL

    -- 2. Recursive Member: Downline referrals (joined on UserID)
    SELECT 
        u1.UserID,
        u1.UserName,
        cte.ReferralLevel + 1 AS ReferralLevel
    FROM UserReferrals AS u1
    INNER JOIN cte_GetAllReferredUsers AS cte 
        ON u1.ReferredByUserID = cte.UserID
)
-- 3. Final Output: Count total downline team size
SELECT 
    1 AS ReferrerID,
    'Aarav (Top Influencer)' AS ReferrerName,
    COUNT(*) AS TotalDownlineMembers
FROM cte_GetAllReferredUsers;


CREATE TABLE Staff (
    EmployeeId INT PRIMARY KEY,
    Name VARCHAR(50),
    Department VARCHAR(50),
    Salary INT,
    SalesAmount INT,
    ManagerId INT NULL
);

INSERT INTO Staff (EmployeeId, Name, Department, Salary, SalesAmount, ManagerId) VALUES
(1,  'Victor',   'Executive', 120000, 0,      NULL), -- CEO
(2,  'Rachel',   'Sales',     85000,  600000, 1),    -- Head of Sales (reports to Victor)
(3,  'David',    'IT',        80000,  0,      1),    -- Head of IT (reports to Victor)
(4,  'Sophia',   'Sales',     60000,  450000, 2),    -- Reports to Rachel
(5,  'Marcus',   'Sales',     55000,  300000, 2),    -- Reports to Rachel
(6,  'Leo',      'IT',        58000,  0,      3),    -- Reports to David
(7,  'Chloe',    'Sales',     50000,  250000, 4);    -- Reports to Sophia


--single
with DepartmentSummary 
as 
(
select s.Department , SUM(s.SalesAmount) as TotalSales, AVG(s.Salary) as AverageSales from Staff as s group by s.Department
)
select * from DepartmentSummary where TotalSales>50000;

--multiple
with cte_DeptHeadcount 
as 
(
select s.Department as Dept, COUNT(s.EmployeeId) as TotalStaff from Staff as s group by s.Department
),
cte_HighEarners
as 
(
select s.Department as Dept2, COUNT(s.EmployeeId) as HighEarnersCount from Staff as s where s.Salary>80000 group by s.Department 
)
select hc.Dept as Department, hc.TotalStaff as TotalCount, he.HighEarnersCount from cte_DeptHeadcount hc inner join cte_HighEarners he on hc.Dept = he.Dept2


--recursive
with cte_Hierarchy  
as 
(
select emp.EmployeeId as EmployeeId, emp.Name as Person, isnull(mgr.Name, 'Final Boss') as ManagerName, 1 as [Level] from Staff as emp left join Staff as mgr on emp.ManagerId = mgr.EmployeeId where emp.ManagerId is null 
union all
select cte.EmployeeId, cte.Person, cte.ManagerName, [Level]+1 from cte_Hierarchy cte inner join Staff as s  on s.ManagerId = cte.EmployeeId
)
select *from cte_Hierarchy
