CREATE SCHEMA [labTest];

--Q1.

create table [labTest].[products] (        
[productId] INT PRIMARY KEY IDENTITY,
[productName] varchar(100) NOT NULL,
[category] VARCHAR (15) NOT NULL CONSTRAINT check_valid_category_ CHECK (category IN ('Exterior','Interior','Dual')) ,
[finishType] VARCHAR(50) NOT NULL,
[binderType] VARCHAR(50) NOT NULL,
[vocLevel] decimal(5,2) NOT NULL,
--[createdAt] TIMESTAMP CONSTRAINT check_valid_timestamp DEFAULT (CURRENT_TIMESTAMP)
[createdAt] DATE CONSTRAINT check_valid_timestamp DEFAULT (CURRENT_TIMESTAMP)
)


INSERT INTO [labTest].[products]
(productName, category, finishType, binderType, vocLevel, createdAt)
VALUES
('Apex Shield','Exterior','Satin','Pure Acrylic',45.00,'2026-09-12'),
('Royal Touch','Interior','Matte','Vinyl Acrylic',30.50,'2026-09-10'),
('Weather Guard','Dual','Gloss','Pure Acrylic',40.00,'2026-09-08'),
('Lux Decor','Interior','Eggshell','Styrene Acrylic',25.75,'2026-09-06'),
('Ultra Protect','Exterior','Gloss','Pure Acrylic',50.00,'2026-09-01');

select * from labTest.products

create table [labTest].[exterior_premium_products](
[productId] INT PRIMARY KEY,
[productName] varchar(100) NOT NULL,
[category] VARCHAR (15) NOT NULL CONSTRAINT check_valid_category_in_premium CHECK (category IN ('Exterior','Interior','Dual')) ,
[finishType] VARCHAR(50) NOT NULL,
[binderType] VARCHAR(50) NOT NULL,
[vocLevel] decimal(5,2) NOT NULL,
--[createdAt] TIMESTAMP CONSTRAINT check_valid_timestamp DEFAULT (CURRENT_TIMESTAMP)
[createdAt] DATE CONSTRAINT check_valid_timestamp_premium DEFAULT (CURRENT_TIMESTAMP)
)

drop table [labTest].[exterior_premium_products]
set identity_insert [labTest].[exterior_premium_products] on

insert into [labTest].[exterior_premium_products]
select * from [labTest].[products] as p
where p.category = 'Exterior' AND p.vocLevel<50.00

select * from [labTest].[exterior_premium_products]


--Q2 

CREATE TABLE [labTest].[raw_materials]
(
    material_id INT PRIMARY KEY IDENTITY(1,1),
    material_name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL
        CHECK (type IN ('Pigment', 'Binder', 'Solvent', 'Additive')),
    unit_of_measure VARCHAR(10) NOT NULL,
    reorder_level DECIMAL(10,2) NOT NULL,
    hazardous_flag BIT NOT NULL DEFAULT 0
);


INSERT INTO [labTest].[raw_materials]
(material_name, type, unit_of_measure, reorder_level, hazardous_flag)
VALUES
('Red Colorant','Pigment','KG',600.00,0),
('Titanium Dioxide','Pigment','KG',100.00,0),
('Red Iron Oxide','Pigment','KG',50.00,0),
('Pure Acrylic Binder','Binder','L',200.00,0),
('Mineral Spirit','Solvent','L',150.00,1),
('Defoamer X1','Additive','L',25.00,1),
('Blue Colorant','Pigment','KG',40.00,0);

select * into 
[labtest].[high_cost_raw_materials]
from [labTest].[raw_materials] as rm
where [rm].[reorder_level] >500.00



-- Q3
SET IDENTITY_INSERT labtest.raw_materials ON;


BULK INSERT labtest.high_cost_raw_materials
FROM 'D:\Anubhaw\raw_materials_sample_csv_2.csv'
WITH
(
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);

SET IDENTITY_INSERT labtest.raw_materials OFF;



--Q4

CREATE TABLE [labTest].[formulas]
(
    formula_id INT PRIMARY KEY IDENTITY(1,1),
    product_id INT NOT NULL,
    base_type VARCHAR(20) NOT NULL,
    yield_liters DECIMAL(10,2) NOT NULL,
    version VARCHAR(10) NOT NULL
);

