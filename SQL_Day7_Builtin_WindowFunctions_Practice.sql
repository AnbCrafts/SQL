-- =====================================================================
-- SQL SERVER PRACTICE - DAY 7: BUILT-IN & WINDOW FUNCTIONS
-- Domain: City Healthcare Center - Patients, Bills, & Doctors
-- =====================================================================

-- ---------------------------------------------------------------------
-- STEP 1: CREATE TABLES
-- ---------------------------------------------------------------------

-- Cleanup existing demo tables if any
DROP TABLE IF EXISTS MedicalBills;
DROP TABLE IF EXISTS Patients;
DROP TABLE IF EXISTS Doctors;

-- 1. Patients Table
CREATE TABLE Patients (
    PatientId INT PRIMARY KEY IDENTITY(1,1),
    FullName VARCHAR(100) NOT NULL,
    ContactPhone VARCHAR(20) NULL,
    DateOfBirth DATE NOT NULL,
    RegistrationDate DATETIME NOT NULL
);

-- 2. MedicalBills Table
CREATE TABLE MedicalBills (
    BillId INT PRIMARY KEY IDENTITY(1001,1),
    PatientId INT FOREIGN KEY REFERENCES Patients(PatientId),
    Department VARCHAR(50) NOT NULL,
    GrossAmount DECIMAL(10,2) NOT NULL,
    DiscountAmount DECIMAL(10,2) NULL,
    BillDate DATE NOT NULL
);

-- 3. Doctors Table
CREATE TABLE Doctors (
    DoctorId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
    DoctorName VARCHAR(100) NOT NULL,
    Specialty VARCHAR(50) NOT NULL
);

-- ---------------------------------------------------------------------
-- STEP 2: INSERT SAMPLE DATA
-- ---------------------------------------------------------------------

-- Insert Patients
INSERT INTO Patients (FullName, ContactPhone, DateOfBirth, RegistrationDate) VALUES
(' Dr. Alice Morgan ', '9876543210', '1990-05-15', '2026-01-10 09:30:00'),
('Bob Smith', '', '1985-08-22', '2026-02-14 11:15:00'),          -- Empty string phone
('Charlie Brown', NULL, '1995-12-01', '2026-03-01 14:00:00'),        -- NULL phone
('Diana Prince', '9123456789', '1988-03-30', '2026-03-15 16:45:00');

-- Insert Medical Bills
INSERT INTO MedicalBills (PatientId, Department, GrossAmount, DiscountAmount, BillDate) VALUES
(1, 'Cardiology', 15000.00, 2000.00, '2026-09-01'),
(1, 'Cardiology', 8000.00, NULL, '2026-09-10'),
(2, 'Orthopedics', 15000.00, 1000.00, '2026-09-05'),
(3, 'Orthopedics', 12000.00, NULL, '2026-09-08'),
(3, 'Cardiology', 15000.00, 3000.00, '2026-09-12'),
(4, 'Neurology', 25000.00, 5000.00, '2026-09-15');

-- Insert Doctors (Generating GUIDs via NEWID())
INSERT INTO Doctors (DoctorName, Specialty) VALUES
('Dr. Robert House', 'Diagnostics'),
('Dr. Stephen Strange', 'Neurosurgery');


-- ---------------------------------------------------------------------
-- STEP 3: DEMO QUERIES FOR BUILT-IN & WINDOW FUNCTIONS
-- ---------------------------------------------------------------------

-- 1. NULL Handling Functions (ISNULL, NULLIF, COALESCE)
-- Translate blank string or NULL to 'N/A'
SELECT 
    FullName,
    ContactPhone,
    ISNULL(NULLIF(ContactPhone, ''), 'N/A') AS CleanPhone,
    COALESCE(NULLIF(ContactPhone, ''), 'No Contact Provided') AS ContactStatus
FROM Patients;

