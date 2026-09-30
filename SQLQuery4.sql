CREATE FUNCTION 
fn_GetProductnamesById (@productId 
INT)
RETURNS TABLE
AS
RETURN
(
    SELECT p.productName
    FROM labTest.products as p
    WHERE productId = @productId
);

SELECT *
FROM fn_GetProductnamesById(3);

--Q1
SELECT
    p.productName,
    pv.variantId,
    pv.mrp
FROM Assignment.productVariant pv
CROSS APPLY fn_GetProductnamesById(pv.productId) p
WHERE pv.mrp =
(
    SELECT MAX(pv2.mrp)
    FROM Assignment.productVariant pv2
    WHERE pv2.productId = pv.productId
);

--Q2

INSERT INTO Assignment.productVariant
(
    productId,
    baseType,
    packSize,
    skuCode,
    unitCost,
    mrp
)
VALUES
(1, 'Water', 1.00, 'APS-001', 250.00, 350.00),
(1, 'Water', 5.00, 'APS-002', 900.00, 1200.00),

(2, 'Oil',   1.00, 'RYT-001', 300.00, 450.00),
(2, 'Oil',   5.00, 'RYT-002', 1200.00, 1800.00),

(3, 'Water', 10.00, 'WGD-001', 1500.00, 2200.00),
(3, 'Water', 20.00, 'WGD-002', 2500.00, 3500.00),

(4, 'Oil',   1.00, 'LXD-001', 450.00, 650.00),
(4, 'Oil',   5.00, 'LXD-002', 1700.00, 2400.00),

(5, 'Water', 1.00, 'ULP-001', 500.00, 750.00),
(5, 'Water', 10.00, 'ULP-002', 3500.00, 5000.00);

SELECT
    p.productName,
    pv.skuCode,
    pv.mrp
FROM Assignment.productVariant pv
OUTER APPLY fn_GetProductnamesById(pv.productId) p
WHERE pv.mrp =
(
    SELECT MIN(pv2.mrp)
    FROM Assignment.productVariant pv2
    WHERE pv2.productId = pv.productId
);


--Q3
select * from labTest.raw_materials


ALTER TABLE labTest.raw_materials
ADD tags NVARCHAR(500)
    CONSTRAINT DF_raw_materials_tags
    DEFAULT ('["hazardous"]');


	create function fn_GetTagsByMaterialID2 (@mat_id int )
	returns table
	as
	return (
	SELECT rm.tags, rm.material_id
    FROM labTest.raw_materials as rm
    WHERE rm.material_id = @mat_id
	)

SELECT
    rm2.material_id,
    s.value AS tag
FROM labTest.raw_materials rm
CROSS APPLY fn_GetTagsByMaterialID2(rm.material_id) rm2
CROSS APPLY STRING_SPLIT(
    REPLACE(
        REPLACE(
            REPLACE(rm2.tags, '[', ''),
        ']', ''),
    '"', ''),
',') s;









SELECT  product_name, list_price, category_id
FROM production.products p1
WHERE list_price IN ( SELECT MAX (p2.list_price)
FROM production.products p2
WHERE p2.category_id = p1.category_id
GROUP BY p2.category_id )
ORDER BY category_id, product_name;



SELECT  product_name, list_price
FROM production.products
WHERE product_id = ANY ( SELECT product_id
FROM sales.order_items
WHERE quantity >= 2 )
ORDER BY product_name;


SELECT AVG (list_price) avg_list_price
FROM production.products
GROUP BY brand_id
ORDER BY avg_list_price;


SELECT product_name,list_price
FROM production.products
WHERE list_price > ALL (
SELECT  AVG (list_price) avg_list_price
FROM production.products
GROUP BY brand_id )
ORDER BY list_price;

select * from labTest.products


