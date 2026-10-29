/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [doctor_id]
      ,[first_name]
      ,[last_name]
      ,[specialization]
      ,[department_id]
      ,[email]
      ,[phone_number]
  FROM [AssignmentDB].[labTest].[Doctors]

  select * from labTest.Doctors


  drop table labtest.Patients
  CREATE TABLE labTest.PatientTbl
(
    patient_id INT IDENTITY(1,1) PRIMARY KEY,

    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,

    gender VARCHAR(10),
    age INT,

    blood_group VARCHAR(5),

    doctor_id INT,

    disease VARCHAR(100),

    admission_date DATE,

    email VARCHAR(100),

    phone_number VARCHAR(15),

    FOREIGN KEY (doctor_id)
        REFERENCES labTest.Doctors(doctor_id)
);

INSERT INTO labTest.PatientTbl
(
    first_name,
    last_name,
    gender,
    age,
    blood_group,
    doctor_id,
    disease,
    admission_date,
    email,
    phone_number
)
VALUES

('Rahul','Sharma','Male',28,'B+',1,'Fever','2026-10-01',
 'rahul@gmail.com','9876543210'),

('Priya','Das','Female',24,'O+',2,'Migraine','2026-10-05',
 'priya@gmail.com','9876543211'),

('Amit','Roy','Male',45,'A+',
 1,'Diabetes','2026-10-07',
 'amit@gmail.com','9876543212'),

('Neha','Agarwal','Female',32,'AB+',
 3,'Thyroid','2026-10-10',
 'neha@gmail.com','9876543213'),

('Sourav','Sen','Male',40,'O-',
 4,'Hypertension','2026-10-12',
 'sourav@gmail.com','9876543214'),

('Ritika','Paul','Female',29,'B-',
 5,'Asthma','2026-10-15',
 'ritika@gmail.com','9876543215');