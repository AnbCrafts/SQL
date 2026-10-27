CREATE TABLE labTest.ResumeUsers
(
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    FullName VARCHAR(100),
    Email VARCHAR(100),
    PhoneNumber VARCHAR(20),
    City VARCHAR(50),
    Skills VARCHAR(500),
    ExperienceYears INT,
    Education VARCHAR(200),
    ImageUrl VARCHAR(500)
);

INSERT INTO labTest.ResumeUsers
(
    FullName,
    Email,
    PhoneNumber,
    City,
    Skills,
    ExperienceYears,
    Education,
    ImageUrl
)
VALUES
(
    'Anubhaw Kumar Gupta',
    'anubhaw.gupta@gmail.com',
    '9876543210',
    'Kolkata',
    'ASP.NET, C#, ADO.NET, SQL Server, Crystal Reports',
    2,
    'B.Tech Computer Science',
    'img1.webp'
),
(
    'Rahul Sharma',
    'rahul.sharma@gmail.com',
    '9876543211',
    'Delhi',
    'Java, Spring Boot, MySQL, REST API',
    4,
    'B.Tech Information Technology',
    'img2.webp'
),
(
    'Priya Das',
    'priya.das@gmail.com',
    '9876543212',
    'Mumbai',
    'ReactJS, NodeJS, MongoDB, JavaScript',
    3,
    'MCA',
    'img3.webp'
);


UPDATE labTest.ResumeUsers
SET ImageUrl =
'C:\Users\anubhawgupta\Desktop\Images\img3.webp'
WHERE FullName = 'Anubhaw Kumar Gupta';

UPDATE labTest.ResumeUsers
SET ImageUrl =
'C:\Users\anubhawgupta\Desktop\Images\img2.webp'
WHERE FullName = 'Rahul Sharma';

UPDATE labTest.ResumeUsers
SET ImageUrl =
'C:\Users\anubhawgupta\Desktop\Images\img1.webp'
WHERE FullName = 'Priya Das';