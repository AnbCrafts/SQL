-- ==========================================
-- Create Table : labTest.QueryUser
-- ==========================================
CREATE TABLE labTest.QueryUser
(
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    UserName VARCHAR(100) NOT NULL,
    Email VARCHAR(255) NOT NULL,

    FullName VARCHAR(150) NULL,
    MobileNo VARCHAR(15) NULL,
    City VARCHAR(100) NULL,
    StateName VARCHAR(100) NULL,
    Country VARCHAR(100) NULL,
    Gender VARCHAR(10) NULL,

    QueryText VARCHAR(MAX) NULL,
    CreatedDate DATETIME NOT NULL DEFAULT GETDATE(),
    IsActive BIT NOT NULL DEFAULT 1
);

-- ==========================================
-- Sample Data
-- ==========================================
INSERT INTO labTest.QueryUser
(
    UserName,
    Email,
    FullName,
    MobileNo,
    City,
    StateName,
    Country,
    Gender,
    QueryText
)
VALUES
(
    'john_smith',
    'john.smith@gmail.com',
    'John Smith',
    '9876543210',
    'Kolkata',
    'West Bengal',
    'India',
    'Male',
    'Need information regarding product pricing.'
),
(
    'emma_watson',
    'emma.watson@yahoo.com',
    'Emma Watson',
    '9876543211',
    'Delhi',
    'Delhi',
    'India',
    'Female',
    'Having issues with account login.'
),
(
    'michael_clark',
    'michael.clark@outlook.com',
    'Michael Clark',
    '9876543212',
    'Mumbai',
    'Maharashtra',
    'India',
    'Male',
    'Requesting a callback from support team.'
),
(
    'sophia_lee',
    'sophia.lee@gmail.com',
    'Sophia Lee',
    '9876543213',
    'Bengaluru',
    'Karnataka',
    'India',
    'Female',
    'Need invoice copy for previous purchase.'
),
(
    'david_miller',
    'david.miller@gmail.com',
    'David Miller',
    '9876543214',
    'Chennai',
    'Tamil Nadu',
    'India',
    'Male',
    'Feedback regarding website performance.'
);

-- Verify Data
SELECT * 
FROM labTest.QueryUser;