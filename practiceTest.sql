SELECT TOP (1000) [ParentPartID]
      ,[ChildPartID]
      ,[QuantityRequired]
  FROM [Practice].[dbo].[BillOfMaterials]


  create proc udp_GetBOMByMaterialParentID
  @id int,
  @message varchar(100) out
  as
  begin 
  declare @count int;
  select * from [dbo].[BillOfMaterials] as bom where bom.ParentPartID = @id;
  set @count = @@ROWCOUNT
  if @count >0
  set @message = 'Found ' + CAST(@count as varchar(10)) + ' rows for this table'
  end;

  declare @m varchar(100)
  exec udp_GetBOMByMaterialParentID 300 , @m

  print(@m)