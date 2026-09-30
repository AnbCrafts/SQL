select * from sales.order_items
select * from sales.staffs
select * from sales.orders

create function sales.udfGetNetSale(
 @quant int,
 @list_price dec(10,2),
 @discount dec(10,2)
)
returns dec(10,2)
as 
begin
return @quant * @list_price * (1-@discount);
end;

select sales.udfGetNetSale(10,90000,0.2) as net_sale;


-- a fun to return total no. of orders geerated by an individual staff using staff id as parameter and a particular year



--create function sales.udfGettotalOrdergeneratedByStaffYearWise( @staffID int , @year int)
--returns dec(10,2)
--as begin 
		
--	( select SUM(o.order_id) from sales.orders as o where o.staff_id = @staffID and GETDATE(YEAR,o.order_date) = @year)
--end;



CREATE FUNCTION sales.udfGettotalOrdergeneratedByStaffYearWise2
(
    @staffID INT,
    @year INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @total DECIMAL(10,2);

    SELECT @total = COUNT(o.order_id)
    FROM sales.orders AS o
    WHERE o.staff_id = @staffID
      AND YEAR(o.order_date) = @year;

    RETURN ISNULL(@total, 0);
END;

select sales.udfGettotalOrdergeneratedByStaffYearWise2(2,2018) as empSale


select * from sales.orders where staff_id =1 and YEAR(order_date) = 2018


create function AGE3(@DOB date)
returns int
as begin 
declare @age int;
set @age = DATEDIFF(year,@DOB,GETDATE()) --case when (MONTH(@DOB)>6) then 1 else 0 end

return @age
end

select dbo.AGE3('2003/05/22') as age

