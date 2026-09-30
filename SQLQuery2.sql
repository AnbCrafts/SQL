create schema Assignment

create table Assignment.products (        
[productId] INT PRIMARY KEY IDENTITY,
[productName] varchar(100) NOT NULL,
[category] VARCHAR (15) NOT NULL CONSTRAINT check_valid_category_ CHECK (category IN ('Exterior','Interior','Dual')) ,
[finishType] VARCHAR(50) NOT NULL,
[binderType] VARCHAR(50) NOT NULL,
[vocLevel] decimal(5,2) NOT NULL,
--[createdAt] TIMESTAMP CONSTRAINT check_valid_timestamp DEFAULT (CURRENT_TIMESTAMP)
[createdAt] DATE CONSTRAINT check_valid_timestamp DEFAULT (CURRENT_TIMESTAMP)
)

insert into Assignment.products values('Apex Shield','Exterior','Satin','Pure Acrylic',45.00,'2026-09-12')



create table Assignment.productVariant(
[variantId] INT PRIMARY KEY IDENTITY,
[productId] INT NOT NULL,
FOREIGN KEY ([productId]) REFERENCES HR.products([productId]),
[baseType] VARCHAR(20) NOT NULL,
[packSize] decimal(5,2) NOT NULL,
[skuCode] VARCHAR(30) NOT NULL UNIQUE,
[unitCost] decimal(10,2) NOT NULL,
[mrp] decimal(10,2) NOT NULL,
)
insert into Assignment.productVariant values(1,'Pastel Blue',5 ,'AS-EXT-W-5L',2000,4000)

select * from Assignment.products
select * from Assignment.productVariant

select * from Assignment.products  INNER JOIN Assignment.productVariant ON Assignment.products.productId = Assignment.productVariant.productId

--*****************
select p.productName,pv.skuCode from Assignment.products as p INNER JOIN Assignment.productVariant as pv ON p.productId = pv.productId




CREATE TABLE raw_materials
(
    material_id INT PRIMARY KEY IDENTITY(1,1),
    material_name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL
        CHECK (type IN ('Pigment', 'Binder', 'Solvent', 'Additive')),
    unit_of_measure VARCHAR(10) NOT NULL,
    reorder_level DECIMAL(10,2) NOT NULL,
    hazardous_flag BIT NOT NULL DEFAULT 0
);


CREATE TABLE formulas
(
    formula_id INT PRIMARY KEY IDENTITY(1,1),
    product_id INT NOT NULL,
    base_type VARCHAR(20) NOT NULL,
    yield_liters DECIMAL(10,2) NOT NULL,
    version VARCHAR(10) NOT NULL
);

CREATE TABLE formula_items
(
    formula_item_id INT PRIMARY KEY IDENTITY(1,1),
    formula_id INT NOT NULL,
    material_id INT NOT NULL,
    quantity DECIMAL(10,4) NOT NULL,
    addition_stage VARCHAR(50) NOT NULL,

    CONSTRAINT FK_formula_items_formula
        FOREIGN KEY (formula_id)
        REFERENCES formulas(formula_id),

    CONSTRAINT FK_formula_items_material
        FOREIGN KEY (material_id)
        REFERENCES raw_materials(material_id)
);


CREATE TABLE color_shades
(
    shade_id INT PRIMARY KEY IDENTITY(1,1),
    shade_code VARCHAR(20) UNIQUE NOT NULL,
    shade_name VARCHAR(100) NOT NULL,
    hex_value CHAR(7) NOT NULL,
    is_exterior_durable BIT NOT NULL
);

CREATE TABLE batch_production
(
    batch_id INT PRIMARY KEY IDENTITY(1,1),
    batch_number VARCHAR(30) UNIQUE NOT NULL,
    formula_id INT NOT NULL,
    quantity_produced DECIMAL(10,2) NOT NULL,
    manufacture_date DATE NOT NULL,

    qc_status VARCHAR(15) NOT NULL
        DEFAULT 'Pending'
        CHECK (qc_status IN ('Pending', 'Approved', 'Rejected')),

    CONSTRAINT FK_batch_formula
        FOREIGN KEY (formula_id)
        REFERENCES formulas(formula_id)
);


