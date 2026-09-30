-- =====================================================================
-- SQL SERVER PRACTICE - DAY 3: JOINS & CROSS-TABLE DML
-- Domain: Book Publishing & Store Management
-- =====================================================================

-- ---------------------------------------------------------------------
-- STEP 1: CREATE TABLES
-- ---------------------------------------------------------------------

-- Cleanup existing demo tables if any
DROP TABLE IF EXISTS BookSales;
DROP TABLE IF EXISTS Books;
DROP TABLE IF EXISTS Authors;
DROP TABLE IF EXISTS StaffMembers;
DROP TABLE IF EXISTS Categories;

-- 1. Authors Table
CREATE TABLE Authors (
    AuthorId INT PRIMARY KEY IDENTITY(1,1),
    AuthorName VARCHAR(100) NOT NULL,
    Country VARCHAR(50) NOT NULL
);

-- 2. Books Table (Foreign key to Authors)
CREATE TABLE Books (
    BookId INT PRIMARY KEY IDENTITY(101,1),
    Title VARCHAR(150) NOT NULL,
    Genre VARCHAR(50) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    AuthorId INT NULL, -- NULL allowed for orphan books test
    FOREIGN KEY (AuthorId) REFERENCES Authors(AuthorId)
);

-- 3. BookSales Table (Foreign key to Books)
CREATE TABLE BookSales (
    SaleId INT PRIMARY KEY IDENTITY(1001,1),
    BookId INT NULL,
    Quantity INT NOT NULL,
    SaleAmount DECIMAL(10,2) NOT NULL,
    SaleDate DATE NOT NULL
);

-- 4. Categories Table (For Cross Join practice)
CREATE TABLE Categories (
    CategoryId INT PRIMARY KEY IDENTITY(1,1),
    CategoryName VARCHAR(50) NOT NULL
);

-- 5. StaffMembers Table (For Self Join practice)
CREATE TABLE StaffMembers (
    StaffId INT PRIMARY KEY IDENTITY(1,1),
    StaffName VARCHAR(100) NOT NULL,
    Designation VARCHAR(50) NOT NULL,
    ManagerId INT NULL -- Foreign key to StaffMembers(StaffId)
);


-- ---------------------------------------------------------------------
-- STEP 2: INSERT SAMPLE DATA
-- ---------------------------------------------------------------------

-- Insert Authors
INSERT INTO Authors (AuthorName, Country) VALUES
('J.K. Rowling', 'UK'),          -- AuthorId 1
('George R.R. Martin', 'USA'),    -- AuthorId 2
('Agatha Christie', 'UK'),       -- AuthorId 3
('Stephen King', 'USA'),         -- AuthorId 4
('Unpublished Writer', 'India');  -- AuthorId 5 (No books linked)

-- Insert Books
INSERT INTO Books (Title, Genre, Price, AuthorId) VALUES
('Harry Potter & The Philosopher Stone', 'Fantasy', 500.00, 1), -- BookId 101
('Harry Potter & The Chamber of Secrets', 'Fantasy', 550.00, 1), -- BookId 102
('A Game of Thrones', 'Fantasy', 750.00, 2),                   -- BookId 103
('A Clash of Kings', 'Fantasy', 800.00, 2),                    -- BookId 104
('Murder on the Orient Express', 'Mystery', 400.00, 3),        -- BookId 105
('The Shining', 'Horror', 600.00, 4),                           -- BookId 106
('Anonymous Ancient Tales', 'History', 300.00, NULL);          -- BookId 107 (No Author)

-- Insert Sales
INSERT INTO BookSales (BookId, Quantity, SaleAmount, SaleDate) VALUES
(101, 10, 5000.00, '2026-09-01'),
(101, 5, 2500.00, '2026-09-05'),
(103, 8, 6000.00, '2026-09-10'),
(105, 12, 4800.00, '2026-09-12'),
(NULL, 2, 1000.00, '2026-09-15'); -- Sale without valid BookId

-- Insert Categories
INSERT INTO Categories (CategoryName) VALUES
('Fiction'),
('Non-Fiction'),
('Digital E-Book');

-- Insert Staff (Self Join Hierarchy)
INSERT INTO StaffMembers (StaffName, Designation, ManagerId) VALUES
('Arthur Pendelton', 'CEO', NULL),          -- StaffId 1 (Top Boss)
('Beatrix Potter', 'Store Manager', 1),     -- StaffId 2 (Reports to 1)
('Charles Xavier', 'Senior Sales Executive', 2), -- StaffId 3 (Reports to 2)
('Diana Prince', 'Sales Associate', 2);     -- StaffId 4 (Reports to 2)


-- ---------------------------------------------------------------------
-- STEP 3: PRACTICE QUERIES FOR EACH JOIN TYPE
-- ---------------------------------------------------------------------

