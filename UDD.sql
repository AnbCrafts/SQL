/****** Script for SelectTopNRows command from SSMS  ******/
SELECT *
  FROM [AssignmentDB].[labTest].[student]

  INSERT INTO labTest.student
( studentName, email)
VALUES
( 'Anubhaw Gupta', 'anubhaw@gmail.com'),
('Rahul Sharma', 'rahul@gmail.com'),
('Priya Singh', 'priya@gmail.com'),
('Amit Kumar', 'amit@gmail.com'),
('Sneha Das', 'sneha@gmail.com'),
( 'Rohit Roy', 'rohit@gmail.com'),
( 'Neha Patel', 'neha@gmail.com'),
( 'Vikas Jain', 'vikas@gmail.com'),
( 'Pooja Sen', 'pooja@gmail.com'),
( 'Arjun Mehta', 'arjun@gmail.com');


create type udd_StdTable as table (name varchar(100), email varchar(100))

CREATE PROCEDURE labTest.InsertStudents
    @tbl udd_StdTable readonly
AS
BEGIN
    INSERT INTO labTest.student
    (
        
        studentName,
        email
    )
    SELECT
        
        Name,
        Email
    FROM @tbl;
END;
GO


DECLARE @Students udd_StdTable;
INSERT INTO @Students
VALUES
('Karan Malhotra', 'karan.malhotra@contoso.com'),
('Ishita Verma', 'ishita.verma@contoso.com'),
('Devansh Kapoor', 'devansh.kapoor@contoso.com'),
('Ritika Nair', 'ritika.nair@contoso.com'),
('Yash Tiwari', 'yash.tiwari@contoso.com'),
('Mehul Joshi', 'mehul.joshi@contoso.com'),
('Tanisha Arora', 'tanisha.arora@contoso.com'),
('Siddharth Rao', 'siddharth.rao@contoso.com'),
('Nikita Bansal', 'nikita.bansal@contoso.com'),
('Aditya Khanna', 'aditya.khanna@contoso.com'),
('Reyansh Gupta', 'reyansh.gupta@contoso.com'),
('Aarohi Mehta', 'aarohi.mehta@contoso.com'),
('Harsh Vardhan', 'harsh.vardhan@contoso.com'),
('Diya Chatterjee', 'diya.chatterjee@contoso.com'),
('Raghav Sethi', 'raghav.sethi@contoso.com'),
('Myra Kulkarni', 'myra.kulkarni@contoso.com'),
('Kabir Anand', 'kabir.anand@contoso.com'),
('Ananya Deshmukh', 'ananya.deshmukh@contoso.com'),
('Vivaan Srivastava', 'vivaan.srivastava@contoso.com'),
('Sara Thomas', 'sara.thomas@contoso.com');
--SELECT * FROM @Students;

exec labTest.InsertStudents @Students
select * from labTest.student