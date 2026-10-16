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
  FROM [AssignmentDB].[labTest].[QueryUser]



  DECLARE @Counter INT = 1;

WHILE @Counter <= 100
BEGIN
    INSERT INTO labTest.QueryUser
    (
        UserName,
        Email,
        FullName,
        MobileNo,
        City,
        StateName,
        Country,
        Gender,
        QueryText,
        CreatedDate,
        IsActive
    )
    VALUES
    (
        'user' + CAST(@Counter AS VARCHAR(10)),
        'user' + CAST(@Counter AS VARCHAR(10)) + '@gmail.com',
        'User Name ' + CAST(@Counter AS VARCHAR(10)),
        '98' + RIGHT('00000000' + CAST(@Counter AS VARCHAR(8)), 8),

        CASE (@Counter % 10)
            WHEN 0 THEN 'Kolkata'
            WHEN 1 THEN 'Delhi'
            WHEN 2 THEN 'Mumbai'
            WHEN 3 THEN 'Chennai'
            WHEN 4 THEN 'Bengaluru'
            WHEN 5 THEN 'Pune'
            WHEN 6 THEN 'Hyderabad'
            WHEN 7 THEN 'Ahmedabad'
            WHEN 8 THEN 'Jaipur'
            ELSE 'Lucknow'
        END,

        CASE (@Counter % 10)
            WHEN 0 THEN 'West Bengal'
            WHEN 1 THEN 'Delhi'
            WHEN 2 THEN 'Maharashtra'
            WHEN 3 THEN 'Tamil Nadu'
            WHEN 4 THEN 'Karnataka'
            WHEN 5 THEN 'Maharashtra'
            WHEN 6 THEN 'Telangana'
            WHEN 7 THEN 'Gujarat'
            WHEN 8 THEN 'Rajasthan'
            ELSE 'Uttar Pradesh'
        END,

        'India',

        CASE
            WHEN @Counter % 2 = 0 THEN 'Male'
            ELSE 'Female'
        END,

        CASE (@Counter % 5)
            WHEN 0 THEN 'Need product pricing information.'
            WHEN 1 THEN 'Unable to login to account.'
            WHEN 2 THEN 'Please arrange a callback.'
            WHEN 3 THEN 'Need invoice copy.'
            ELSE 'Website performance feedback.'
        END,

        DATEADD(DAY, -(@Counter % 365), GETDATE()),

        1
    );

    SET @Counter = @Counter + 1;
END

delete from labTest.QueryUser where Gender = 'Female'

ALTER TABLE labTest.QueryUser
ADD QueryAmount DECIMAL(18,2) default 7800;

select * from labTest.QueryUser