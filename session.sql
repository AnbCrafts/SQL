/*=========================================
    CREATE SCHEMA
=========================================*/

IF NOT EXISTS (
    SELECT *
    FROM sys.schemas
    WHERE name = 'labTest'
)
BEGIN
    EXEC('CREATE SCHEMA labTest');
END;


/*=========================================
    DROP TABLE
=========================================*/

IF OBJECT_ID('labTest.student', 'U') IS NOT NULL
    DROP TABLE labTest.student;


/*=========================================
    CREATE TABLE
=========================================*/

CREATE TABLE labTest.student
(
    studentId INT IDENTITY(1,1) PRIMARY KEY,
    studentName VARCHAR(50) NOT NULL,
    email VARCHAR(50) NOT NULL
);
SELECT SCOPE_IDENTITY() AS LastInsertedID;


/*=========================================
    INSERT ONE RECORD
=========================================*/

INSERT INTO labTest.student
(
    studentName,
    email
)
VALUES
(
    'Anubhaw Gupta',
    'anubhaw@gmail.com'
);


/*=========================================
    GET LAST GENERATED IDENTITY
=========================================*/

SELECT SCOPE_IDENTITY() AS LastInsertedID;


/*=========================================
    INSERT SECOND RECORD
=========================================*/

INSERT INTO labTest.student
(
    studentName,
    email
)
VALUES
(
    'Rahul Sharma',
    'rahul@gmail.com'
);

SELECT SCOPE_IDENTITY() AS LastInsertedID;


/*=========================================
    VIEW DATA
=========================================*/

SELECT *
FROM labTest.student;

truncate table labTest.student