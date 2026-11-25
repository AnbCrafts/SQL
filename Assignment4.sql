--1

CREATE TABLE labTest.StudentDetails
(
    studentId INT IDENTITY(1,1) PRIMARY KEY,
    studentName VARCHAR(100) NOT NULL,
    fatherName VARCHAR(100) NOT NULL
);

INSERT INTO labTest.StudentDetails (studentName, fatherName)
VALUES
('Rajiv Kumar', 'Arvind Kumar'),
('Asish Roy', 'Ashim Roy'),
('Bipin Gupta', 'Rajiv Gupta'),
('Rajiv Kumar', 'Arvind Kumar'),
('Sourav Patra', 'Asish Patra'),
('Asish Roy', 'Ashim Roy'),
('Ankit Das', 'Sanjib Das'),
('Rohit Sen', 'Ajit Sen'),
('Ankit Das', 'Sanjib Das');

SELECT
    studentName,
    fatherName
FROM labTest.StudentDetails
GROUP BY
    studentName,
    fatherName
HAVING COUNT(*) > 1;


--2
select FORMAT(GETDATE() , 'dddd, dd MMMM yyyy') as CurrentDate

--4


CREATE TABLE labTest.Items
(
    itemId INT IDENTITY(1,1) PRIMARY KEY,
    itemCode VARCHAR(20) NOT NULL UNIQUE,
    itemName VARCHAR(100) NOT NULL,
    parentItemId INT NULL,
    unit VARCHAR(20) NOT NULL,
    unitPrice DECIMAL(10,2) NOT NULL,
    CONSTRAINT FK_Items_Parent
        FOREIGN KEY (parentItemId)
        REFERENCES labTest.Items(itemId)
);

INSERT INTO labTest.Items
(
    itemCode,
    itemName,
    parentItemId,
    unit,
    unitPrice
)
VALUES
('LAP001', 'Laptop', NULL, 'Each', 60000.00),

('MB001', 'Motherboard', 1, 'Each', 12000.00),
('CS001', 'Laptop Casing', 1, 'Each', 5000.00),
('BT001', 'Battery Pack', 1, 'Each', 4000.00),
('KY001', 'Keyboard Assembly', 1, 'Each', 1800.00),
('SC001', 'Display Screen', 1, 'Each', 8500.00),

('CPU001', 'Processor', 2, 'Each', 15000.00),
('RAM001', 'RAM Module', 2, 'Each', 2500.00),
('SSD001', 'SSD Storage', 2, 'Each', 4000.00),

('CE001', 'CPU Core', 7, 'Each', 7000.00),
('HS001', 'Heat Sink', 7, 'Each', 500.00),

('BC001', 'Battery Cell', 4, 'Each', 900.00),
('WC001', 'Battery Wiring', 4, 'Each', 150.00),

('KP001', 'Key Pad', 5, 'Each', 50.00),
('KC001', 'Keyboard Controller', 5, 'Each', 250.00),

('LP001', 'LCD Panel', 6, 'Each', 5000.00),
('FP001', 'Flexible Panel Cable', 6, 'Each', 300.00),

('CH001', 'Aluminium Chassis', 3, 'Each', 2500.00),
('SCW01', 'Assembly Screws', 3, 'Pack', 100.00);

WITH BOM AS
(
    SELECT
        itemId,
        itemCode,
        itemName,
        parentItemId,
        unitPrice,
        0 AS Level
    FROM labTest.Items
    WHERE itemCode = 'LAP001'

    UNION ALL

    SELECT
        i.itemId,
        i.itemCode,
        i.itemName,
        i.parentItemId,
        i.unitPrice,
        b.Level + 1
    FROM labTest.Items i
    INNER JOIN BOM b
        ON i.parentItemId = b.itemId
)
SELECT *
FROM BOM
ORDER BY Level, itemId;

--6
CREATE TABLE labTest.TicketBooking
(
    BookingId INT IDENTITY(1,1) PRIMARY KEY,
    PassengerName VARCHAR(100) NOT NULL,
    SourceCity VARCHAR(100) NOT NULL,
    DestinationCity VARCHAR(100) NOT NULL,
    JourneyDate DATE NOT NULL,
    TicketPrice DECIMAL(10,2) NOT NULL
);

