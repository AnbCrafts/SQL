/****** Script for SelectTopNRows command from SSMS  ******/
SELECT   *
  FROM [AssignmentDB].[labTest].[EmployeeData]


  drop index IX_EmployeeData_EmployeeId on [AssignmentDB].[labTest].[EmployeeData]


  CREATE NONCLUSTERED INDEX IX_EmployeeID
ON labTest.EmployeeData (EmployeeId);

select * from labTest.EmployeeData where EmployeeId = 'abcd'

drop index IX_Employee_Department_Email on labTest.EmployeeData


SELECT   *
  FROM [AssignmentDB].[labTest].[EmployeeData] where Department = 'Finance' and Email = 'employee100022@company.com' --index seek

SELECT   *
  FROM [AssignmentDB].[labTest].[EmployeeData] where Department = 'Finance'  -- index seek

  SELECT   *
  FROM [AssignmentDB].[labTest].[EmployeeData] where Email = 'employee100022@company.com'  -- index scan


    CREATE NONCLUSTERED INDEX IX_City_NONC
ON labTest.EmployeeData (City) 
include(FirstName, LastName, Email, Salary);

--drop index IX_City_NONC on labtest.EmployeeData

select * from labTest.EmployeeData where City = 'Mumbai'


select * from labTest.EmployeeData where LastName = 'LastName_100097'


    CREATE NONCLUSTERED INDEX IX_Employee_Department_Email_NONC
ON labTest.EmployeeData (Department, Email);






