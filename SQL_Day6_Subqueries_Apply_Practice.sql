-- =====================================================================
-- SQL SERVER PRACTICE - DAY 6: SUBQUERIES & APPLY OPERATORS
-- Domain: Software Projects & Tasks Management
-- =====================================================================

-- ---------------------------------------------------------------------
-- STEP 1: CREATE TABLES & TABLE-VALUED FUNCTION
-- ---------------------------------------------------------------------

-- Cleanup existing demo objects if any
DROP FUNCTION IF EXISTS fn_GetTasksByProject;
DROP TABLE IF EXISTS ProjectTasks;
DROP TABLE IF EXISTS TechProjects;
DROP TABLE IF EXISTS Developers;

-- 1. TechProjects Table
CREATE TABLE TechProjects (
    ProjectId INT PRIMARY KEY IDENTITY(101,1),
    ProjectName VARCHAR(100) NOT NULL,
    Budget DECIMAL(12,2) NOT NULL,
    ClientRegion VARCHAR(50) NOT NULL
);

-- 2. ProjectTasks Table
CREATE TABLE ProjectTasks (
    TaskId INT PRIMARY KEY IDENTITY(1,1),
    ProjectId INT NULL FOREIGN KEY REFERENCES TechProjects(ProjectId),
    TaskName VARCHAR(100) NOT NULL,
    EstimatedHours INT NOT NULL,
    Status VARCHAR(20) NOT NULL
);

-- 3. Developers Table
CREATE TABLE Developers (
    DevId INT PRIMARY KEY IDENTITY(1,1),
    DevName VARCHAR(100) NOT NULL,
    HourlyRate DECIMAL(10,2) NOT NULL,
    City VARCHAR(50) NOT NULL
);

-- ---------------------------------------------------------------------
-- STEP 2: INSERT SAMPLE DATA
-- ---------------------------------------------------------------------

-- Insert Projects
INSERT INTO TechProjects (ProjectName, Budget, ClientRegion) VALUES
('AI Customer Support Bot', 80000.00, 'USA'),     -- ProjectId 101
('Mobile Banking App', 150000.00, 'UK'),          -- ProjectId 102
('E-Commerce Cloud Migration', 45000.00, 'USA'),   -- ProjectId 103
('Internal ERP Refactoring', 25000.00, 'India'),   -- ProjectId 104
('Legacy System Deprecation', 10000.00, 'EU');     -- ProjectId 105 (No tasks assigned)

-- Insert Tasks
INSERT INTO ProjectTasks (ProjectId, TaskName, EstimatedHours, Status) VALUES
(101, 'Train NLP Model', 120, 'Completed'),
(101, 'Build API Endpoint', 40, 'In Progress'),
(102, 'Setup Biometric Auth', 80, 'Completed'),
(102, 'UI/UX Redesign', 60, 'Completed'),
(102, 'Payment Gateway Integration', 90, 'Pending'),
(103, 'Database Schema Migration', 70, 'Completed'),
(104, 'Refactor Legacy Modules', 50, 'Pending');

-- Insert Developers
INSERT INTO Developers (DevName, HourlyRate, City) VALUES
('Alex Mercer', 150.00, 'San Jose'),
('David Chen', 120.00, 'San Jose'),
('Elena Rostova', 180.00, 'London'),
('Priya Sharma', 90.00, 'Bangalore');

-- ---------------------------------------------------------------------
-- STEP 3: CREATE TABLE-VALUED FUNCTION (TVF) FOR APPLY DEMO
-- ---------------------------------------------------------------------
GO
CREATE FUNCTION fn_GetTasksByProject(@ProjId INT)
RETURNS TABLE
AS
RETURN (
    SELECT TaskId, TaskName, EstimatedHours, Status
    FROM ProjectTasks
    WHERE ProjectId = @ProjId
);
GO

-- ---------------------------------------------------------------------
-- STEP 4: DEMO QUERIES FOR SUBQUERIES & APPLY
-- ---------------------------------------------------------------------