CREATE TYPE labTest.TicketBookingType AS TABLE
(
    PassengerName VARCHAR(100),
    SourceCity VARCHAR(100),
    DestinationCity VARCHAR(100),
    JourneyDate DATE,
    TicketPrice DECIMAL(10,2)
);
GO

CREATE PROCEDURE labTest.InsertTicketBookings
(
    @TicketBookings labTest.TicketBookingType READONLY
)
AS
BEGIN
    INSERT INTO labTest.TicketBooking
    (
        PassengerName,
        SourceCity,
        DestinationCity,
        JourneyDate,
        TicketPrice
    )
    SELECT
        PassengerName,
        SourceCity,
        DestinationCity,
        JourneyDate,
        TicketPrice
    FROM @TicketBookings;
END;
GO

DECLARE @Bookings AS labTest.TicketBookingType;

INSERT INTO @Bookings
VALUES
('Rajiv Kumar', 'Kolkata', 'Delhi', '2026-12-02', 4500),
('Asish Roy', 'Delhi', 'Mumbai', '2026-12-07', 3200),
('Bipin Gupta', 'Chennai', 'Bangalore', '2026-12-11', 1800);

EXEC labTest.InsertTicketBookings @TicketBookings = @Bookings;

SELECT *
FROM labTest.TicketBooking;

--7

CREATE TABLE labTest.Graph
(
    EdgeId INT IDENTITY(1,1) PRIMARY KEY,
    SourceNode VARCHAR(20) NOT NULL,
    DestinationNode VARCHAR(20) NOT NULL,
    Distance INT NOT NULL
);

INSERT INTO labTest.Graph
(
    SourceNode,
    DestinationNode,
    Distance
)
VALUES
('A', 'B', 5),
('A', 'C', 3),
('B', 'D', 4),
('B', 'E', 2),
('C', 'D', 7),
('C', 'F', 6),
('D', 'G', 3),
('E', 'G', 5),
('F', 'G', 2),
('B', 'F', 4),
('C', 'E', 1),
('A', 'D', 8),
('E', 'H', 3),
('F', 'H', 2),
('G', 'I', 4),
('H', 'I', 1);


WITH Paths
AS
(
    SELECT
        SourceNode,
        DestinationNode,
        CAST(SourceNode + '->' + DestinationNode AS VARCHAR(MAX)) AS Path,
        1 AS Level
    FROM labTest.Graph
    WHERE SourceNode = 'A'

    UNION ALL

    SELECT
        g.SourceNode,
        g.DestinationNode,
        CAST(p.Path + '->' + g.DestinationNode AS VARCHAR(MAX)),
        p.Level + 1
    FROM labTest.Graph g
    INNER JOIN Paths p
        ON p.DestinationNode = g.SourceNode
    WHERE p.Path NOT LIKE '%->' + g.DestinationNode + '%'
)
SELECT *
FROM Paths
WHERE DestinationNode = 'I';




--OR
declare @startNode VARCHAR(10) 
set @startNode = 'G'
;WITH Paths AS
(
    SELECT
        SourceNode AS StartNode,
        DestinationNode,
        CAST(SourceNode + '->' + DestinationNode AS VARCHAR(MAX)) AS Path,
        1 AS Level
    FROM labTest.Graph
    WHERE SourceNode = @startNode

    UNION ALL

    SELECT
        p.StartNode,
        g.DestinationNode,
        CAST(p.Path + '->' + g.DestinationNode AS VARCHAR(MAX)),
        p.Level + 1
    FROM labTest.Graph g
    JOIN Paths p
        ON p.DestinationNode = g.SourceNode
    WHERE p.Path NOT LIKE '%->' + g.DestinationNode + '%'
)
SELECT
    StartNode,
    DestinationNode AS EndNode,
    Path,
    Level
FROM Paths
WHERE DestinationNode = 'I';


--9