CREATE TABLE qc_test_logs
(
    log_id INT PRIMARY KEY IDENTITY(1,1),
    batch_id INT NOT NULL,
    test_parameter VARCHAR(50) NOT NULL,
    measured_value VARCHAR(50) NOT NULL,
    passed BIT NOT NULL,
    tested_by INT NOT NULL,

    CONSTRAINT FK_qc_batch
        FOREIGN KEY (batch_id)
        REFERENCES batch_production(batch_id)
);


INSERT INTO Assignment.products
(productName, category, finishType, binderType, vocLevel, createdAt)
VALUES
('Apex Shield','Exterior','Satin','Pure Acrylic',45.00,'2026-09-12'),
('Royal Touch','Interior','Matte','Vinyl Acrylic',30.50,'2026-09-10'),
('Weather Guard','Dual','Gloss','Pure Acrylic',40.00,'2026-09-08'),
('Lux Decor','Interior','Eggshell','Styrene Acrylic',25.75,'2026-09-06'),
('Ultra Protect','Exterior','Gloss','Pure Acrylic',50.00,'2026-09-01');


INSERT INTO Assignment.productVariant
(productId, baseType, packSize, skuCode, unitCost, mrp)
VALUES
(1,'White Base',5.00,'AS-EXT-W-5L',2000,4000),
(1,'Deep Base',10.00,'AS-EXT-D-10L',3500,6500),
(2,'White Base',1.00,'RT-INT-W-1L',500,900),
(3,'Pastel Base',5.00,'WG-DUAL-P-5L',2200,4100),
(5,'White Base',20.00,'UP-EXT-W-20L',7000,12000);

INSERT INTO raw_materials
(material_name, type, unit_of_measure, reorder_level, hazardous_flag)
VALUES
('Titanium Dioxide','Pigment','KG',100.00,0),
('Red Iron Oxide','Pigment','KG',50.00,0),
('Pure Acrylic Binder','Binder','L',200.00,0),
('Mineral Spirit','Solvent','L',150.00,1),
('Defoamer X1','Additive','L',25.00,1),
('Blue Colorant','Pigment','KG',40.00,0);


INSERT INTO formulas
(product_id, base_type, yield_liters, version)
VALUES
(1,'White Base',1000,'V1.0'),
(1,'Deep Base',1000,'V1.1'),
(2,'White Base',750,'V1.0'),
(3,'Pastel Base',1200,'V2.0'),
(5,'White Base',1500,'V1.0');

INSERT INTO color_shades
(shade_code, shade_name, hex_value, is_exterior_durable)
VALUES
('SH001','Ocean Blue','#1E90FF',1),
('SH002','Forest Green','#228B22',1),
('SH003','Ivory White','#FFFFF0',0),
('SH004','Sunset Orange','#FF8C00',1),
('SH005','Rose Pink','#FF66CC',0);

INSERT INTO batch_production
(batch_number, formula_id, quantity_produced, manufacture_date, qc_status)
VALUES
('BT2026001',1,950.00,'2026-09-01','Approved'),
('BT2026002',2,980.00,'2026-09-02','Pending'),
('BT2026003',3,720.00,'2026-09-04','Approved'),
('BT2026004',4,1180.00,'2026-09-07','Rejected'),
('BT2026005',5,1490.00,'2026-09-10','Approved');


INSERT INTO qc_test_logs
(batch_id, test_parameter, measured_value, passed, tested_by)
VALUES
(1,'Viscosity','95 KU',1,101),
(1,'pH','8.5',1,101),

(2,'Viscosity','90 KU',1,102),

(3,'Opacity','98%',1,103),

(4,'Dry Film Thickness','35 Micron',0,104),

(5,'Gloss','87 GU',1,105),

(5,'Washability','1500 Cycles',1,105);


CREATE TABLE shade_recipes
(
    recipe_id INT PRIMARY KEY IDENTITY(1,1),

    shade_id INT NOT NULL,
    product_id INT NOT NULL,
    colorant_id INT NOT NULL,

    shots_per_liter DECIMAL(8,4) NOT NULL,

    CONSTRAINT FK_shade_recipes_shade
        FOREIGN KEY (shade_id)
        REFERENCES color_shades(shade_id),

    CONSTRAINT FK_shade_recipes_colorant
        FOREIGN KEY (colorant_id)
        REFERENCES raw_materials(material_id)
);

