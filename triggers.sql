DROP TRIGGER  trInsertEmployee;


CREATE TRIGGER trInsertEmployee
ON labTest.EmployeeData
FOR INSERT
AS
BEGIN
    PRINT 'INSERT TRIGGER FIRED';

    SELECT *
    FROM inserted;
END

INSERT INTO labTest.EmployeeData
VALUES
(
    'Sample_first_2',
    'Sample_last_2',
    'Nowhere',
    'HR',
    4000000,
    '2026-01-22',
    'sample_2@gmail.com'
);




CREATE TRIGGER 
trInsertEmployeeOnWednesday ON labTest.EmployeeData
FOR INSERT
AS
BEGIN
IF DATEPART(DW,GETDATE())= 4
PRINT 'YOU CANNOT PERFORM INSERT OPERATION ON WEDENSDAY'
ROLLBACK TRANSACTION
END

CREATE TRIGGER 
trDeleteEmployeeOnWednesday ON labTest.EmployeeData
FOR DELETE
AS
BEGIN
IF DATEPART(DW,GETDATE()) = 4
PRINT 'YOU CANNOT PERFORM DELETE OPERATION ON WEDENSDAY'
ROLLBACK TRANSACTION
END


CREATE TRIGGER 
trDeleteEmployee ON labTest.EmployeeData
FOR DELETE
AS
BEGIN
PRINT 'YOU CANNOT PERFORM DELETE OPERATION ON THIS TABLE'
ROLLBACK TRANSACTION
END

delete from labTest.EmployeeData where Email = 'sample@gmail.com'

DROP TRIGGER trInsertEmployee;



CREATE TRIGGER trInsertEmployee2 ON labTest.EmployeeData
FOR INSERT
AS
BEGIN
SELECT * FROM INSERTED
END





CREATE TRIGGER trInsertPersons
ON labTest.Persons
FOR INSERT
AS
BEGIN
    PRINT 'INSERT TRIGGER FIRED';

    SELECT *
    FROM inserted;
END

select * from labTest.Persons

INSERT INTO labTest.Persons values('sample test', 'Address Sample ', 'Delhi',50,4000),('sample test2', 'Address Sample ', 'Kolkata',40,4000);
INSERT INTO labTest.Persons values('sample test2', 'Address Sample ', 'Kolkata',40,4000);

CREATE TRIGGER trInsertPersons_UpdateDelete
ON labTest.Persons
FOR UPDATE,DELETE
AS
BEGIN
    PRINT 'INSERT TRIGGER FIRED';
    SELECT *
    FROM inserted;
	SELECT *
    FROM deleted;
END

update labTest.Persons set FullName = 'Sample 5' where FullName = 'sample test';


CREATE TABLE labTest.EmployeeAudit
(
ID INT IDENTITY(1,1) PRIMARY KEY,
AuditData VARCHAR(MAX),
AuditDate DATETIME
)

drop TABLE labTest.EmployeeAudit

CREATE TRIGGER tr_Employee_For_Delete ON labTest.EmployeeData
FOR DELETE
AS
BEGIN
DECLARE @ID INT
DECLARE @Name VARCHAR(100)
DECLARE @AuditData VARCHAR(100)
SELECT @ID = ID, @Name = Name FROM DELETED
SET @AuditData = 'An employee is deleted with ID  = ' + Cast(@ID AS VARCHAR(10)) + ' and Name = ' + @Name
INSERT INTO labTest.EmployeeAudit (AuditData, AuditDate)VALUES(@AuditData, GETDATE())
END



select * from labTest.EmployeeData