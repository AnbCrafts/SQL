/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UserId]
      ,[UserName]
      ,[Email]
      ,[FullName]
      ,[MobileNo]
      ,[City]
      ,[StateName]
      ,[Country]
      ,[Gender]
      ,[QueryText]
      ,[CreatedDate]
      ,[IsActive]
      ,[QueryAmount]
  FROM [AssignmentDB].[labTest].[QueryUser]



  CREATE PROCEDURE sp_SearchUsers
(
    @SearchBy VARCHAR(50),
    @SearchValue VARCHAR(100)
)
AS
BEGIN

    IF @SearchBy = 'FullName'
    BEGIN
        SELECT *
        FROM labTest.QueryUser
        WHERE FullName LIKE '%' + @SearchValue + '%'
    END

    ELSE IF @SearchBy = 'Email'
    BEGIN
        SELECT *
        FROM labTest.QueryUser
        WHERE Email LIKE '%' + @SearchValue + '%'
    END

    ELSE IF @SearchBy = 'City'
    BEGIN
        SELECT *
        FROM labTest.QueryUser
        WHERE City LIKE '%' + @SearchValue + '%'
    END

    ELSE IF @SearchBy = 'Country'
    BEGIN
        SELECT *
        FROM labTest.QueryUser
        WHERE Country LIKE '%' + @SearchValue + '%'
    END

END