CREATE TABLE [labTest].[formula_items]
(
    formula_item_id INT PRIMARY KEY IDENTITY(1,1),
    formula_id INT NOT NULL,
    material_id INT NOT NULL,
    quantity DECIMAL(10,4) NOT NULL,
    addition_stage VARCHAR(50) NOT NULL,

    CONSTRAINT FK_formula_items_formula_3
        FOREIGN KEY (formula_id)
        REFERENCES  [labTest].[formulas](formula_id),

    CONSTRAINT FK_formula_items_material_3
        FOREIGN KEY (material_id)
        REFERENCES [labTest].[raw_materials](material_id)
);




INSERT INTO [labTest].[products]
(productName, category, finishType, binderType, vocLevel, createdAt)
VALUES
('Apex Shield','Exterior','Satin','Pure Acrylic',45.00,'2026-09-12'),
('Royal Touch','Interior','Matte','Vinyl Acrylic',30.50,'2026-09-10'),
('Weather Guard','Dual','Gloss','Pure Acrylic',40.00,'2026-09-08'),
('Lux Decor','Interior','Eggshell','Styrene Acrylic',25.75,'2026-09-06'),
('Ultra Protect','Exterior','Gloss','Pure Acrylic',50.00,'2026-09-01');


INSERT INTO [labTest].[formulas]
(product_id, base_type, yield_liters, version)
VALUES
(1,'White Base',1000,'V1.0'),
(1,'Deep Base',1000,'V1.1'),
(2,'White Base',750,'V1.0'),
(3,'Pastel Base',1200,'V2.0'),
(5,'White Base',1500,'V1.0');


select * from [labTest].[raw_materials]
select * from [labTest].[formulas]
drop table [formula_items]
drop table dbo.formulas

INSERT INTO labTest.formula_items
(
    formula_id,
    material_id,
    quantity,
    addition_stage
)
VALUES
(1,1,12.5000,'Base Mix'),
(1,2,5.2500,'Pigment Addition'),
(1,3,1.7500,'Final Adjustment'),

(2,1,15.0000,'Base Mix'),
(2,4,3.5000,'Binder Addition'),
(2,5,0.9500,'Quality Correction'),

(3,2,8.2500,'Pigment Addition'),
(3,3,2.1000,'Thickener Addition'),
(3,5,1.2500,'Final Adjustment'),

(4,1,20.0000,'Base Mix'),
(4,2,6.7500,'Pigment Addition'),
(4,3,4.5000,'Binder Addition'),

(5,1,18.0000,'Base Mix'),
(5,2,7.5000,'Pigment Addition'),
(5,3,2.2500,'Thickener Addition');


select f.[product_id] , COUNT(distinct fi.material_id) as dist_rm
from labTest.formulas as f 
join labTest.formula_items as fi 
on f.formula_id = fi.formula_id 
group by f.product_id
having COUNT(distinct fi.material_id)>5


--Q9
alter table [labTest].[formula_items] drop constraint FK_formula_items_formula_3
alter table [labTest].[formula_items] drop constraint FK_formula_items_material_3


alter table [labTest].[formula_items] 
add constraint FK_formula_items_formula_3 
FOREIGN KEY (formula_id)
        REFERENCES  [labTest].[formulas](formula_id) ON DELETE CASCADE


alter table [labTest].[formula_items] 
add constraint FK_formula_items_material_3 
FOREIGN KEY (material_id)
        REFERENCES [labTest].[raw_materials](material_id) ON UPDATE CASCADE ON DELETE SET DEFAULT





--Q10

CREATE TABLE [labTest].[batch_production]
(
    batch_id INT IDENTITY PRIMARY KEY,
    batch_number INT NOT NULL,

    formula_id INT ,

    quantity_produced DECIMAL(10,2) NOT NULL,
    manufacture_date DATE,

    CONSTRAINT FK_formula_
        FOREIGN KEY (formula_id)
        REFERENCES [labTest].[formulas](formula_id) ON DELETE SET NULL
);


-- Q8

CREATE TABLE [labTest].[color_shades]
(
    shade_id INT PRIMARY KEY IDENTITY(1,1),
    shade_code VARCHAR(20) UNIQUE NOT NULL,
    shade_name VARCHAR(100) NOT NULL,
    hex_value CHAR(7) NOT NULL,
    is_exterior_durable BIT NOT NULL
);


INSERT INTO [labTest].[color_shades]
(shade_code, shade_name, hex_value, is_exterior_durable)
VALUES
('SH001','Ocean Blue','#1E90FF',1),
('SH002','Forest Green','#228B22',1),
('SH003','Ivory White','#FFFFF0',0),
('SH004','Sunset Orange','#FF8C00',1),
('SH005','Rose Pink','#FF66CC',0);

