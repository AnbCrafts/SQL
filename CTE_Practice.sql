

with cet_GetWeekDays(n,weekday)
as 
(select 0,DATENAME(DW,0)
union all
select n+1, DATENAME(DW, n+1)
from cet_GetWeekDays
where n<6)

select * from cet_GetWeekDays;


CREATE TABLE labTest.EmployeeHierarchy
(
    EmployeeId INT PRIMARY KEY,
    EmployeeName VARCHAR(100) NOT NULL,
    Designation VARCHAR(100),
    Department VARCHAR(100),
    Salary DECIMAL(10,2),
    HireDate DATE,
    ManagerId INT NULL,

    CONSTRAINT FK_Employee_Manager
    FOREIGN KEY (ManagerId)
    REFERENCES labTest.EmployeeHierarchy(EmployeeId)
);

INSERT INTO labTest.EmployeeHierarchy
(EmployeeId, EmployeeName, Designation, Department, Salary, HireDate, ManagerId)
VALUES
-- Level 1 (Super Boss)
(1, 'Robert King', 'CEO', 'Management', 250000, '2015-01-01', NULL),

-- Level 2
(2, 'John Smith', 'VP Sales', 'Sales', 180000, '2016-03-15', 1),
(3, 'Sarah Wilson', 'VP Technology', 'IT', 190000, '2016-05-20', 1),

-- Level 3
(4, 'David Brown', 'Sales Manager', 'Sales', 120000, '2018-02-10', 2),
(5, 'Emma Davis', 'Regional Sales Manager', 'Sales', 115000, '2018-06-12', 2),
(6, 'Michael Lee', 'IT Manager', 'IT', 130000, '2018-01-05', 3),
(7, 'Sophia Miller', 'Project Manager', 'IT', 125000, '2019-02-07', 3),

-- Level 4
(8, 'Chris Taylor', 'Sales Executive', 'Sales', 70000, '2020-03-01', 4),
(9, 'Olivia Martin', 'Sales Executive', 'Sales', 72000, '2020-04-15', 4),
(10, 'James Clark', 'Sales Executive', 'Sales', 71000, '2021-01-12', 5),
(11, 'Daniel White', 'Senior Developer', 'IT', 90000, '2020-07-18', 6),
(12, 'Grace Hall', 'Senior Developer', 'IT', 92000, '2020-09-10', 6),
(13, 'Lucas Young', 'Business Analyst', 'IT', 85000, '2021-02-11', 7),

-- Level 5
(14, 'Ava Scott', 'Junior Developer', 'IT', 60000, '2022-01-20', 11),
(15, 'Noah Green', 'Junior Developer', 'IT', 62000, '2022-05-15', 12);


select * from labTest.EmployeeHierarchy

with cteEmployeeManagerLevel(EmployeeId, Name, ManagerId, [Level])
as
(
select e.EmployeeId, e.EmployeeName,isnull(e.ManagerId,0), 1
from labTest.EmployeeHierarchy as e where e.ManagerId is NULL
union all
select emp.EmployeeId, emp.EmployeeName,isnull(emp.ManagerId,'Super Boss'),[Level]+1 
from labTest.EmployeeHierarchy as emp join cteEmployeeManagerLevel on emp.ManagerId = cteEmployeeManagerLevel.EmployeeId

)select * from cteEmployeeManagerLevel



CREATE TABLE labTest.bill_of_materials (
    parent_part_id INT,
    child_part_id  INT,
    quantity       DECIMAL(10, 2) NOT NULL DEFAULT 1.00,
    PRIMARY KEY (parent_part_id, child_part_id)
);

CREATE TABLE labTest.parts (
    part_id   INT PRIMARY KEY,
    part_name VARCHAR(100) NOT NULL,
    part_type VARCHAR(20) CHECK (part_type IN ('Assembly', 'Sub-Assembly', 'Component'))
);
INSERT INTO labTest.parts (part_id, part_name, part_type) VALUES
(100, 'Bicycle', 'Assembly'),
(200, 'Frame Assembly', 'Sub-Assembly'),
(201, 'Frame Tube', 'Component'),
(202, 'Front Fork', 'Component'),
(300, 'Wheel Assembly', 'Sub-Assembly'),
(301, 'Rim', 'Component'),
(302, 'Tire', 'Component'),
(303, 'Spoke', 'Component');