-- 1. Scalar Subquery in SELECT clause
SELECT 
    ProjectName,
    Budget,
    (SELECT AVG(Budget) FROM TechProjects) AS AvgProjectBudget,
    Budget - (SELECT AVG(Budget) FROM TechProjects) AS DiffFromAvg
FROM TechProjects;

-- 2. Subquery with IN operator
SELECT ProjectName, Budget
FROM TechProjects
WHERE ProjectId IN (
    SELECT DISTINCT ProjectId 
    FROM ProjectTasks 
    WHERE Status = 'Completed'
);

-- 3. Correlated Subquery (Find projects with budget greater than avg of their region)
SELECT p1.ProjectName, p1.ClientRegion, p1.Budget
FROM TechProjects p1
WHERE p1.Budget > (
    SELECT AVG(p2.Budget)
    FROM TechProjects p2
    WHERE p2.ClientRegion = p1.ClientRegion
);

-- 4. Subquery with EXISTS / NOT EXISTS
-- Find projects that have NO tasks assigned:
SELECT p.ProjectName
FROM TechProjects p
WHERE NOT EXISTS (
    SELECT 1 
    FROM ProjectTasks t 
    WHERE t.ProjectId = p.ProjectId
);

-- 5. Subquery with ANY / ALL operators
-- Find projects with budget greater than ALL projects in 'India' region:
SELECT ProjectName, Budget
FROM TechProjects
WHERE Budget > ALL (
    SELECT Budget 
    FROM TechProjects 
    WHERE ClientRegion = 'India'
);

-- 6. CROSS APPLY (Table + TVF: Only returns projects that HAVE tasks)
SELECT p.ProjectName, t.TaskName, t.EstimatedHours
FROM TechProjects p
CROSS APPLY fn_GetTasksByProject(p.ProjectId) t;

-- 7. OUTER APPLY (Table + TVF: Returns ALL projects, including ones with NO tasks)
SELECT p.ProjectName, ISNULL(t.TaskName, 'No Tasks') AS TaskName
FROM TechProjects p
OUTER APPLY fn_GetTasksByProject(p.ProjectId) t;


-- ---------------------------------------------------------------------
-- STEP 5: PRACTICE QUESTIONS FOR DAY 6
-- ---------------------------------------------------------------------
select * from ProjectTasks
select * from TechProjects
select * from Developers

-- Q1. Write a query using a subquery with IN to find all ProjectName(s) that have at least one task with EstimatedHours > 70.

select tp.ProjectName from TechProjects as tp where tp.ProjectId in (select pt.ProjectId from ProjectTasks as pt where pt.EstimatedHours<70);

-- Q2. Write a query using EXISTS to find all Developers who live in a City where at least one developer has an HourlyRate > 140. (Correlated subquery).

select * from Developers as d where exists(select 1 from Developers as d2 where d .City = d2.City and d2.HourlyRate>140); 

-- Q3. Write a query using ALL operator (> ALL) to find all ProjectName(s) whose Budget is greater than ALL project budgets in the 'USA' region.

select * from TechProjects as tp where tp.Budget>ALL(select tp2.Budget from TechProjects as tp2 where tp2.ClientRegion = 'USA');

-- Q4. Write a query using CROSS APPLY with the function fn_GetTasksByProject to display the ProjectName and TaskName for tasks that are 'Completed'.

select tp.ProjectName, pt.TaskName from TechProjects as tp cross apply fn_GetTasksByProject(tp.ProjectId) as pt where pt.Status = 'Completed'

-- Q5. Write a query using OUTER APPLY to display all ProjectName(s) and their total estimated task hours (SUM of EstimatedHours). Make sure projects without tasks display 0 (or NULL).

select tp.ProjectName, isnull(sum(pt.EstimatedHours),0) as totalHrs from TechProjects as tp outer apply fn_GetTasksByProject(tp.ProjectId) as pt group by tp.ProjectName order by tp.ProjectName 
