----PATTRERN PRINTING------

--Q1
declare @start int = 1;
declare @end int = 5;
declare @line VARCHAR(100) ;


while @start<@end
begin

set @line = REPLICATE('*',@start);
print(@line)

SET @start +=1;
end

--Q2
DECLARE @start INT = 1;
DECLARE @end INT = 5;
DECLARE @nestedStart INT;
DECLARE @line VARCHAR(100);

WHILE @start < @end
BEGIN
    SET @nestedStart = 0;
    SET @line = '';

    WHILE @nestedStart < @start
    BEGIN
        SET @line += CHAR(ASCII('A') + @nestedStart);
        SET @nestedStart += 1;
    END

    PRINT @line;

    SET @start += 1;
END


--Q3
DECLARE @num INT = 100;
DECLARE @i INT = 2;
DECLARE @isPrime BIT = 1;

IF @num <= 1
    SET @isPrime = 0;

WHILE @i <= SQRT(@num) AND @isPrime = 1
BEGIN
    IF @num % @i = 0
        SET @isPrime = 0;

    SET @i += 1;
END

IF @isPrime = 1
    PRINT CAST(@num AS VARCHAR(10)) + ' is Prime';
ELSE
    PRINT CAST(@num AS VARCHAR(10)) + ' is Not Prime';

--Q4
	CREATE TABLE Assignment.Student
(
    StudentID INT IDENTITY(1,1) PRIMARY KEY,
    StudentName VARCHAR(50) NOT NULL,
    FatherName VARCHAR(50) NOT NULL
);

INSERT INTO Assignment.Student (StudentName, FatherName)
VALUES
('Anubhaw Singh', 'Ashok Gupta'),
('Komal Rajpput', 'Rakesh Gupta'),
('Avijit Pakhira', 'Subhash Pakhira'),
('Priyanka Roy', 'Sanjib Roy'),
('Rahul Sharma', 'Mahesh Sharma'),
('Sneha Das', 'Bimal Das'),
('Amit Kumar', 'Ramesh Kumar'),
('Pooja Singh', 'Rajesh Singh'),
('Rohit Verma', 'Suresh Verma'),
('Neha Paul', 'Tarun Paul');

SELECT * 
FROM Assignment.Student;

select CONCAT(s.StudentName , ' Son of ',s.FatherName) as student_father from Assignment.Student as s;

select s.FatherName, COUNT(s.StudentID) as duplicateStudent  from Assignment.Student as s where s.FatherName in (select s2.FatherName from Assignment.Student as s2 where s.StudentID != s2.StudentID ) group by s.FatherName 

select s.FatherName, COUNT(s.StudentID) as duplicateStudent  from Assignment.Student as s group by s.FatherName having COUNT(s.StudentID) >=2;


--Q5
CREATE TABLE Assignment.Employee
(
    EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
    EmployeeName VARCHAR(50) NOT NULL,
    Department VARCHAR(30),
    Salary DECIMAL(10,2),
    HireMonth VARCHAR(15)
);

INSERT INTO Assignment.Employee
(
    EmployeeName,
    Department,
    Salary,
    HireMonth
)
VALUES
('Anubhaw Gupta', 'IT', 55000, 'January'),
('Komal Gupta', 'HR', 48000, 'March'),
('Avijit Pakhira', 'Finance', 62000, 'January'),
('Rahul Sharma', 'IT', 53000, 'April'),
('Sneha Das', 'HR', 47000, 'March'),
('Amit Kumar', 'Sales', 45000, 'May'),
('Pooja Singh', 'Sales', 50000, 'January'),
('Rohit Verma', 'IT', 70000, 'June'),
('Neha Paul', 'Finance', 58000, 'April'),
('Priyanka Roy', 'HR', 52000, 'May');


WITH CTE AS
(
    SELECT *,
           DENSE_RANK() OVER
           (
               ORDER BY
               CASE HireMonth
                   WHEN 'January' THEN 1
                   WHEN 'February' THEN 2
                   WHEN 'March' THEN 3
                   WHEN 'April' THEN 4
                   WHEN 'May' THEN 5
                   WHEN 'June' THEN 6
                   WHEN 'July' THEN 7
                   WHEN 'August' THEN 8
                   WHEN 'September' THEN 9
                   WHEN 'October' THEN 10
                   WHEN 'November' THEN 11
                   WHEN 'December' THEN 12
               END DESC
           ) AS rnk
    FROM Assignment.Employee
)
SELECT *
FROM CTE
WHERE rnk <= 3;

--Q8
WITH CTE AS
(
    SELECT *,
           DENSE_RANK() OVER
           (
               ORDER BY salary DESC
           ) AS rnk
    FROM Assignment.Employee
)
SELECT *
FROM CTE
WHERE rnk = 6;

--Q7
select e.EmployeeName from Assignment.Employee as e where substring(e.EmployeeName,1,1) = 'A'



--Q6

select isnull(e.ManagerID,'No manager'),COUNT(e.EmployeeID) as empCOUNT from Assignment.Employee as e group by e.ManagerID having e.managerID is not null

