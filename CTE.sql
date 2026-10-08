/****** Script for SelectTopNRows command from SSMS  ******/
select * from Assignment.products_new

WITH cte_Products AS
(
    SELECT
        p.category,
        AVG(p.unit_cost) AS AvgUnitCost
    FROM Assignment.products_new p
    GROUP BY p.category
),
cte_Rank AS
(
    SELECT
        category,
        AvgUnitCost,
        DENSE_RANK() OVER (ORDER BY AvgUnitCost DESC) AS rnk
    FROM cte_Products
)
SELECT
    category,
    AvgUnitCost
FROM cte_Rank
WHERE rnk = 2;


--Q1

--select * from sales.orders
select * from sales.order_items

with cte_Order_items_totalRevenue(orderIds,totalRevenue) 
as 
(
select oi.order_id,
SUM(oi.quantity*oi.list_price*(1-oi.discount)) 
from sales.order_items 
as oi 
group by oi.order_id
), 
cte_Order_items_AvgRevenue (orderIds,avgRevenue)
as
(select oi.order_id ,
Avg(oi.list_price*(1-oi.discount))  
from sales.order_items 
as oi 
group by oi.order_id
)
select orderIds, totalRevenue 
from cte_Order_items_totalRevenue 
as trv inner join 
cte_Order_items_AvgRevenue 
as arv 
on trv.orderIds = arv.orderIds 
where trv.totalRevenue>arv.avgRevenue;




---Corrected Q1

WITH cte_Order_items_totalRevenue AS
(
    SELECT
        oi.order_id AS orderIds,
        SUM(oi.quantity * oi.list_price * (1 - oi.discount)) AS totalRevenue
    FROM sales.order_items oi
    GROUP BY oi.order_id
),
cte_Order_items_AvgRevenue AS
(

--gives average per order
	--SELECT
       -- AVG(oi.quantity * oi.list_price * (1 - oi.discount)) AS avgRevenue     
    --FROM sales.order_items oi


	--gives average per group
	SELECT
        AVG(totalRevenue) AS avgRevenue
    FROM cte_Order_items_totalRevenue
)

SELECT
    trv.orderIds,
    trv.totalRevenue
FROM cte_Order_items_totalRevenue trv, cte_Order_items_AvgRevenue as a
WHERE trv.totalRevenue >=a.avgRevenue --(select avgRevenue from cte_Order_items_AvgRevenue );




--Q2

with cte_discountedCategoryrank
as
(
select 
oi.item_id as ItemId,
oi.order_id as OrderId,
oi.discount as Discount,
SUM(oi.list_price*oi.quantity*(1-oi.discount)) as NetPrice,
DENSE_RANK()over(partition by(oi.order_id) order by oi.discount desc) as rnk
from 
sales.order_items 
as oi 
group by oi.order_id , oi.discount, oi.item_id
)
select  * from cte_discountedCategoryrank where rnk = 1

