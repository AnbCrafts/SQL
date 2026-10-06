/****** Script for SelectTopNRows command from SSMS  ******/


--Q1

create clustered index IX_OrdeItems_OrderId on sales.order_items(order_id, item_id);
SELECT *
  FROM [BikeStores].[sales].[order_items] 
  where order_id =42;
  drop index IX_OrdeItems_OrderId on sales.[order_items]

--Q2

create clustered index IX_OrdeItems_OrderId_C on sales.order_items(order_id);
SELECT *
  FROM [BikeStores].[sales].[order_items] 
  where order_id between 10000 and 10500;
  
  drop index IX_OrdeItems_OrderId_C on sales.[order_items]

--Q3

   create nonclustered index IX_OrderItems_ProductId_ on sales.[order_items] (product_id) 
  -- 50% -> NC Index seek + 50% key Lookup Clustered ( order_id) when data is not present and 100% NC index seek when data is present

  SELECT *
  FROM [BikeStores].[sales].[order_items] where product_id = 5000;

  drop index IX_OrderItems_ProductId on sales.[order_items]

  --Q4

  create nonclustered index IX_OrderItems_ProductId on sales.[order_items] (product_id) 
  include (quantity,list_price,discount, item_id);  -- 100% -> NC Index seek 
  
  SELECT *
  FROM [BikeStores].[sales].[order_items] where product_id = 505;
   drop index IX_OrderItems_ProductId_ on sales.[order_items]
  
  --Q5

  create nonclustered index IX_OrderItems_Discount on sales.[order_items] (order_id, item_id) 
  include (product_id, quantity,list_price,discount) where discount>0.00;

  SELECT *
  FROM [BikeStores].[sales].[order_items] where discount > 5.00;


