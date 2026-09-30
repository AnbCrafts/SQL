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
FOREIGN KEY ([productId]) REFERENCES Assignment.products([productId]),
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

drop table Assignment.products;



CREATE TABLE Assignment.raw_materials
(
    material_id INT PRIMARY KEY IDENTITY(1,1),
    material_name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL
        CHECK (type IN ('Pigment', 'Binder', 'Solvent', 'Additive')),
    unit_of_measure VARCHAR(10) NOT NULL,
    reorder_level DECIMAL(10,2) NOT NULL,
    hazardous_flag BIT NOT NULL DEFAULT 0
);
CREATE TABLE Assignment.formulas
(
    formula_id INT PRIMARY KEY IDENTITY(1,1),
    product_id INT NOT NULL,
    base_type VARCHAR(20) NOT NULL,
    yield_liters DECIMAL(10,2) NOT NULL,
    version VARCHAR(10) NOT NULL
);

CREATE TABLE Assignment.formula_items
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


CREATE TABLE Assignment.color_shades
(
    shade_id INT PRIMARY KEY IDENTITY(1,1),
    shade_code VARCHAR(20) UNIQUE NOT NULL,
    shade_name VARCHAR(100) NOT NULL,
    hex_value CHAR(7) NOT NULL,
    is_exterior_durable BIT NOT NULL
);

CREATE TABLE Assignment.batch_production
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


CREATE TABLE Assignment.qc_test_logs
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

INSERT INTO Assignment.raw_materials
(material_name, type, unit_of_measure, reorder_level, hazardous_flag)
VALUES
('Titanium Dioxide','Pigment','KG',100.00,0),
('Red Iron Oxide','Pigment','KG',50.00,0),
('Pure Acrylic Binder','Binder','L',200.00,0),
('Mineral Spirit','Solvent','L',150.00,1),
('Defoamer X1','Additive','L',25.00,1),
('Blue Colorant','Pigment','KG',40.00,0);


INSERT INTO Assignment.formulas
(product_id, base_type, yield_liters, version)
VALUES
(1,'White Base',1000,'V1.0'),
(1,'Deep Base',1000,'V1.1'),
(2,'White Base',750,'V1.0'),
(3,'Pastel Base',1200,'V2.0'),
(5,'White Base',1500,'V1.0');

INSERT INTO Assignment.color_shades
(shade_code, shade_name, hex_value, is_exterior_durable)
VALUES
('SH001','Ocean Blue','#1E90FF',1),
('SH002','Forest Green','#228B22',1),
('SH003','Ivory White','#FFFFF0',0),
('SH004','Sunset Orange','#FF8C00',1),
('SH005','Rose Pink','#FF66CC',0);

INSERT INTO Assignment.batch_production
(batch_number, formula_id, quantity_produced, manufacture_date, qc_status)
VALUES
('BT2026001',1,950.00,'2026-09-01','Approved'),
('BT2026002',2,980.00,'2026-09-02','Pending'),
('BT2026003',3,720.00,'2026-09-04','Approved'),
('BT2026004',4,1180.00,'2026-09-07','Rejected'),
('BT2026005',5,1490.00,'2026-09-10','Approved');


INSERT INTO Assignment.qc_test_logs
(batch_id, test_parameter, measured_value, passed, tested_by)
VALUES
(1,'Viscosity','95 KU',1,101),
(1,'pH','8.5',1,101),

(2,'Viscosity','90 KU',1,102),

(3,'Opacity','98%',1,103),

(4,'Dry Film Thickness','35 Micron',0,104),

(5,'Gloss','87 GU',1,105),

(5,'Washability','1500 Cycles',1,105);


CREATE TABLE Assignment.shade_recipes
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
        REFERENCES raw_materials(material_id),
		
		CONSTRAINT FK_shade_recipes_product
FOREIGN KEY (product_id)
REFERENCES Assignment.products(productId)
);




INSERT INTO Assignment.shade_recipes
(shade_id, product_id, colorant_id, shots_per_liter)
VALUES
(1,1,6,12.5000),  -- Ocean Blue
(2,1,2,8.2500),   -- Forest Green
(3,2,1,5.0000),   -- Ivory White
(4,3,2,10.7500),  -- Sunset Orange
(5,4,2,7.5000);   -- Rose Pink


SELECT * FROM Assignment.products;

SELECT * FROM Assignment.productVariant;

SELECT * FROM Assignment.raw_materials;

SELECT * FROM Assignment.formulas;

SELECT * FROM Assignment.formula_items;

SELECT * FROM Assignment.color_shades;

SELECT * FROM Assignment.shade_recipes;

SELECT * FROM Assignment.batch_production;

SELECT * FROM Assignment.qc_test_logs;

DROP TABLE IF EXISTS qc_test_logs;

DROP TABLE IF EXISTS batch_production;

DROP TABLE IF EXISTS shade_recipes;

DROP TABLE IF EXISTS formula_items;

DROP TABLE IF EXISTS color_shades;

DROP TABLE IF EXISTS formulas;

DROP TABLE IF EXISTS raw_materials;

DROP TABLE IF EXISTS Assignment.productVariant;

DROP TABLE IF EXISTS Assignment.products;