create table labTest.DeviceTable(
customerName varchar(100),
productname varchar(100),
amount decimal(10,2)
);


INSERT INTO labTest.DeviceTable (customerName, productname, amount) VALUES
('John Smith', 'Laptop', 65000),
('John Smith', 'Mobile', 25000),
('John Smith', 'Desktop', 55000),

('Alice Johnson', 'Laptop', 72000),
('Alice Johnson', 'Mobile', 18000),

('David Brown', 'Desktop', 48000),
('David Brown', 'Laptop', 68000),
('David Brown', 'Mobile', 22000),

('Emma Wilson', 'Mobile', 15000),
('Emma Wilson', 'Mobile', 28000),
('Emma Wilson', 'Laptop', 75000),

('Michael Davis', 'Desktop', 60000),
('Michael Davis', 'Laptop', 85000),

('Sophia Miller', 'Mobile', 35000),
('Sophia Miller', 'Desktop', 52000),

('James Anderson', 'Laptop', 90000),
('James Anderson', 'Laptop', 82000),
('James Anderson', 'Mobile', 27000),

('Olivia Thomas', 'Desktop', 45000),
('Olivia Thomas', 'Mobile', 20000),

('William Jackson', 'Laptop', 70000),
('William Jackson', 'Desktop', 65000),

('Charlotte White', 'Mobile', 32000),
('Charlotte White', 'Laptop', 78000),

('Benjamin Harris', 'Desktop', 58000),
('Benjamin Harris', 'Mobile', 24000),
('Benjamin Harris', 'Laptop', 88000),

('Amelia Martin', 'Mobile', 17000),
('Amelia Martin', 'Desktop', 49000),

('Lucas Thompson', 'Laptop', 95000),
('Lucas Thompson', 'Mobile', 30000),

('Mia Garcia', 'Desktop', 53000),
('Mia Garcia', 'Laptop', 81000),
('Mia Garcia', 'Mobile', 21000);

SELECT 
    customerName,
    ISNULL(Laptop, 0) AS Laptop,
    ISNULL(Desktop, 0) AS Desktop,
    ISNULL(Mobile, 0) AS Mobile,
    (
        ISNULL(Laptop, 0) +
        ISNULL(Desktop, 0) +
        ISNULL(Mobile, 0)
    ) / 3.0 AS AvgSpent
FROM
(
    SELECT customerName, productname, amount
    FROM labTest.DeviceTable
) AS SourceData
PIVOT
(
    SUM(amount)
    FOR productname IN (Laptop, Desktop, Mobile)
) AS P;



select * from labTest.DeviceTable as d where d.customerName='John Smith'

-- select * from pivotDevicetable -- PIVOT TABLE DOES NOT EXIST PHYSICALLY, IT"S JUST FOR VISUALLISATION OF DATA IN A DIFFERENT MANNER/POV