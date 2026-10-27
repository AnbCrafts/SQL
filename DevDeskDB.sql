-- ============================================================================
-- DevDesk Database Schema with Role-Based Access Control (RBAC)
-- Database: DevDesk_DB
-- File: F:\MCC_Practice\SQL\DevDeskDB.sql
-- ============================================================================

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'DevDesk_DB')
BEGIN
    CREATE DATABASE DevDesk_DB;
END
GO

USE DevDesk_DB;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- 1. ROLES TABLE (RBAC Foundation)
-- Roles: 'Employee', 'ITSupport', 'Admin'
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Roles')
BEGIN
    CREATE TABLE Roles (
        RoleId INT IDENTITY(1,1) PRIMARY KEY,
        RoleName NVARCHAR(50) NOT NULL UNIQUE,
        Description NVARCHAR(255) NULL
    );
END
GO

-- 2. USERS TABLE
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Users')
BEGIN
    CREATE TABLE Users (
        UserId INT IDENTITY(1,1) PRIMARY KEY,
        RoleId INT NOT NULL,
        FullName NVARCHAR(100) NOT NULL,
        Email NVARCHAR(120) NOT NULL UNIQUE,
        Password NVARCHAR(100) NOT NULL,
        Department NVARCHAR(50) NOT NULL,
        PhoneNumber NVARCHAR(20) NULL,
        IsActive BIT NOT NULL DEFAULT 1,
        CreatedAt DATETIME DEFAULT GETDATE(),
        CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleId) REFERENCES Roles(RoleId)
    );
END
GO

-- 3. ASSETS TABLE (Hardware & Inventory)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Assets')
BEGIN
    CREATE TABLE Assets (
        AssetId INT IDENTITY(1,1) PRIMARY KEY,
        AssetTag NVARCHAR(50) NOT NULL UNIQUE,
        AssetName NVARCHAR(100) NOT NULL,
        Category NVARCHAR(50) NOT NULL,
        SerialNumber NVARCHAR(100) NULL,
        PurchaseCost DECIMAL(10, 2) NOT NULL,
        PurchaseDate DATE NOT NULL,
        Status NVARCHAR(30) DEFAULT 'Available',
        AssignedToUserId INT NULL,
        CONSTRAINT FK_Assets_Users FOREIGN KEY (AssignedToUserId) REFERENCES Users(UserId)
    );
END
GO

-- 4. TICKETS TABLE (Support Requests)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Tickets')
BEGIN
    CREATE TABLE Tickets (
        TicketId INT IDENTITY(1,1) PRIMARY KEY,
        TicketNumber AS ('TCK-' + RIGHT('00000' + CAST(TicketId AS NVARCHAR(10)), 5)) PERSISTED,
        CreatedByUserId INT NOT NULL,
        AssignedToUserId INT NULL,
        RelatedAssetId INT NULL,
        Title NVARCHAR(150) NOT NULL,
        Description NVARCHAR(MAX) NOT NULL,
        Category NVARCHAR(50) NOT NULL,
        Priority NVARCHAR(20) NOT NULL DEFAULT 'Medium',
        Status NVARCHAR(30) NOT NULL DEFAULT 'Open',
        EstimatedHours DECIMAL(4, 1) NULL,
        CreatedAt DATETIME DEFAULT GETDATE(),
        ResolvedAt DATETIME NULL,
        CONSTRAINT FK_Tickets_CreatedBy FOREIGN KEY (CreatedByUserId) REFERENCES Users(UserId),
        CONSTRAINT FK_Tickets_AssignedTo FOREIGN KEY (AssignedToUserId) REFERENCES Users(UserId),
        CONSTRAINT FK_Tickets_Assets FOREIGN KEY (RelatedAssetId) REFERENCES Assets(AssetId)
    );
END
GO

-- 5. TICKET UPDATES / ACTIVITY LOG TABLE (For AJAX real-time comments)
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'TicketUpdates')
BEGIN
    CREATE TABLE TicketUpdates (
        UpdateId INT IDENTITY(1,1) PRIMARY KEY,
        TicketId INT NOT NULL,
        UserId INT NOT NULL,
        CommentText NVARCHAR(MAX) NOT NULL,
        IsInternalNote BIT NOT NULL DEFAULT 0,
        CreatedAt DATETIME DEFAULT GETDATE(),
        CONSTRAINT FK_TicketUpdates_Tickets FOREIGN KEY (TicketId) REFERENCES Tickets(TicketId) ON DELETE CASCADE,
        CONSTRAINT FK_TicketUpdates_Users FOREIGN KEY (UserId) REFERENCES Users(UserId)
    );
END
GO

