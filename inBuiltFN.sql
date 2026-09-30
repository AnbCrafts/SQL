/*=========================================================
  DROP OLD OBJECTS
=========================================================*/

IF OBJECT_ID('labTest.employee', 'U') IS NOT NULL
    DROP TABLE labTest.employee;

IF NOT EXISTS (
    SELECT *
    FROM sys.schemas
    WHERE name = 'labTest' 
)
BEGIN
    EXEC('CREATE SCHEMA labTest');
END;


/*=========================================================
  CREATE TABLE
=========================================================*/

CREATE TABLE labTest.employee
(
    emp_id INT IDENTITY PRIMARY KEY,
    emp_name VARCHAR(20),
    nickname VARCHAR(5),
    email VARCHAR(50),
    phone VARCHAR(15),
    salary DECIMAL(10,2)
);




/*=========================================================
  INSERT DATA
=========================================================*/

INSERT INTO labTest.employee
(emp_name, nickname, email, phone, salary)
VALUES
('Anubhaw', NULL, 'anubhaw@gmail.com', NULL, 50000),
('Rahul', 'Rocky', NULL, '9876543210', 45000),
('Priya', NULL, NULL, NULL, NULL),
('Amit', 'Amit', 'amit@gmail.com', '9999999999', 60000);



/*=========================================================
  EXAMPLE 1 : SIMPLE NULL REPLACEMENT
=========================================================*/


SELECT
   *
FROM labTest.employee;


SELECT
    emp_name,
    salary,
    ISNULL(salary, 0) AS salary_using_isnull,
    COALESCE(salary, 0) AS salary_using_coalesce
FROM labTest.employee;

/*
For Priya:
salary = NULL

ISNULL  -> 0
COALESCE -> 0

Both give same result.
*/



/*=========================================================
  EXAMPLE 2 : MULTIPLE FALLBACK VALUES
=========================================================*/

SELECT
   *
FROM labTest.employee;

SELECT
    emp_name,
    email,
    phone,
    COALESCE(email, phone, 'Contact Not Available')
        AS preferred_contact,
		ISNULL(email,'Contact Not Available done by isNUll') as isnullCol    -- Works for only a single column , means we'l;l have ot use two columns for emaila nd phone while Coalesce usese a single one for both
FROM labTest.employee;

/*
Anubhaw -> email available
Rahul   -> email NULL, phone returned
Priya   -> both NULL, default text returned

ISNULL cannot do this in one function call.
*/



/*=========================================================
  EXAMPLE 3 : DATA TYPE DIFFERENCE
=========================================================*/

DECLARE @nickName VARCHAR(5);

SET @nickName = NULL;

/* ISNULL takes datatype of FIRST argument */
SELECT
    ISNULL(@nickName, 'ABCDEFGHIJ') AS isnull_result;

/*
Result:
ABCDE

Why?
@nickName is VARCHAR(5)
Therefore ISNULL returns VARCHAR(5)
String gets truncated.
*/



/*=========================================================
  EXAMPLE 4 : COALESCE DATA TYPE BEHAVIOUR
=========================================================*/

DECLARE @nickName2 VARCHAR(5);

SET @nickName2 = NULL;

SELECT
    COALESCE(@nickName2,
             CAST('ABCDEFGHIJ' AS VARCHAR(10)))
             AS coalesce_result;

/*
Result:
ABCDEFGHIJ

No truncation.
COALESCE determines datatype differently.
*/



/*=========================================================
  EXAMPLE 5 : REAL-LIFE CONTACT SEARCH
=========================================================*/
SELECT
   *
FROM labTest.employee;

SELECT
    emp_id,
    emp_name,
    COALESCE(
        email,
        phone,
        nickname,
        'NO CONTACT DETAILS'
    ) AS first_available_contact
FROM labTest.employee;

/*
Checks in order:

1. email
2. phone
3. nickname
4. default text

Returns first non-NULL value.
*/



/*=========================================================
  BONUS : SEE DATA
=========================================================*/