ALTER TABLE shade_recipes
ADD CONSTRAINT FK_shade_recipes_product
FOREIGN KEY (product_id)
REFERENCES Assignment.products(productId);


INSERT INTO shade_recipes
(shade_id, product_id, colorant_id, shots_per_liter)
VALUES
(1,1,6,12.5000),  -- Ocean Blue
(2,1,2,8.2500),   -- Forest Green
(3,2,1,5.0000),   -- Ivory White
(4,3,2,10.7500),  -- Sunset Orange
(5,4,2,7.5000);   -- Rose Pink


SELECT * FROM Assignment.products;

SELECT * FROM Assignment.productVariant;

SELECT * FROM raw_materials;

SELECT * FROM formulas;

SELECT * FROM formula_items;

SELECT * FROM color_shades;

SELECT * FROM shade_recipes;

SELECT * FROM batch_production;

SELECT * FROM qc_test_logs;



--Q1
select p.productName,pv.skuCode,pv.variantId from Assignment.products as p INNER JOIN Assignment.productVariant as pv ON p.productId = pv.productId

--Q2
select p.productName,COUNT(pv.variantId) as variantNeeded from Assignment.products as p INNER JOIN Assignment.productVariant as pv ON p.productId = pv.productId GROUP BY p.productName having COUNT(pv.variantId)>=1;

--Q3
select p.productName,pv.skuCode from Assignment.products as p LEFT JOIN Assignment.productVariant as pv ON p.productId = pv.productId

--Q4
select p.productName,pv.skuCode from Assignment.products as p LEFT JOIN Assignment.productVariant as pv ON p.productId = pv.productId where pv.variantId is null

--Q5

select p.productName,pv.skuCode from Assignment.products as p RIGHT JOIN Assignment.productVariant as pv ON p.productId = pv.productId 

--Q6

CREATE TABLE Assignment.raw_materials_new
(
    material_id INT PRIMARY KEY IDENTITY(1,1),
    material_name VARCHAR(100) NOT NULL,
	parent_material_name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL
        CHECK (type IN ('Pigment', 'Binder', 'Solvent', 'Additive')),
    unit_of_measure VARCHAR(10) NOT NULL,
    reorder_level DECIMAL(10,2) NOT NULL,
    hazardous_flag BIT NOT NULL DEFAULT 0,
	parent_material_id INT 
	
	CONSTRAINT FK_parent
        FOREIGN KEY (parent_material_id)
        REFERENCES Assignment.raw_materials_new(material_id),


);

INSERT INTO Assignment.raw_materials_new
(
    material_name,
    parent_material_name,
    type,
    unit_of_measure,
    reorder_level,
    hazardous_flag,
    parent_material_id
)
VALUES
('Titanium Dioxide', 'Root', 'Pigment', 'Kg', 100.00, 0, NULL),
('Acrylic Resin', 'Root', 'Binder', 'Kg', 200.00, 0, NULL),
('Mineral Spirits', 'Root', 'Solvent', 'Ltr', 150.00, 1, NULL),
('Dispersant', 'Root', 'Additive', 'Kg', 50.00, 0, NULL);

INSERT INTO Assignment.raw_materials_new
(
    material_name,
    parent_material_name,
    type,
    unit_of_measure,
    reorder_level,
    hazardous_flag,
    parent_material_id
)
VALUES
('Titanium Dioxide R-902', 'Titanium Dioxide', 'Pigment', 'Kg', 75.00, 0, 1),
('Titanium Dioxide R-960', 'Titanium Dioxide', 'Pigment', 'Kg', 60.00, 0, 1),

('Acrylic Resin AR-100', 'Acrylic Resin', 'Binder', 'Kg', 120.00, 0, 2),
('Acrylic Resin AR-200', 'Acrylic Resin', 'Binder', 'Kg', 140.00, 0, 2),

('Mineral Spirits MS-1', 'Mineral Spirits', 'Solvent', 'Ltr', 80.00, 1, 3),
('Mineral Spirits MS-2', 'Mineral Spirits', 'Solvent', 'Ltr', 90.00, 1, 3),

('Polymeric Dispersant', 'Dispersant', 'Additive', 'Kg', 25.00, 0, 4),
('Wetting Agent', 'Dispersant', 'Additive', 'Kg', 30.00, 0, 4);


