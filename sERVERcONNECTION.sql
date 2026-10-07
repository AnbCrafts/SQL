/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [Name]
      ,[Price]
  FROM [AssignmentDB].[labTest].[Bikeshop]


  select * from labTest.Bikeshop

  drop table labTest.Bikeshop

  create table labTest.Bikeshop
  (
  Id INT PRIMARY KEY IDENTITY,
  Name VARCHAR(100),
  Price INT
  
  )

  --list all bikeshops
  Alter proc ReadAllBikesDataFromDB
  as
  begin
  select Id,Name,Price 
  from labTest.Bikeshop
  end;

  -- list bikeshops by id
  Create proc ReadBikeDataById 
  (
  @id int
  )
  as 
  begin
  select Id,Name,Price 
  from labTest.Bikeshop 
  where Id = @id
  end;
  
  --Add bikeshop
  alter proc AddBikeDataIntoDB 
  (
  @name varchar(100), 
  @price int,
  @message varchar(200) out
  )
  as 
  begin
  insert into labTest.Bikeshop 
  values(@name,@price)
  if @@ROWCOUNT>0
  set @message = 'One bike shop added successfully'
  else
  set @message = 'Failed to add bikeshop'
  end;

  --update bikeshop by id
  alter proc UpdateBikeDataIntoDB 
  (
  @id int,
  @name varchar(100), 
  @price int,
  @notification varchar(200) out
  )
  as 
  begin
  if @name !=''
  update labTest.Bikeshop 
  set Name = @name where Id = @id;
  if @price !=0
  update labTest.Bikeshop 
  set Price = @price  where Id = @id;

  if @@ROWCOUNT>0
  set @notification = CAST(@name as varchar(100)) + ' '  + CAST(@price as varchar(10)) + ' Updated for bike ';
  else 
  set @notification = 'Failed to update bike data '
  end;

  --delete bikeshop by id
  alter proc DeleteBikeDataById 
  (
  @id int,
  @m varchar(200) out
  )
  as 
  begin
  delete 
  from labTest.Bikeshop 
  where Id = @id
  if @@ROWCOUNT >0
  set @m = 'Bike shop with id - '+CAST(@id as varchar(10)) + ' Deleted successfullly'
  else 
  set @m = 'Failed to delete Bike shop with id - '+CAST(@id as varchar(10))  
  end;