select cs.[shade_name],cs.[shade_code] 
from [labTest].[color_shades] as cs
where cs.is_exterior_durable = 1;



--Q7.1

CREATE TABLE [labTest].[stg_raw_materials]
(
    material_id INT PRIMARY KEY IDENTITY(1,1),
    material_name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL
        CHECK (type IN ('Pigment', 'Binder', 'Solvent', 'Additive')),
    unit_of_measure VARCHAR(10) NOT NULL,
    reorder_level DECIMAL(10,2) NOT NULL,
    hazardous_flag BIT NOT NULL DEFAULT 0
);

MERGE [labTest].[raw_materials] AS T
USING [labTest].[stg_raw_materials] AS S
ON T.material_id = S.material_id

WHEN MATCHED THEN
    UPDATE SET
        T.reorder_level = S.reorder_level,
        T.hazardous_flag = S.hazardous_flag

WHEN NOT MATCHED BY TARGET THEN
    INSERT (
        material_id,
        material_name,
        unit_of_measure,
        reorder_level,
        hazardous_flag
    )
    VALUES (
        S.material_id,
        S.material_name,
        S.unit_of_measure,
        S.reorder_level,
        S.hazardous_flag
    );


	select * from [labTest].[raw_materials]
	select * from [labTest].[stg_raw_materials]
--Q7.2

create table [labTest].[productVariant](
[variantId] INT PRIMARY KEY IDENTITY,
[productId] INT NOT NULL,
FOREIGN KEY ([productId]) REFERENCES [labTest].[products]([productId]),
[baseType] VARCHAR(20) NOT NULL,
[packSize] decimal(5,2) NOT NULL,
[skuCode] VARCHAR(30) NOT NULL UNIQUE,
[unitCost] decimal(10,2) NOT NULL,
[mrp] decimal(10,2) NOT NULL, 
[variant_name] varchar(5) NOT NULL
)


	INSERT INTO[labTest].[productVariant]
(
    [productId],
    [skuCode],
    [variant_name],
    [mrp]
)
VALUES
(
    (SELECT p.productId
     FROM [labTest].[products] as p
     WHERE p.productName = 'Apex Shield') ,
    'EX-PNT-10L',
    '10 Litre Pack',
    2499.99
);

INSERT INTO [labTest].raw_materials
(
    material_name,
    type,
    unit_of_measure,
    reorder_level,
    hazardous_flag
)
VALUES
('Titanium Dioxide', 'Pigment', 'KG', 300.00, 0),
('Red Oxide', 'Pigment', 'KG', 150.00, 0),
('Acrylic Binder', 'Binder', 'LTR', 500.00, 0),
('Mineral Spirit', 'Solvent', 'LTR', 200.00, 1),
('Defoamer X1', 'Additive', 'LTR', 75.00, 0);

SET IDENTITY_INSERT labTest.stg_raw_materials OFF;
INSERT INTO [labTest].stg_raw_materials
VALUES
-- Existing IDs (for UPDATE)
( 'Titanium Dioxide', 'Pigment', 'KG', 400.00, 1),   
('Acrylic Binder', 'Binder', 'LTR', 650.00, 0),

-- New IDs (for INSERT)
('Blue Pigment', 'Pigment', 'KG', 250.00, 0),
('Flow Modifier', 'Additive', 'LTR', 120.00, 0);


--Q6

SELECT *
FROM [labTest].[productVariant] as pv
ORDER BY pv.mrp DESC, pv.variantId
OFFSET 20 ROWS
FETCH NEXT 10 ROWS ONLY;


--Q5

CREATE TABLE [labTest].qc_test_logs
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


SELECT
    batch_id,
    test_parameter,
    AVG(CAST(measured_value AS DECIMAL(10,2))) AS avg_measured_value,
    SUM(CASE
            WHEN passed = 0 THEN 1
            ELSE 0
        END) AS failed_test_count
FROM [labTest].qc_test_logs as qc
GROUP BY
    qc.batch_id,
    qc.test_parameter
HAVING
    SUM(CASE
            WHEN passed = 0 THEN 1
            ELSE 0
        END) >= 2;





select * from [labTest].[products]
select * from [labTest].[productVariant]
select * from [labTest].[raw_materials]

create table 