-- 2. Conditional & String Functions (IIF, SUBSTRING, STUFF, LTRIM, RTRIM)
SELECT 
    LTRIM(RTRIM(FullName)) AS TrimmedName,
    SUBSTRING(FullName, 1, 5) AS First5Chars, -- 1-indexed!
    STUFF('Patient-000', 9, 3, '123') AS StuffedID,
    IIF(DATEDIFF(YEAR, DateOfBirth, GETDATE()) >= 35, 'Senior/Adult', 'Young Adult') AS AgeGroup
FROM Patients;

-- 3. Date & Type Conversion (DATEDIFF, FORMAT, TRY_CAST, CONVERT)
SELECT 
    PatientId,
    FORMAT(RegistrationDate, 'dd-MMM-yyyy hh:mm tt') AS FormattedDate,
    DATEDIFF(DAY, DateOfBirth, GETDATE()) AS AgeInDays,
    TRY_CAST('123.45' AS DECIMAL(10,2)) AS ValidCast,
    TRY_CAST('InvalidNum' AS DECIMAL(10,2)) AS SafeNullCast -- Returns NULL instead of error!
FROM Patients;

-- 4. Window Functions (ROW_NUMBER, RANK, DENSE_RANK)
SELECT 
    BillId,
    Department,
    GrossAmount,
    ROW_NUMBER() OVER (PARTITION BY Department ORDER BY GrossAmount DESC) AS RowNum,
    RANK() OVER (PARTITION BY Department ORDER BY GrossAmount DESC) AS RankNum,         -- Skips rank on ties!
    DENSE_RANK() OVER (PARTITION BY Department ORDER BY GrossAmount DESC) AS DenseRankNum -- Consecutive ranks!
FROM MedicalBills;


-- ---------------------------------------------------------------------
-- STEP 4: PRACTICE QUESTIONS FOR DAY 7
-- ---------------------------------------------------------------------
select * from Doctors;
select * from Patients
select * from MedicalBills

-- Q1. Write a query using ISNULL or COALESCE on MedicalBills to display GrossAmount, DiscountAmount, and NetAmount (calculated as GrossAmount - ISNULL(DiscountAmount, 0)).

select m.GrossAmount ,SUM(m.GrossAmount - isnull(m.DiscountAmount,0)) as NetAmount from MedicalBills as m  group by m.GrossAmount

-- Q2. Write a query using NULLIF to prevent divide-by-zero errors when calculating the DiscountPercentage: (DiscountAmount / NULLIF(GrossAmount, 0)) * 100.
select ROUND(isnull(SUM(DiscountAmount/nullif(m.GrossAmount,0)*100),0),2) as DicountPercentage from MedicalBills as m group by m.BillId
-- Q3. Write a query using DATEDIFF and GETDATE() to calculate the current age in years for all patients.
select DATEDIFF(Year,p.DateOfBirth,GETDATE()) as currAge from Patients as p
 
-- Q4. Write a query using TRY_CAST to attempt converting a text string '2026-09-27' to a DATE data type.
select TRY_CAST('2026-09-27'AS DATE)
-- Q5. Write a query using DENSE_RANK() OVER (ORDER BY GrossAmount DESC) to rank all medical bills by GrossAmount from highest to lowest. Display BillId, Department, GrossAmount, and BillRank.

SELECT 
    BillId,
    Department,
    GrossAmount,
    -- 1. ROW_NUMBER(): Assigns unique sequential integers (1, 2, 3, 4)
    ROW_NUMBER() OVER (PARTITION BY Department ORDER BY GrossAmount DESC) AS RowNum,

    -- 2. RANK(): Assigns rank with GAPS on ties (1, 2, 2, 4)
    RANK() OVER (PARTITION BY Department ORDER BY GrossAmount DESC) AS RankNum,

    -- 3. DENSE_RANK(): Assigns rank WITHOUT GAPS on ties (1, 2, 2, 3)
    DENSE_RANK() OVER (PARTITION BY Department ORDER BY GrossAmount DESC) AS DenseRankNum
FROM MedicalBills;