-- 1. INNER JOIN (Matching records only)
SELECT b.BookId, b.Title, b.Price, a.AuthorName, a.Country
FROM Books b
INNER JOIN Authors a ON b.AuthorId = a.AuthorId;

-- 2. LEFT OUTER JOIN (All books + matching authors, NULL if no author)
SELECT b.BookId, b.Title, b.Price, a.AuthorName
FROM Books b
LEFT JOIN Authors a ON b.AuthorId = a.AuthorId;

-- Find Books that have NO Author assigned:
SELECT b.BookId, b.Title
FROM Books b
LEFT JOIN Authors a ON b.AuthorId = a.AuthorId
WHERE a.AuthorId IS NULL;

-- 3. RIGHT OUTER JOIN (All authors + matching books, NULL if author has no books)
SELECT a.AuthorId, a.AuthorName, b.Title, b.Price
FROM Books b
RIGHT JOIN Authors a ON b.AuthorId = a.AuthorId;

-- Find Authors who have published NO Books:
SELECT a.AuthorId, a.AuthorName
FROM Books b
RIGHT JOIN Authors a ON b.AuthorId = a.AuthorId
WHERE b.BookId IS NULL;

-- 4. FULL OUTER JOIN (All authors and all books, with NULLs where unmatched)
SELECT a.AuthorName, b.Title
FROM Authors a
FULL OUTER JOIN Books b ON a.AuthorId = b.AuthorId;

-- Find records that exist ONLY in Authors or ONLY in Books (Excluding common matches):
SELECT a.AuthorName, b.Title
FROM Authors a
FULL OUTER JOIN Books b ON a.AuthorId = b.AuthorId
WHERE a.AuthorId IS NULL OR b.BookId IS NULL;

-- 5. CROSS JOIN (Cartesian product N x M)
SELECT b.Title, c.CategoryName
FROM Books b
CROSS JOIN Categories c;

-- 6. SELF JOIN (Staff and Manager Hierarchy)
SELECT 
    s.StaffId,
    s.StaffName AS StaffMember,
    s.Designation,
    ISNULL(m.StaffName, 'Top Executive / No Manager') AS ManagerName
FROM StaffMembers s
LEFT JOIN StaffMembers m ON s.ManagerId = m.StaffId;

-- 7. UPDATE WITH JOIN (Apply 10% discount to all Fantasy books)
UPDATE b
SET b.Price = b.Price * 0.90
FROM Books b
INNER JOIN Authors a ON b.AuthorId = a.AuthorId
WHERE b.Genre = 'Fantasy';

-- 8. DELETE WITH JOIN (Delete sales records for books that cost less than 450)
DELETE s
FROM BookSales s
INNER JOIN Books b ON s.BookId = b.BookId
WHERE b.Price < 450;



--Q1 Write a query to retrieve the BookId, Title, Genre, Price, and AuthorName for all books that have an assigned author.
select b.BookId, b.Genre, b.Title,b.Price, a.AuthorName from Books as b inner join Authors as a on b.AuthorId = a.AuthorId 

--Q2 Write a query using LEFT JOIN to list all AuthorId and AuthorName from the Authors table along with any Title they have written.

select a.AuthorId, a.AuthorName from Books as b left join Authors as a on b.AuthorId = a.AuthorId where a.AuthorId is not null

--Q3 Write a query using RIGHT JOIN between BookSales (left table) and Books (right table) to retrieve all book titles and their respective SaleAmount and SaleDate. Make sure books with no sales records are included.

select b.Title, bs.SaleAmount, bs.SaleDate from BookSales as bs right join Books as b on b.BookId = bs.BookId

--Q4 Write a query using FULL OUTER JOIN between Authors and Books to find records that are either an author without any books OR a book without any author (excluding all matching author-book pairs).

select * from Authors as a full outer join Books as b on a.AuthorId = b.AuthorId where (b.AuthorId is null or b.BookId is null)

--Q5 Write a query to generate every possible pairing of AuthorName and CategoryName

select * from Authors cross join Categories

--Q6 Write a query using SELF JOIN on StaffMembers that outputs:

select s1.StaffName, s1.Designation , isnull(s2.ManagerId,'No Manager') as manger from StaffMembers as s1 inner join StaffMembers as s2 on s1.StaffId = s2.ManagerId 

--Q7 Write an UPDATE query using an INNER JOIN between Books and Authors to increase the Price by 15% for all books written by authors located in 'USA'.

update Books set Price += Price*0.15 from Books as b inner join Authors as a on b.AuthorId = a.AuthorId where a.Country = 'USA'
select *  from Books as b inner join Authors as a on b.AuthorId = a.AuthorId where a.Country = 'USA'

--Q8 Write a DELETE statement using a JOIN to delete all sales records from BookSales for books belonging to the 'Horror' genre.

delete from BookSales from Books as b inner join BookSales as bs on b.BookId = bs.BookId where b.Genre = 'Horror'

--Q9 