create table labTest.Course
(
courseId int PRIMARY KEY IDENTITY,
courseName Varchar(100) ,
courseDescription VARCHAR(500),
launchDate Date
)

alter proc 
usp_InsertCourseData 
@name varchar(100),
@desc varchar(500),
@lnch date,
@message varchar(100) out

as  
begin
declare @insertedRows int;
insert into labTest.Course values (@name, @desc, @lnch);
set @insertedRows = @@ROWCOUNT
select * from labTest.Course as c where c.courseName = @name and c.courseDescription = @desc and c.launchDate = @lnch;
if(@insertedRows>0)
set @message = 'Successfully inserted row - ' + CAST(@insertedRows as varchar) + ' into the Course table' 
--select * from labTest.Course as c where c.courseId = @@ROWCOUNT

else
set @message = 'Inserting data failed for the Course table!!!'
end;

declare @m varchar(100)
exec usp_InsertCourseData 'Sample Course new 2', 'This is a new sample course description','2026/12/15', @m out

print @m

select * from labTest.Course

--Q1
create proc sup_GetOrdersByCustomer 
@custId int 
as
begin
select o.order_id from sales.orders as o where o.customer_id = @custId
end;

exec sup_GetOrdersByCustomer 2


--Q2

create proc GetOrderDetails

as 
begin 
select o.order_id, oi.item_id, oi.list_price from sales.orders as o inner join sales.order_items as oi on o.order_id = oi.order_id

end;

exec GetOrderDetails;

--Q3

ALTER PROC GetTotalBillForOrder
    @orderId INT,
    @amount DECIMAL(18,2) OUT,
    @message VARCHAR(100) OUT
AS
BEGIN
    SET @amount =
    (
        SELECT SUM(ISNULL(oi.list_price,0) * oi.quantity * (1 - oi.discount))
        FROM sales.order_items AS oi
        WHERE oi.order_id = @orderId
    );

    SET @message =
        'The total amount for this order is -> '
        + CAST(@amount AS VARCHAR(20));
END;


DECLARE @total decimal(10,2);
DECLARE @m VARCHAR(100);

EXEC GetTotalBillForOrder
    @orderId = 1,
    @amount = @total OUT,
    @message = @m OUT;

PRINT @total;
PRINT @m;



--Q4

alter proc UpdateOrderShipmentdate
@shipDate date,
@id int,
@notice varchar(200) out

as 

begin 
--declare @oldDate date = (select * from sales.orders as o where o.order_id = @id);
update sales.orders set shipped_date=@shipDate where order_id = @id 
if @@ROWCOUNT >0
set @notice = 'The update was successful and the shipment date was updated  ' + ' to ' + CAST(@shipDate as varchar)
else
set @notice = 'Updating the date was failed!!'
end;

declare @n varchar(200)
exec UpdateOrderShipmentdate '2026/06/10',2, @n out

print @n

--Q5

alter proc GetStockInfo 
@storeid int ,
@threshold int,
@info varchar(100) out

as
begin 

SELECT
    --MAX(ISNULL(s.,'') + ' / ' + ISNULL(s.phone,'')) AS contactDetails,
    COUNT(p.product_id) AS TotalProducts
FROM production.stocks AS s
INNER JOIN production.products AS p
    ON s.product_id = p.product_id
WHERE s.store_id = @storeid
and s.quantity <= @threshold;

if @@ROWCOUNT>0
set @info = 'Got the information about stock'
else 
set @info = 'No information was obtained'

end;

declare @n varchar(200)

exec GetStockInfo 1,10,@n out

print @n

select * from production.stocks

--Q6


create proc production.usp_ProductDistributionSummary
(
    @ProductId int,
    @TotalGlobalStock int out
)
as
begin
   
    select
        s.store_id,
        s.store_name,
        s.city,
        s.state,
        st.quantity as InventoryQuantity
    from sales.stores s
    INNER JOIN production.stocks st
        on s.store_id = st.store_id
    where st.product_id = @ProductId;

    select
        @TotalGlobalStock = SUM(quantity)
    from production.stocks
    where product_id = @ProductId;
end;


declare @TotalStock int;

exec production.usp_ProductDistributionSummary 1, @TotalStock out
   