INSERT INTO labTest.bill_of_materials (parent_part_id, child_part_id, quantity) VALUES
(100, 200, 1.00), -- 1 Frame per Bicycle
(100, 300, 2.00), -- 2 Wheels per Bicycle
(200, 201, 1.00), -- 1 Tube per Frame
(200, 202, 1.00), -- 1 Fork per Frame
(300, 301, 1.00), -- 1 Rim per Wheel
(300, 302, 1.00), -- 1 Tire per Wheel
(300, 303, 32.00); -- 32 Spokes per Wheel


--Q2

select * from labTest.bill_of_materials
select * from labTest.parts
WITH cte_BOM
(
    parent_part_id,
    child_part_id,
    quantity,
    LevelNo
)
AS
(
    
    SELECT
        parent_part_id,
        child_part_id,
        quantity,
        1
    FROM labTest.bill_of_materials
    WHERE parent_part_id = 300

    UNION ALL

    SELECT
        bom.parent_part_id,
        bom.child_part_id,
        bom.quantity,
        cte_BOM.LevelNo + 1
    FROM labTest.bill_of_materials bom
        INNER JOIN cte_BOM
            ON bom.parent_part_id = cte_BOM.child_part_id
)
SELECT
    *
FROM cte_BOM cte

--Q2
with cet_GenerateNumbers (n)
as 
(
select 1
union all
select n+1 from cet_GenerateNumbers
where n<10
)select n from cet_GenerateNumbers

--Q3

DECLARE @Year INT = 2026;
DECLARE @Month INT = 10;

WITH cte_Dates(DateValue)
AS
(
    SELECT DATEFROMPARTS(@Year, @Month, 1)

    UNION ALL

    SELECT DATEADD(DAY, 1, DateValue)
    FROM cte_Dates
    WHERE DateValue < EOMONTH(DATEFROMPARTS(@Year, @Month, 1))
)
SELECT DateValue
FROM cte_Dates
OPTION (MAXRECURSION 31);


--Q4

CREATE TABLE labTest.Projects
(
    ProjectId INT PRIMARY KEY,
    ProjectName VARCHAR(100) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NULL,
    Status VARCHAR(20) NOT NULL
        DEFAULT 'Planned',

    CHECK (EndDate IS NULL OR EndDate >= StartDate)
);

CREATE TABLE labTest.Tasks
(
    TaskId INT PRIMARY KEY,
    ProjectId INT NOT NULL,
    TaskName VARCHAR(150) NOT NULL,

    ParentTaskId INT NULL,
    DependsOnTaskId INT NULL,

    AssignedTo VARCHAR(100) NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NULL,
    Status VARCHAR(20) NOT NULL
        DEFAULT 'Pending',

    FOREIGN KEY (ProjectId)
        REFERENCES labTest.Projects(ProjectId),

    FOREIGN KEY (ParentTaskId)
        REFERENCES labTest.Tasks(TaskId),

    FOREIGN KEY (DependsOnTaskId)
        REFERENCES labTest.Tasks(TaskId),

    CHECK (ParentTaskId IS NULL
           OR ParentTaskId <> TaskId),

    CHECK (DependsOnTaskId IS NULL
           OR DependsOnTaskId <> TaskId),

    CHECK (EndDate IS NULL OR EndDate >= StartDate)
);

INSERT INTO labtest.Projects
    (ProjectId, ProjectName, StartDate, EndDate, Status)
VALUES
    (1, 'E-Commerce Application',
        '2026-10-01', '2026-12-31', 'In Progress'),

    (2, 'Employee Management System',
        '2026-10-05', '2027-01-31', 'Planned');


		INSERT INTO labTest.Tasks
    (TaskId, ProjectId, TaskName, ParentTaskId,
     DependsOnTaskId, AssignedTo, StartDate, EndDate, Status)
