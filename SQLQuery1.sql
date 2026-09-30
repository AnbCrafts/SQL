create schema Company;

create table Company.employee(
[name] VARCHAR(30) NOT NULL,
[empId] INT PRIMARY KEY IDENTITY,
[depID] INT NOT NULL,
[salary] DECIMAL(10,2) NOT NULL CONSTRAINT check_salary_ CHECK([salary]>=10000),
[location] VARCHAR(30) NOT NULL,
[joinedOn] DATE NOT NULL DEFAULT GETDATE(),
[intro] VARCHAR(3500) 
)

create table Company.department( 
[depId] INT PRIMARY KEY IDENTITY,
[name] VARCHAR(20) NOT NULL CONSTRAINT check_valid_dep_ CHECK ([name] in ('HR','Tech','Marketting'))
)
ALTER TABLE Company.department
ADD
    managerName VARCHAR(50),
    budget DECIMAL(12,2),
    extensionNo VARCHAR(10),
    floorNo INT,
    employeeCount INT DEFAULT 0,
    createdOn DATE DEFAULT GETDATE(),
    description VARCHAR(500);

	drop table department
INSERT INTO Company.employee
([name], [depID], [salary], [location], [joinedOn], [intro])
VALUES
('Anubhaw Gupta', 2, 65000.00, 'Bangalore', '2024-01-15',
 'Software Developer with expertise in C#, SQL Server and .NET.'),

('Komal Sharma', 1, 45000.00, 'Delhi', '2024-02-20',
 'HR Executive responsible for recruitment and employee engagement.'),

('Abhijeet Kumar', 2, 72000.00, 'Pune', '2023-11-10',
 'Full Stack Developer working on enterprise applications.'),

('Rohit Gupta', 3, 50000.00, 'Mumbai', '2024-03-05',
 'Marketing specialist focusing on digital campaigns.'),

('Priya Singh', 1, 40000.00, 'Noida', '2024-04-12',
 'HR coordinator handling onboarding processes.'),

('Amit Kumar', 2, 85000.00, 'Hyderabad', '2022-09-18',
 'Senior Software Engineer leading backend development.'),

('Neha Verma', 3, 55000.00, 'Chennai', '2023-06-25',
 'Marketing analyst skilled in data-driven strategies.'),

('Vikas Yadav', 2, 78000.00, 'Bangalore', '2022-12-01',
 'Database developer with strong SQL Server knowledge.'),

('Pooja Mishra', 1, 42000.00, 'Lucknow', '2024-05-07',
 'Talent acquisition specialist.'),

('Karan Mehta', 3, 60000.00, 'Gurgaon', '2023-08-30',
 'Brand manager overseeing promotional activities.');

 INSERT INTO Company.department
(name, managerName, budget, extensionNo, floorNo, description)
VALUES
('HR', 'Komal Sharma', 500000.00, 'HR101', 1,
 'Handles recruitment, onboarding and employee relations.'),

('Tech', 'Abhijeet Kumar', 2500000.00, 'TE201', 2,
 'Responsible for software development and IT infrastructure.'),

('Marketting', 'Rohit Gupta', 1200000.00, 'MK301', 3,
 'Handles branding, advertising and promotional campaigns.');

 select * from Company.employee
 select * from Company.department

 -- FULL OUTER JOIN
 select * from Company.department AS cd 
 FULL OUTER JOIN 
 Company.employee AS ce 
 on cd.depId = ce.depID
 WHERE cd.budget >500000
ORDER BY cd.budget


SELECT
    cd.floorNo,
    COUNT(*) AS EmployeeCount
FROM Company.department cd
JOIN Company.employee ce
    ON cd.depId = ce.depID
GROUP BY cd.floorNo;



 