select c.material_name, p.material_name from Assignment.raw_materials_new as c inner join Assignment.raw_materials_new as p on c.parent_material_id = p.material_id;


--Q7
select pv.skuCode,pv.productId from Assignment.productVariant as p INNER JOIN Assignment.productVariant as pv ON p.productId = pv.productId and p.mrp !=pv.mrp

--Q8

select * from Assignment.products as p CROSS JOIN Assignment.raw_materials as rm 

--Q9

select * from labTest.raw_materials as rm left JOIN labTest.stg_raw_materials as srm on rm.material_id = srm.material_id cross join labTest.products





CREATE TABLE labTest.orders
(
    order_id INT PRIMARY KEY IDENTITY(1,1),
    customer_id INT NOT NULL,
    order_date DATE NOT NULL,
    order_amount DECIMAL(10,2) NOT NULL
);


INSERT INTO labTest.orders (customer_id, order_date, order_amount)
VALUES
-- Customer 1
(1, '2022-01-15', 1200.00),
(1, '2022-03-10', 800.00),
(1, '2023-07-21', 1500.00),

-- Customer 2
(2, '2022-02-05', 600.00),
(2, '2023-04-12', 950.00),
(2, '2023-11-18', 400.00),
(2, '2024-01-20', 700.00),

-- Other customers (should not appear)
(3, '2022-06-18', 1200.00),
(4, '2023-08-25', 900.00);



SELECT
    customer_id,
    YEAR(order_date) AS order_year,
    COUNT(order_id) AS order_placed
FROM labTest.orders
WHERE customer_id IN (1, 2)
GROUP BY
    customer_id,
    YEAR(order_date)
ORDER BY customer_id;


SELECT customer_id,
       total_orders
FROM
(
    SELECT customer_id,
           COUNT(order_id) AS total_orders
    FROM labTest.orders
    GROUP BY customer_id
) AS order_summary
---WHERE total_orders > 3
group by total_orders,customer_id 
having total_orders = 4


SELECT customer_id,
       YEAR(order_date) AS order_year
FROM labTest.orders
WHERE YEAR(order_date) = 2022

UNION

SELECT customer_id,
       YEAR(order_date) AS order_year
FROM labTest.orders
WHERE YEAR(order_date) = 2023;


SELECT customer_id,
       YEAR(order_date) AS order_year
FROM labTest.orders
WHERE YEAR(order_date) = 2022

UNION

SELECT YEAR(order_date) AS order_year, customer_id
       
FROM labTest.orders
WHERE YEAR(order_date) = 2023;

--1

SELECT 101 AS value_col

UNION

SELECT '102' AS value_col;


--2

SELECT 101,'Anubhaw' AS value_col

UNION

SELECT 101, 'Anubhaw2' AS value_col;


SELECT 101 AS value_col

UNION

SELECT '102' AS value_co2;



--Q1

CREATE TABLE Assignment.raw_materials_new2
(
    material_id INT PRIMARY KEY,
    unit_cost DECIMAL(10,2) NOT NULL,
    quantity_in_stock INT NOT NULL,
    last_restock_date DATE NOT NULL,
    
    CONSTRAINT FK_raw_materials_new2_material
    FOREIGN KEY (material_id)
    REFERENCES Assignment.raw_materials_new(material_id)
);


INSERT INTO Assignment.raw_materials_new2
(
    material_id,
    unit_cost,
    quantity_in_stock,
    last_restock_date
)
VALUES
(1, 25.50, 500, '2026-08-15'),
(2, 150.00, 120, '2026-09-01'),
(3, 75.25, 300, '2026-08-28'),
(4, 450.00, 50, '2026-09-10'),
(5, 12.75, 1000, '2026-07-20'),
(6, 99.99, 200, '2026-08-05'),
(7, 18.40, 750, '2026-09-12'),
(8, 320.00, 80, '2026-08-18'),
(9, 8.90, 1500, '2026-09-03'),
(10, 55.50, 400, '2026-08-25');

select rm.material_id, SUM(rm.unit_cost*rm.quantity_in_stock) as netValue 
from Assignment.raw_materials_new2 as rm 
group by rm.material_id


