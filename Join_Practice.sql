-- ============================================================================
-- SQL JOIN PRACTICE SETUP (T-SQL / MS SQL Server)
-- ============================================================================

-- 1. CREATE SCHEMA
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'PracticeJoin')
BEGIN
    EXEC('CREATE SCHEMA PracticeJoin');
END
GO

-- Clean up existing tables if re-running
DROP TABLE IF EXISTS PracticeJoin.EmployeeProjects;
DROP TABLE IF EXISTS PracticeJoin.Projects;
DROP TABLE IF EXISTS PracticeJoin.Employees;
DROP TABLE IF EXISTS PracticeJoin.Departments;
GO

-- 2. CREATE TABLES

-- Table 1: Departments
CREATE TABLE PracticeJoin.Departments (
    department_id   INT PRIMARY KEY IDENTITY(10, 10), -- 10, 20, 30, 40...
    department_name VARCHAR(50) NOT NULL,
    location        VARCHAR(50) NOT NULL
);

-- Table 2: Employees (Includes manager_id for Self Joins, NULL department_id for Contractors)
CREATE TABLE PracticeJoin.Employees (
    employee_id     INT PRIMARY KEY IDENTITY(101, 1),
    first_name      VARCHAR(50) NOT NULL,
    last_name       VARCHAR(50) NOT NULL,
    department_id   INT NULL FOREIGN KEY REFERENCES PracticeJoin.Departments(department_id),
    manager_id      INT NULL FOREIGN KEY REFERENCES PracticeJoin.Employees(employee_id),
    salary          DECIMAL(10, 2) NOT NULL
);

-- Table 3: Projects
CREATE TABLE PracticeJoin.Projects (
    project_id      INT PRIMARY KEY IDENTITY(1, 1),
    project_name    VARCHAR(100) NOT NULL,
    budget          DECIMAL(12, 2) NOT NULL
);

-- Table 4: EmployeeProjects (Junction table for Many-to-Many relationship)
CREATE TABLE PracticeJoin.EmployeeProjects (
    employee_id     INT FOREIGN KEY REFERENCES PracticeJoin.Employees(employee_id),
    project_id      INT FOREIGN KEY REFERENCES PracticeJoin.Projects(project_id),
    role            VARCHAR(50) NOT NULL,
    PRIMARY KEY (employee_id, project_id)
);
GO

-- 3. INSERT SAMPLE DATA

-- Insert Departments
INSERT INTO PracticeJoin.Departments (department_name, location)
VALUES 
    ('Human Resources', 'Bangalore'),   -- ID 10
    ('Technology',      'Hyderabad'),   -- ID 20
    ('Marketing',       'Mumbai'),      -- ID 30
    ('Finance',         'Delhi');       -- ID 40 (No employees assigned -> perfect for RIGHT/LEFT JOIN tests!)

-- Insert Employees
INSERT INTO PracticeJoin.Employees (first_name, last_name, department_id, manager_id, salary)
VALUES 
    ('Alice',   'Smith',   20, NULL, 120000.00), -- ID 101: Tech Lead (No manager)
    ('Bob',     'Jones',   20, 101,   85000.00), -- ID 102: Tech, reports to Alice
    ('Charlie', 'Brown',   10, 101,   65000.00), -- ID 103: HR, reports to Alice
    ('Diana',   'Prince',  30, 103,   70000.00), -- ID 104: Marketing, reports to Charlie
    ('Evan',    'Wright',  NULL, 102, 90000.00); -- ID 105: Contractor (NO Dept), reports to Bob

-- Insert Projects
INSERT INTO PracticeJoin.Projects (project_name, budget)
VALUES 
    ('Cloud Migration',    500000.00), -- ID 1
    ('HR Portal Redesign', 150000.00), -- ID 2
    ('Ad Campaign 2026',   300000.00), -- ID 3
    ('Annual Audit',       200000.00); -- ID 4 (No employees assigned)

-- Insert Employee-Project Allocations
INSERT INTO PracticeJoin.EmployeeProjects (employee_id, project_id, role)
VALUES 
    (101, 1, 'Project Manager'),
    (102, 1, 'Lead Developer'),
    (103, 2, 'HR Coordinator'),
    (104, 3, 'Marketing Manager');
GO

-- ============================================================================
-- VERIFY SETUP
-- ============================================================================
SELECT * FROM PracticeJoin.Departments;
SELECT * FROM PracticeJoin.Employees;
SELECT * FROM PracticeJoin.Projects;
SELECT * FROM PracticeJoin.EmployeeProjects;



GO


select e.first_name, e.last_name, e.salary, d.department_name, d.location from PracticeJoin.Employees as e inner join PracticeJoin.Departments as d on e.department_id = d.department_id

select e.first_name, ep.role, d.department_name from PracticeJoin.Employees as e inner join PracticeJoin.Departments as d on e.department_id = d.department_id inner join PracticeJoin.EmployeeProjects as ep on e.employee_id = ep.employee_id

select e.first_name + ' ' + e.last_name as Name , d.department_name from PracticeJoin.Employees as e left join PracticeJoin.Departments as d on e.department_id = d.department_id

select e.first_name + ' ' + e.last_name as Name , d.department_name from PracticeJoin.Employees as e left join PracticeJoin.Departments as d on e.department_id = d.department_id where d.department_name is null

select d.department_name from PracticeJoin.Employees as e right join PracticeJoin.Departments as d on e.department_id = d.department_id where e.employee_id is null


select e.first_name + ' ' + e.last_name, e.salary as Name, d.department_name, p.project_name, ep.role from PracticeJoin.Employees as e inner join PracticeJoin.Departments as d on e.department_id = d.department_id inner join PracticeJoin.EmployeeProjects as ep on e.employee_id = ep.employee_id inner join PracticeJoin.Projects as p on p.project_id = ep.project_id

select d.department_name, Count(e.employee_id) as empCount from PracticeJoin.Employees as e inner join PracticeJoin.Departments as d on e.department_id = d.department_id group by d.department_name