create function fn_GetOrderFulfilmentStatus(@storeID int)
returns @QueryTable table(
order_id int ,
customer_id int,
order_date date,
required_date date,
shipped_date date,
fullFilment_category varchar(40)
)
as
begin
insert into @QueryTable
select order_id,customer_id,order_date,required_date,shipped_date, 
case 

when (o.shipped_date>o.required_date) then 'Late' 
when(o.shipped_date<o.required_date) then 'Early' 
when(o.shipped_date=o.required_date) then 'On time'  
end
from sales.orders as o where o.store_id= @storeID;



return;
end;


select * from fn_GetOrderFulfilmentStatus(2)


select * from sales.orders



CREATE FUNCTION fn_GetOrderSummary
(
    @start DATE,
    @end DATE
)
RETURNS @QueryTable TABLE
(
    staff_id INT,
    total_orders INT,
    completed_orders INT,
    shipped_orders INT,
    delayed_orders INT,
    avg_shipping_time INT
)
AS
BEGIN

    INSERT INTO @QueryTable
    SELECT
        o.staff_id,

        COUNT(o.order_id) AS total_orders,

        SUM(CASE
                WHEN o.order_status = 1 THEN 1
                ELSE 0
            END) AS completed_orders,

        SUM(CASE
                WHEN o.order_status = 2 THEN 1
                ELSE 0
            END) AS shipped_orders,

        SUM(CASE
                WHEN o.order_status = 3 THEN 1
                ELSE 0
            END) AS delayed_orders,

        AVG(CASE
                WHEN o.shipped_date IS NOT NULL
                THEN DATEDIFF(DAY, o.order_date, o.shipped_date)
            END) AS avg_shipping_time

    FROM sales.orders AS o
    WHERE o.order_date BETWEEN @start AND @end
    GROUP BY o.staff_id;

    RETURN;
END;

SELECT *
FROM dbo.fn_GetOrderSummary('2016-01-01', '2018-12-31');

							select * from sales.orders

create function fn_GetStoreOrderSummary4(@storeID int, @threshold int)
returns table 
as return 
(
select o.order_id,DATEDIFF(DAY,o.order_date , o.shipped_date) as shipping_time  from sales.orders as o where o.store_id = @storeID and DATEDIFF(DAY,o.order_date , o.shipped_date)<=@threshold 
)

select * from fn_GetStoreOrderSummary4(2,2)


create function fn_getdealyuedCustomerOrders2(@custId int)
returns table
as return 
(
select o.order_id,o.customer_id from sales.orders as o where o.customer_id = @custId and (o.required_date<o.shipped_date or o.shipped_date is null)

)

select * from fn_getdealyuedCustomerOrders2(175)