-- 1. Create the Employees table
CREATE TABLE EmployeesData (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    EmpId VARCHAR(10) NOT NULL UNIQUE,
    Name VARCHAR(100) NOT NULL,
    Designation VARCHAR(50) NOT NULL,
    DOB DATE NOT NULL,
    DOJ DATE NOT NULL,
    Salary DECIMAL(10, 2) NOT NULL,
    Address VARCHAR(255) DEFAULT 'N/A'
);

-- 2. Insert the sample data from the screenshot
INSERT INTO EmployeesData (EmpId, Name, Designation, DOB, DOJ, Salary, Address)
VALUES 
    ('E004', 'Ranjit Das',    'General Employee', '1988-05-20', '2015-01-07', 15000.00, 'N/A'),
    ('E005', 'Sagar Das',     'Manager',          '1989-06-04', '2016-01-18', 40000.00, 'N/A'),
    ('E002', 'Samer Sen',     'Project Manager',  '1984-04-19', '2015-04-13', 35000.00, 'N/A'),
    ('E003', 'Sandeep Gupta', 'Team Leader',      '1981-04-18', '2016-01-20', 28000.00, 'N/A'),
    ('E006', 'Sujit Sen',     'General Employee', '1987-06-04', '2015-04-07', 12000.00, 'N/A'),
    ('E001', 'Suresh Das',    'Project Manager',  '1985-06-04', '2016-01-07', 30000.00, 'N/A');


-- =============================================
-- PROCEDURES
-- =============================================

-- 1. Get Distinct Designations (To populate the "Designation" dropdown)
CREATE OR ALTER PROCEDURE sp_GetDesignations
AS
BEGIN
    SET NOCOUNT ON;
    
    select distinct e.Designation from EmployeesData as e  
    
END

exec sp_GetDesignations

-- 2. Search, Filter & Sort Employees (For the GridView search and dropdown change)
CREATE OR ALTER PROCEDURE sp_SearchEmployees
    @SearchTerm   VARCHAR(100) = NULL,  -- Search keyword for EmpId or Name
    @Designation  VARCHAR(50)  = NULL,  -- Filter by Designation ('Select', '' or NULL for all)
    @SortBy       VARCHAR(50)  = 'Name' -- Column to sort by: 'Name', 'EmpId', 'Salary', 'DOB', 'DOJ', etc.
AS
BEGIN
    SET NOCOUNT ON;

    -- Clean up input parameters
    SET @SearchTerm = LTRIM(RTRIM(@SearchTerm));
    SET @Designation = LTRIM(RTRIM(@Designation));
    SET @SortBy = LTRIM(RTRIM(@SortBy));

    SELECT 
        ROW_NUMBER() OVER (
            ORDER BY 
                CASE WHEN @SortBy = 'EmpId' THEN EmpId END ASC,
                CASE WHEN @SortBy = 'Designation' THEN Designation END ASC,
                CASE WHEN @SortBy = 'DOB' THEN DOB END ASC,
                CASE WHEN @SortBy = 'DOJ' THEN DOJ END ASC,
                CASE WHEN @SortBy = 'Salary' THEN Salary END ASC,
                -- Default sorting by Name
                CASE WHEN @SortBy = 'Name' OR @SortBy IS NULL OR @SortBy = '' THEN Name END ASC
        ) AS [#],
        EmpId,
        Name,
        Designation,
        CONVERT(VARCHAR(10), DOB, 103) AS DOB,  -- 103 formats date as DD/MM/YYYY (as shown in image)
        CONVERT(VARCHAR(10), DOJ, 103) AS DOJ,  -- 103 formats date as DD/MM/YYYY
        Salary,
        Address
    FROM EmployeesData
    WHERE 
        -- 1. Search filter: Matches either EmpId or Name
        (
            @SearchTerm IS NULL 
            OR @SearchTerm = '' 
            OR EmpId LIKE '%' + @SearchTerm + '%' 
            OR Name LIKE '%' + @SearchTerm + '%'
        )
        -- 2. Designation filter: If NULL, empty, or 'Select', show all
        AND (
            @Designation IS NULL 
            OR @Designation = '' 
            OR @Designation = 'Select' 
            OR Designation = @Designation
        )
    ORDER BY [#] ASC;
END

EXEC sp_SearchEmployees @Designation = 'Project Manager';


-- 3. Add New Employee (Triggered by clicking the "Add" button)
CREATE OR ALTER PROCEDURE sp_AddEmployee
    @EmpId       VARCHAR(10),
    @Name        VARCHAR(100),
    @Designation VARCHAR(50),
    @DOB         DATE,
    @DOJ         DATE,
    @Salary      DECIMAL(10, 2),
    @Address     VARCHAR(255) = 'N/A'
AS
BEGIN
    SET NOCOUNT ON;
    
    insert into EmployeesData values(@EmpId,@Name,@Designation,@DOB,@DOJ,@Salary,@Address) 
    
END



-- 4. Get Employee By ID (For editing or viewing single record)
CREATE OR ALTER PROCEDURE sp_GetEmployeeById
    @EmpId VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    
    select * from EmployeesData where EmpId = @EmpId
    
END
GO


-- 5. Update Employee Details
CREATE OR ALTER PROCEDURE sp_UpdateEmployee
    @EmpId       VARCHAR(10),
    @Name        VARCHAR(100)    = NULL,
    @Designation VARCHAR(50)     = NULL,
    @DOB         DATE            = NULL,
    @DOJ         DATE            = NULL,
    @Salary      DECIMAL(10, 2)  = NULL,
    @Address     VARCHAR(255)    = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Update only the row matching @EmpId
    UPDATE EmployeesData
    SET 
        Name        = ISNULL(@Name, Name),
        Designation = ISNULL(@Designation, Designation),
        DOB         = ISNULL(@DOB, DOB),
        DOJ         = ISNULL(@DOJ, DOJ),
        Salary      = ISNULL(@Salary, Salary),
        Address     = ISNULL(@Address, Address)
    WHERE EmpId = @EmpId;

    -- Return number of affected rows (1 if successful, 0 if EmpId not found)
    SELECT @@ROWCOUNT AS RowsAffected;
END

-- Update only the Salary and Designation for 'E001' (other fields remain unchanged)
EXEC sp_UpdateEmployee 
    @EmpId = 'E001', 
    @Designation = 'Senior Project Manager', 
    @Salary = 38000.00;

-- Verify the change
SELECT * FROM EmployeesData WHERE EmpId = 'E001';

-- 6. Delete Employee
CREATE OR ALTER PROCEDURE sp_DeleteEmployee
    @EmpId VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    
    Delete from EmployeesData where EmpId = @EmpId
    
END