CREATE TABLE labTest.Complaint
(
    ComplaintId INT IDENTITY(1,1) PRIMARY KEY,
    CustomerName VARCHAR(100) NOT NULL,
    ComplaintDescription VARCHAR(500) NOT NULL,
    ComplaintDate DATE NOT NULL,
    Status VARCHAR(20) NOT NULL,
    EscalationDate DATETIME NULL
);

INSERT INTO labTest.Complaint
(
    CustomerName,
    ComplaintDescription,
    ComplaintDate,
    Status,
    EscalationDate
)
VALUES
('Rajiv Kumar', 'Internet not working', DATEADD(DAY, -25, GETDATE()), 'Open', NULL),

('Asish Roy', 'Billing issue', DATEADD(DAY, -18, GETDATE()), 'Open', NULL),

('Bipin Gupta', 'Slow network speed', DATEADD(DAY, -35, GETDATE()), 'Open', NULL),

('Sourav Patra', 'Router replacement request', DATEADD(DAY, -5, GETDATE()), 'Open', NULL),

('Ankit Das', 'Connection drops frequently', DATEADD(DAY, -2, GETDATE()), 'Open', NULL),

('Rohit Sen', 'Password reset issue', DATEADD(DAY, -12, GETDATE()), 'Closed', NULL),

('Abhishek Das', 'Unable to access portal', DATEADD(DAY, -20, GETDATE()), 'Open', NULL),

('Kunal Roy', 'Installation pending', DATEADD(DAY, -7, GETDATE()), 'Open', NULL);

CREATE PROC labTest.HandleComplaints
AS
BEGIN
    BEGIN TRY

        BEGIN TRANSACTION;

        IF NOT EXISTS
        (
            SELECT 1
            FROM labTest.Complaint
            WHERE DATEDIFF(DAY, ComplaintDate, GETDATE()) > 7
              AND Status = 'Open'
        )
            THROW 50006, 'No complaints found for escalation.', 1;

        UPDATE labTest.Complaint
        SET
            EscalationDate = GETDATE(),
            Status = 'Escalated'
        WHERE DATEDIFF(DAY, ComplaintDate, GETDATE()) > 7
          AND Status = 'Open';

        IF @@ROWCOUNT = 0
            THROW 50007, 'No complaints updated.', 1;

        COMMIT TRANSACTION;

    END TRY

    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;

    END CATCH
END;


exec labTest.HandleComplaints
select * from labTest.Complaint


--3

CREATE TABLE labTest.Train
(
    TrainId INT IDENTITY(1,1) PRIMARY KEY,
    TrainName VARCHAR(100) NOT NULL,
    TotalSeats INT NOT NULL,
    AvailableSeats INT NOT NULL
);

CREATE TABLE labTest.Reservation
(
    ReservationId INT IDENTITY(1,1) PRIMARY KEY,
    TrainId INT NOT NULL,
    PassengerName VARCHAR(100) NOT NULL,
    SeatsBooked INT NOT NULL,
    ReservationStatus VARCHAR(20) NOT NULL,
    ReservationDate DATE NOT NULL,

    CONSTRAINT FK_Reservation_Train
        FOREIGN KEY (TrainId)
        REFERENCES labTest.Train(TrainId)
);

INSERT INTO labTest.Train
(
    TrainName,
    TotalSeats,
    AvailableSeats
)
VALUES
('Rajdhani Express', 500, 500),
('Shatabdi Express', 300, 300),
('Duronto Express', 400, 400);

INSERT INTO labTest.Reservation
(
    TrainId,
    PassengerName,
    SeatsBooked,
    ReservationStatus,
    ReservationDate
)
VALUES
(1, 'Rajiv Kumar', 2, 'Confirmed', '2026-11-01'),
(1, 'Asish Roy', 3, 'Cancelled', '2026-11-02'),
(1, 'Bipin Gupta', 1, 'Confirmed', '2026-11-03'),

(2, 'Sourav Patra', 4, 'Confirmed', '2026-11-04'),
(2, 'Ankit Das', 2, 'Cancelled', '2026-11-05'),

