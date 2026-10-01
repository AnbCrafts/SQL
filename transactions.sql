
CREATE PROC spdivide2(
@a decimal,
@b decimal,
@c decimal output
) AS
BEGIN
BEGIN TRY
SET @c = @a / @b;
END TRY
BEGIN CATCH
SELECT  
ERROR_NUMBER() AS ErrorNumber  
,ERROR_SEVERITY() AS ErrorSeverity  
,ERROR_STATE() AS ErrorState  
,ERROR_PROCEDURE() AS ErrorProcedure  
,ERROR_LINE() AS ErrorLine  
,ERROR_MESSAGE() AS ErrorMessage,
XACT_STATE() AS ExactState;

END CATCH
END;

CREATE TABLE labTest.Persons
(
    PersonID INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(100) NOT NULL,
    AddressLine VARCHAR(200),
    City VARCHAR(50),
    Age INT,
    Salary DECIMAL(10,2)
);


DECLARE @r decimal;
EXEC spdivide2 10, 0, @r output;
PRINT @r;


INSERT INTO labTest.Persons
(
    FullName,
    AddressLine,
    City,
    Age,
    Salary
)
VALUES
('Anubhaw Gupta', 'Sector 62', 'Noida', 25, 45000.00),
('Rahul Sharma', 'MG Road', 'Bangalore', 30, 55000.00),
('Priya Verma', 'Civil Lines', 'Delhi', 28, 50000.00),
('Amit Singh', 'Rajendra Nagar', 'Patna', 35, 65000.00),
('Neha Kapoor', 'Salt Lake', 'Kolkata', 27, 48000.00),
('Rohit Kumar', 'Ashok Nagar', 'Chennai', 32, 60000.00),
('Sneha Jain', 'Koregaon Park', 'Pune', 29, 53000.00),
('Vikas Mishra', 'Hazratganj', 'Lucknow', 40, 70000.00),
('Pooja Shah', 'Navrangpura', 'Ahmedabad', 26, 47000.00),
('Karan Mehta', 'Banjara Hills', 'Hyderabad', 31, 62000.00);

set implicit_transactions off
set implicit_transactions on
begin transaction

INSERT INTO labTest.Persons
(
    FullName,
    AddressLine,
    City,
    Age,
    Salary
)
VALUES
('Anubhaw Gupta 10', 'Sector 62', 'Noida', 25, 45000.00),
('Rahul Sharma 10', 'MG Road', 'Bangalore', 30, 55000.00),
('Priya Verma 10', 'Civil Lines', 'Delhi', 28, 50000.00),
('Amit Singh 10', 'Rajendra Nagar', 'Patna', 35, 65000.00)

INSERT INTO labTest.Persons
(
    FullName,
    AddressLine,
    City,
    Age,
    Salary
)
VALUES
('Anubhaw Gupta 11', 'Sector 62', 'Noida', 25, 45000.00),
('Rahul Sharma 11', 'MG Road', 'Bangalore', 30, 55000.00),
('Priya Verma 11', 'Civil Lines', 'Delhi', 28, 50000.00),
('Amit Singh 11', 'Rajendra Nagar', 'Patna', 35, 65000.00)
COMMIT TRAN



select * from labTest.Persons
begin transaction
INSERT INTO labTest.Persons
(
    FullName,
    AddressLine,
    City,
    Age,
    Salary
)


VALUES
('Anubhaw Gupta 12', 'Sector 62', 'Noida', 25, 45000.00),
('Rahul Sharma 12', 'MG Road', 'Bangalore', 30, 55000.00),
('Priya Verma 12', 'Civil Lines', 'Delhi', 28, 50000.00),
('Amit Singh 12', 'Rajendra Nagar', 'Patna', 35, 65000.00)
ROLLBACK TRAN

ROLLBACK TRAN
set implicit_transactions off

begin try
begin transaction

INSERT INTO labTest.Persons
(
    FullName,
    AddressLine,
    City,
    Age,
    Salary
)
VALUES
('Anubhaw Gupta 4', 'Sector 62', 'Noida', 25, 45000.00),
('Rahul Sharma 4', 'MG Road', 'Bangalore', 30, 55000.00),
('Priya Verma 4', 'Civil Lines', 'Delhi', 28, 50000.00),
('Amit Singh 4', 'Rajendra Nagar', 'Patna', 35, 6500)

commit transaction

end try

begin catch
if(@@TRANCOUNT>0)
select @@trancount
end catch



SELECT @@TRANCOUNT AS TranCount;  -- 0

BEGIN TRANSACTION;
SELECT @@TRANCOUNT AS TranCount;  -- 1

BEGIN TRANSACTION;
SELECT @@TRANCOUNT AS TranCount;  -- 2

BEGIN TRANSACTION;
SELECT @@TRANCOUNT AS TranCount;

--COMMIT;
--SELECT @@TRANCOUNT AS TranCount;  -- 1
COMMIT;
SELECT @@TRANCOUNT AS TranCount;
rollback;
SELECT @@TRANCOUNT AS TranCount;  -- 0


set implicit_transactions on
set implicit_transactions off
select @@TRANCOUNT as t

select * from labTest.Persons

INSERT INTO labTest.Persons
(
    FullName,
    AddressLine,
    City,
    Age,
    Salary
)
VALUES
('Anubhaw Gupta 4', 'Sector 62', 'Noida', 25, 45000.00),
('Rahul Sharma 4', 'MG Road', 'Bangalore', 30, 55000.00),
('Priya Verma 4', 'Civil Lines', 'Delhi', 28, 50000.00),
('Amit Singh 4', 'Rajendra Nagar', 'Patna', 35, 6500)

begin transaction


ROLLBACK TRAN