--Q2
CREATE TABLE Assignment.products_new
(
    product_id INT PRIMARY KEY IDENTITY(1,1),
    product_name VARCHAR(100) NOT NULL,
    category VARCHAR(50) NOT NULL,
    selling_price DECIMAL(10,2) NOT NULL,
    volume DECIMAL(10,2) NOT NULL,
    unit_cost DECIMAL(10,2) NOT NULL
);

CREATE TABLE Assignment.productvariant_new
(
    variant_id INT PRIMARY KEY IDENTITY(1,1),
    product_id INT NOT NULL,
    material_id INT NOT NULL,
    volume_required DECIMAL(10,2) NOT NULL,
    unit_cost DECIMAL(10,2) NOT NULL,

    CONSTRAINT FK_productvariant_product
        FOREIGN KEY(product_id)
        REFERENCES Assignment.products_new(product_id),

    CONSTRAINT FK_productvariant_material
        FOREIGN KEY(material_id)
        REFERENCES Assignment.raw_materials_new(material_id)
);


INSERT INTO Assignment.products_new
(
    product_name,
    category,
    selling_price,
    volume,
    unit_cost
)
VALUES
('Steel Cabinet', 'Furniture', 15000, 2.50, 9000),
('Office Chair', 'Furniture', 5000, 1.20, 2800),
('Laptop Stand', 'Accessories', 1200, 0.30, 650),
('Storage Rack', 'Furniture', 10000, 3.50, 6000),
('Electrical Panel', 'Electronics', 25000, 1.80, 17000);

INSERT INTO Assignment.productvariant_new
(
    product_id,
    material_id,
    volume_required,
    unit_cost
)
VALUES
(1,1,100,25.50),
(1,3,20,75.25),

(2,1,30,25.50),
(2,6,15,99.99),

(3,3,10,75.25),
(3,10,5,55.50),

(4,1,150,25.50),
(4,5,50,12.75),

(5,8,25,320.00),
(5,3,40,75.25);

select p.product_name, ROUND(SUM(p.unit_cost*p.volume),2) as TotalVal 
from Assignment.products_new as p 
group by p.product_name

--Q3
select pv.product_id, AVG(p.selling_price) as avgVal from Assignment.products_new as p join Assignment.productvariant_new as pv on p.product_id=pv.product_id group by pv.product_id

--Q4
select * from Assignment.raw_materials

select rm.material_name , AVG(rm.reorder_level) 
from Assignment.raw_materials as rm 
where rm.hazardous_flag = 1 
group by rm.material_name  

--Q5
select pv.product_id, 
COUNT(pv.variant_id) as countOfVariants 
from Assignment.productvariant_new as pv 
group by pv.product_id 
having count(pv.variant_id)>1

--Q6
select COUNT(distinct rm.material_id) as NumberOfDistID
from 
labTest.raw_materials as rm 
except 
select COUNT(distinct srm.material_id) as NumberOfDistID
from 
labTest.stg_raw_materials as srm 

--Q7

select p.productName,  MAX(pv.unit_cost) as price from Assignment.productvariant_new as pv join Assignment.products as p on pv.product_id = p.productId group by p.productName 

--Q8

select srm.material_name, MIN(srm.reorder_level) as minReorderLVL from labTest.stg_raw_materials as srm group by srm.material_name

--Q9

select rm.material_id from labTest.raw_materials as rm
union 
select srm.material_id from labTest.stg_raw_materials as srm

--Q10
select distinct p.productName from Assignment.products as p
union
select distinct rm.material_name from Assignment.raw_materials as rm

--select distinct p.productName + ' ' +  rm.material_name  from Assignment.products as p inner join Assignment.raw_materials as rm on p.productId = rm.material_id
--Q11
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            
select pv.skuCode as item_identifier from labTest.productVariant pv
union all
select cast(material_id as varchar(30)) as material from labTest.raw_materials rm

--Q12

select rm.reorder_level as commonVal from labTest.raw_materials as rm
intersect
select  srm.reorder_level as commonVal from labTest.stg_raw_materials as srm


--Q13                                                                        

select  srm.material_id as commonVal from labTest.stg_raw_materials as srm
except
select rm.material_id as commonVal from labTest.raw_materials as rm

--Q14

select rm.material_id as diffval from labTest.raw_materials as rm
except
select  srm.material_id as diffval from labTest.stg_raw_materials as srm
