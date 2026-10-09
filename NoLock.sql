/****** Script for SelectTopNRows command from SSMS  ******/



  BEGIN TRAN
UPDATE [labTest].[tblOrder] SET ProductName = 'Sample via trn1' WHERE CustomerId between 41000 and 42000

rollback tran
--commit tran


