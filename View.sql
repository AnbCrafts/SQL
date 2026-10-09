select * from labTest.tblOrder

SELECT *
FROM labTest.tblOrder WITH (NOLOCK);

  BEGIN TRAN
UPDATE [labTest].[tblOrder] SET ProductName = 'Sample via tran2' WHERE CustomerId between 41000 and 42000

rollback tran


----------------------------------------VIEWS----------------------------------------------

create view labTest.viewAllEmployees 
as 
select * from labTest.EmployeeHierarchy

select * from labTest.viewAllEmployees where Department = 'IT'

update labTest.viewAllEmployees set Department = 'Random' where EmployeeId = 7

delete from labTest.viewAllEmployees where ManagerId is null

insert into labtest.viewAllEmployees values (16, 'Robert King 2', 'CEO 2', 'Management', 250000, '2015-01-01', NULL)
----------------------------------------VIEWS----------------------------------------------