-- ============================================================================
-- SEED DATA (Roles, Demo Users, Sample Assets & Tickets)
-- ============================================================================

-- Seed Roles
IF NOT EXISTS (SELECT 1 FROM Roles)
BEGIN
    SET IDENTITY_INSERT Roles ON;
    INSERT INTO Roles (RoleId, RoleName, Description)
    VALUES 
    (1, 'Employee', 'Regular employees who raise support tickets and view their assigned assets.'),
    (2, 'ITSupport', 'IT Staff who resolve tickets, add internal notes, and manage assets.'),
    (3, 'Admin', 'Super administrators with full system access and role management.');
    SET IDENTITY_INSERT Roles OFF;
END
GO

-- Seed Users (Passwords for all: User@123)
IF NOT EXISTS (SELECT 1 FROM Users)
BEGIN
    SET IDENTITY_INSERT Users ON;
    INSERT INTO Users (UserId, RoleId, FullName, Email, Password, Department, PhoneNumber)
    VALUES
    (1, 3, 'Sarah Connor (Admin)', 'admin@devdesk.com', 'User@123', 'IT Management', '555-0101'),
    (2, 2, 'David Miller (IT Support)', 'support@devdesk.com', 'User@123', 'IT Operations', '555-0102'),
    (3, 1, 'Emily Watson (Finance)', 'emily@company.com', 'User@123', 'Finance', '555-0201'),
    (4, 1, 'Michael Chang (Engineering)', 'michael@company.com', 'User@123', 'Engineering', '555-0202');
    SET IDENTITY_INSERT Users OFF;
END
GO

-- Seed Assets
IF NOT EXISTS (SELECT 1 FROM Assets)
BEGIN
    INSERT INTO Assets (AssetTag, AssetName, Category, SerialNumber, PurchaseCost, PurchaseDate, Status, AssignedToUserId)
    VALUES
    ('LAP-2026-001', 'Dell Precision 5570', 'Laptop', 'SN-DELL-88392', 1850.00, '2026-01-15', 'Assigned', 4),
    ('LAP-2026-002', 'MacBook Pro 16 M3', 'Laptop', 'SN-APPL-99211', 2499.00, '2026-02-10', 'Assigned', 3),
    ('MON-2026-010', 'Dell UltraSharp 27 4K', 'Monitor', 'SN-MON-11442', 420.00, '2026-01-20', 'Assigned', 4),
    ('LAP-2026-003', 'ThinkPad T14 Gen 4', 'Laptop', 'SN-LEN-44321', 1250.00, '2026-03-01', 'Available', NULL),
    ('KEY-2026-050', 'Logitech MX Master 3S', 'Accessories', 'SN-LOGI-7711', 99.00, '2026-03-05', 'Available', NULL);
END
GO

-- Seed Tickets
IF NOT EXISTS (SELECT 1 FROM Tickets)
BEGIN
    INSERT INTO Tickets (CreatedByUserId, AssignedToUserId, RelatedAssetId, Title, Description, Category, Priority, Status, EstimatedHours)
    VALUES
    (3, 2, 2, 'Screen flickering on MacBook Pro', 'External monitor intermittently loses signal during video calls.', 'Hardware', 'High', 'In Progress', 2.5),
    (4, 2, 1, 'VPN access required for staging server', 'Need OpenVPN profile configured for staging database access.', 'Access Request', 'Medium', 'Open', 1.0),
    (3, NULL, NULL, 'Request software license for Adobe Acrobat Pro', 'Need to sign confidential audit PDFs.', 'Software', 'Low', 'Open', 0.5);
END
GO

-- Seed Ticket Updates / Conversation Notes
IF NOT EXISTS (SELECT 1 FROM TicketUpdates)
BEGIN
    INSERT INTO TicketUpdates (TicketId, UserId, CommentText, IsInternalNote)
    VALUES
    (1, 3, 'Issue started happening after the recent macOS update.', 0),
    (1, 2, 'Tested with a different Thunderbolt cable; ordering replacement dongle.', 1),
    (1, 2, 'Hi Emily, replacement adapter has been ordered. Will test tomorrow.', 0);
END
GO

-- 6. VERIFICATION SUMMARY
SELECT 'Roles' AS TableName, COUNT(*) AS TotalRows FROM Roles
UNION ALL
SELECT 'Users' AS TableName, COUNT(*) AS TotalRows FROM Users
UNION ALL
SELECT 'Assets' AS TableName, COUNT(*) AS TotalRows FROM Assets
UNION ALL
SELECT 'Tickets' AS TableName, COUNT(*) AS TotalRows FROM Tickets
UNION ALL
SELECT 'TicketUpdates' AS TableName, COUNT(*) AS TotalRows FROM TicketUpdates;
GO