SELECT *
FROM labTest.employee;


SELECT
    emp_id,
    emp_name,
    IIF(emp_id % 2 = 0, 'Even', 'Odd') AS IdType
FROM labTest.employee;


SELECT
	 LEFT(emp_name,3)  +
	 RIGHT(emp_name,4) as AddedName ,
    SUBSTRING(emp_name,0,4) as shortName,
	 LEFT(emp_name,3) as LeftTruncatedName,
	 RIGHT(emp_name,4) as RightTruncatedName,
	  LTRIM(emp_name) as LTrimmedName,
	  REPLACE(emp_name,'A','B') as ReplacedName,
    salary,
    IIF(
        salary >= 80000,
        'Excellent',
        IIF(
            salary >= 50000,
            'Good',
            IIF(
                salary >= 30000,
                'Average',
                'Poor'
            )
        )
    ) AS SalaryGrade
FROM labTest.employee;

select LTRIM('           SQL             SERVER   ') as LTrimmed
SELECT REPLACE(
    'I love SQL Server',
    'love',
    'am learning'
) AS ModifiedSentence;

SELECT STUFF(
    'I love SQL Server',
    3,
    4,
    'like'
) AS ModifiedSentence;

DECLARE @d DATE = '2026-09-25';

SELECT
    FORMAT(@d, 'dd/MM/yyyy') AS Format1,
    FORMAT(@d, 'MM/dd/yyyy') AS Format2,
    FORMAT(@d, 'dd-MMM-yyyy') AS Format3,
    FORMAT(@d, 'dddd') AS DayName,
    FORMAT(@d, 'MMMM') AS MonthName,
    FORMAT(@d, 'yyyy') AS YearOnly;


	DECLARE @t DATETIME = GETDATE();

SELECT
    FORMAT(@t, 'HH:mm:ss') AS TwentyFourHour,
    FORMAT(@t, 'hh:mm:ss tt') AS TwelveHour,
    FORMAT(@t, 'HH:mm') AS HoursMinutes;


	DECLARE @n DECIMAL(12,2) = 1234567.89;

SELECT
    FORMAT(@n, 'N')  AS NumberDefault,
    FORMAT(@n, 'N0') AS NoDecimals,
    FORMAT(@n, 'N3') AS ThreeDecimals;



	DECLARE @amount DECIMAL(10,2) = 54000.75;

SELECT
    FORMAT(@amount, 'C') AS CurrencyDefault,
    FORMAT(@amount, 'C0') AS CurrencyNoDecimal;

	DECLARE @p DECIMAL(5,4) = 0.875;

SELECT
    FORMAT(@p, 'P') AS Percentage,
    FORMAT(@p, 'P1') AS OneDecimalPlace;


	SELECT FORMAT(1234567, 'E');
	SELECT FORMAT(9876543210, '(###) ###-####');
	SELECT FORMAT(123, '000000');

	SELECT FORMAT(50000, 'C', 'en-IN');
	SELECT FORMAT(50000, 'C', 'en-US');


	SELECT
    emp_name,
    salary,
    FORMAT(salary, 'C', 'en-IN') AS SalaryInRupees,
    FORMAT(salary, 'N2') AS SalaryWithCommas
FROM labTest.employee;

SELECT FORMAT(GETDATE(), 'dd-MMM-yyyy hh:mm:ss tt') as formattedDate;

select DATEDIFF(DAY, '2026-09-01', '2026-09-25') as differenceDate


DECLARE @id UNIQUEIDENTIFIER;
SET @id = NEWID();
SELECT @id AS GUID;



SELECT * FROM (
SELECT *, RANK () OVER ( 
PARTITION BY emp_id
ORDER BY salary DESC
) salRank 
FROM labTest.employee
) t
WHERE salRank <= 3




SELECT * FROM ( 
SELECT *, DENSE_RANK () 
OVER ( PARTITION BY category  ORDER BY vocLevel DESC ) price_rank 
FROM labTest.products as p
) t 
--WHERE price_rank < 3;

select * from labTest.products