(3, 'Rohit Sen', 5, 'Confirmed', '2026-11-06'),
(3, 'Arijit Ghosh', 2, 'Cancelled', '2026-11-07');

CREATE OR ALTER PROCEDURE labTest.UpdateTrainSeats
AS
BEGIN
    DECLARE @TrainId INT,
            @SeatsBooked INT,
            @ReservationStatus VARCHAR(20);

    DECLARE ReservationCursor CURSOR
    FOR
    SELECT
        TrainId,
        SeatsBooked,
        ReservationStatus
    FROM labTest.Reservation;

    OPEN ReservationCursor;

    FETCH NEXT FROM ReservationCursor
    INTO @TrainId, @SeatsBooked, @ReservationStatus;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        IF @ReservationStatus = 'Confirmed'
        BEGIN
            UPDATE labTest.Train
            SET AvailableSeats = AvailableSeats - @SeatsBooked
            WHERE TrainId = @TrainId;
        END
        ELSE IF @ReservationStatus = 'Cancelled'
        BEGIN
            UPDATE labTest.Train
            SET AvailableSeats = AvailableSeats + @SeatsBooked
            WHERE TrainId = @TrainId;
        END

        FETCH NEXT FROM ReservationCursor
        INTO @TrainId, @SeatsBooked, @ReservationStatus;

    END

    CLOSE ReservationCursor;
    DEALLOCATE ReservationCursor;
END;
GO


EXEC labTest.UpdateTrainSeats;

SELECT *
FROM labTest.Train;


--5

CREATE TABLE labTest.Product
(
    ProductId INT PRIMARY KEY,
    ProductName VARCHAR(100) NOT NULL,
    StockQuantity INT NOT NULL
);

CREATE TABLE labTest.Transactions
(
    TransactionId INT IDENTITY(1,1) PRIMARY KEY,
    ProductId INT NOT NULL,
    TransactionType VARCHAR(20) NOT NULL,
    Quantity INT NOT NULL,
    TransactionDate DATE NOT NULL,

    CONSTRAINT FK_Transactions_Products
        FOREIGN KEY (ProductId)
        REFERENCES labTest.Product(ProductId)
);

INSERT INTO labTest.Product
VALUES
(101, 'Laptop', 50),
(102, 'Keyboard', 100),
(103, 'Mouse', 75),
(104, 'Monitor', 40);

INSERT INTO labTest.Transactions
(
    ProductId,
    TransactionType,
    Quantity,
    TransactionDate
)
VALUES
(101, 'Purchase', 10, '2026-11-18'),
(101, 'Sale', 5, '2026-11-18'),

(102, 'Sale', 20, '2026-11-18'),
(102, 'Purchase', 15, '2026-11-19'),

(103, 'Sale', 10, '2026-11-19'),
(103, 'Purchase', 5, '2026-11-19'),

(104, 'Sale', 8, '2026-11-20'),
(104, 'Purchase', 12, '2026-11-20');


CREATE OR ALTER PROC labTest.UpdateStock
AS
BEGIN

    DECLARE
        @ProductId INT,
        @TransactionType VARCHAR(20),
        @Quantity INT;

    DECLARE TransactionCursor CURSOR
    FOR
    SELECT
        ProductId,
        TransactionType,
        Quantity
    FROM labTest.Transactions;

    OPEN TransactionCursor;

    FETCH NEXT FROM TransactionCursor
    INTO @ProductId, @TransactionType, @Quantity;

    WHILE @@FETCH_STATUS = 0
    BEGIN

        IF @TransactionType = 'Purchase'
        BEGIN
            UPDATE labTest.Product
            SET StockQuantity = StockQuantity + @Quantity
            WHERE ProductId = @ProductId;
        END
        ELSE IF @TransactionType = 'Sale'
        BEGIN
            UPDATE labTest.Product
            SET StockQuantity = StockQuantity - @Quantity
            WHERE ProductId = @ProductId;
        END

        FETCH NEXT FROM TransactionCursor
        INTO @ProductId, @TransactionType, @Quantity;

    END

    CLOSE TransactionCursor;
    DEALLOCATE TransactionCursor;

END;
GO