VALUES
-- Project 1: top-level tasks
(101, 1, 'Requirement Analysis', NULL, NULL,
 'Rahul', '2026-10-01', '2026-10-05', 'Completed'),

(102, 1, 'System Design', NULL, 101,
 'Amit', '2026-10-06', '2026-10-12', 'Completed'),

(103, 1, 'Backend Development', NULL, 102,
 'Priya', '2026-10-13', '2026-10-25', 'In Progress'),

(104, 1, 'Frontend Development', NULL, 102,
 'Neha', '2026-10-13', '2026-10-27', 'In Progress'),

(105, 1, 'Testing', NULL, 103,
 'Rohit', '2026-10-28', '2026-11-05', 'Pending'),

-- Subtasks of Backend Development
(106, 1, 'Database Design', 103, NULL,
 'Amit', '2026-10-13', '2026-10-16', 'Completed'),

(107, 1, 'Develop API', 103, 106,
 'Priya', '2026-10-17', '2026-10-23', 'In Progress'),

(108, 1, 'API Unit Testing', 103, 107,
 'Rohit', '2026-10-24', '2026-10-25', 'Pending'),

-- Project 2
(201, 2, 'Gather Employee Requirements', NULL, NULL,
 'Sneha', '2026-10-05', '2026-10-10', 'Planned'),

(202, 2, 'Design Employee Database', NULL, 201,
 'Amit', '2026-10-11', '2026-10-15', 'Planned');
select * from labTest.Tasks
select * from labTest.Projects

--Retrieve all subtasks under a parent task Given TaskId = 103 (Backend Development), retrieve all tasks and nested subtasks under it, regardless of depth.

WITH cte_GetAllSubTask
(
    TaskId,
    TaskName,
    ParentTaskId,
    LevelNo
)
AS
(
   
    SELECT
        TaskId,
        TaskName,
        ParentTaskId,
        0
    FROM labTest.Tasks
    WHERE TaskId = 103

    UNION ALL

    
    SELECT
        t.TaskId,
        t.TaskName,
        t.ParentTaskId,
        cte.LevelNo + 1
    FROM labTest.Tasks t
    INNER JOIN cte_GetAllSubTask cte
        ON t.ParentTaskId = cte.TaskId
)
SELECT *
FROM cte_GetAllSubTask
ORDER BY LevelNo, TaskId;

WITH cte_GetTaskHierarchy
(
    TaskId,
    TaskName,
    ParentTaskId,
    [Level]
)
AS
(

    SELECT
        t.TaskId,
        t.TaskName,
        t.ParentTaskId,
        1
    FROM labTest.Tasks t
    WHERE  t.ParentTaskId IS NULL

    UNION ALL


    SELECT
        t.TaskId,
        t.TaskName,
        t.ParentTaskId,
        cte.[Level] + 1
    FROM labTest.Tasks t
    INNER JOIN cte_GetTaskHierarchy cte
        ON t.ParentTaskId = cte.TaskId
)
SELECT *
FROM cte_GetTaskHierarchy
ORDER BY [Level], TaskId;

--Find tasks that have no child tasks beneath them in the hierarchy. Example leaf tasks include Database Design, Develop API, and API Unit Testing. Return the project ID, task ID, task name, and status. A leaf task may still have dependencies on other tasks.

WITH cte_GetLeafTask
(
    TaskId,
    TaskName,
    ParentTaskId,
    [Level]
)
AS
(

    SELECT
        t.TaskId,
        t.TaskName,
        t.ParentTaskId,
        1
    FROM labTest.Tasks t
    WHERE t.ProjectId = 1
      AND t.ParentTaskId IS not NULL

    UNION ALL


    SELECT
        t.TaskId,
        t.TaskName,
        t.ParentTaskId,
        cte.[Level] + 1
    FROM labTest.Tasks t
    INNER JOIN cte_GetLeafTask cte
        ON t.ParentTaskId = cte.TaskId
)
SELECT *
FROM cte_GetLeafTask
ORDER BY [Level], TaskId;