-- ============================================================================
-- DevDesk Database Stored Procedures
-- Database: DevDesk_DB
-- ============================================================================

USE DevDesk_DB;
GO

SET ANSI_NULLS ON;
GO
SET QUOTED_IDENTIFIER ON;
GO

-- 1. AUTHENTICATE USER (LOGIN)
CREATE OR ALTER PROCEDURE sp_AuthenticateUser
    @Email NVARCHAR(120),
    @Password NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        u.UserId,
        u.FullName,
        u.Email,
        u.Department,
        u.PhoneNumber,
        r.RoleId,
        r.RoleName
    FROM Users u
    INNER JOIN Roles r ON u.RoleId = r.RoleId
    WHERE LOWER(u.Email) = LOWER(@Email)
      AND u.Password = @Password
      AND u.IsActive = 1;
END
GO

-- 2. REGISTER NEW EMPLOYEE
CREATE OR ALTER PROCEDURE sp_RegisterUser
    @FullName NVARCHAR(100),
    @Email NVARCHAR(120),
    @Password NVARCHAR(100),
    @Department NVARCHAR(50),
    @PhoneNumber NVARCHAR(20) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    -- Check if email already exists
    IF EXISTS (SELECT 1 FROM Users WHERE LOWER(Email) = LOWER(@Email))
    BEGIN
        RAISERROR('An account with this email address already exists.', 16, 1);
        RETURN;
    END

    -- Default RoleId = 1 (Employee)
    INSERT INTO Users (RoleId, FullName, Email, Password, Department, PhoneNumber, IsActive)
    VALUES (1, @FullName, @Email, @Password, @Department, @PhoneNumber, 1);

    SELECT SCOPE_IDENTITY() AS NewUserId;
END
GO

-- 3. GET ROLE-BASED DASHBOARD COUNTERS
CREATE OR ALTER PROCEDURE sp_GetDashboardStats
    @UserId INT,
    @RoleName NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF @RoleName = 'Employee'
    BEGIN
        SELECT 
            COUNT(CASE WHEN Status != 'Closed' AND Status != 'Resolved' THEN 1 END) AS MyOpenTickets,
            COUNT(CASE WHEN Status = 'Resolved' THEN 1 END) AS MyResolvedTickets,
            (SELECT COUNT(*) FROM Assets WHERE AssignedToUserId = @UserId) AS MyAssignedAssets,
            (SELECT COUNT(*) FROM Tickets WHERE CreatedByUserId = @UserId) AS MyTotalTickets
        FROM Tickets 
        WHERE CreatedByUserId = @UserId;
    END
    ELSE
    BEGIN
        -- IT Support & Admin View
        SELECT 
            COUNT(CASE WHEN Status = 'Open' THEN 1 END) AS OpenTickets,
            COUNT(CASE WHEN Status = 'In Progress' THEN 1 END) AS InProgressTickets,
            COUNT(CASE WHEN Priority = 'Critical' AND Status != 'Closed' THEN 1 END) AS CriticalTickets,
            COUNT(CASE WHEN AssignedToUserId IS NULL AND Status != 'Closed' THEN 1 END) AS UnassignedTickets,
            (SELECT COUNT(*) FROM Assets WHERE Status = 'Available') AS AvailableAssets,
            (SELECT COUNT(*) FROM Assets WHERE Status = 'Assigned') AS AssignedAssets
        FROM Tickets;
    END
END
GO

-- 4. CREATE SUPPORT TICKET
CREATE OR ALTER PROCEDURE sp_CreateTicket
    @CreatedByUserId INT,
    @Title NVARCHAR(150),
    @Description NVARCHAR(MAX),
    @Category NVARCHAR(50),
    @Priority NVARCHAR(20),
    @RelatedAssetId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO Tickets (CreatedByUserId, Title, Description, Category, Priority, RelatedAssetId, Status, CreatedAt)
    VALUES (@CreatedByUserId, @Title, @Description, @Category, @Priority, @RelatedAssetId, 'Open', GETDATE());

    SELECT SCOPE_IDENTITY() AS NewTicketId;
END
GO

-- 5. GET TICKETS LIST (FOR GRIDVIEW)
CREATE OR ALTER PROCEDURE sp_GetTicketsList
    @UserId INT,
    @RoleName NVARCHAR(50),
    @StatusFilter NVARCHAR(30) = NULL,
    @PriorityFilter NVARCHAR(30) = NULL,
    @SearchText NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        t.TicketId,
        t.TicketNumber,
        t.Title,
        t.Category,
        t.Priority,
        t.Status,
        t.CreatedAt,
        t.ResolvedAt,
        uCreator.FullName AS CreatedByName,
        uCreator.Department AS Department,
        COALESCE(uAssigned.FullName, 'Unassigned') AS AssignedToName,
        a.AssetTag,
        a.AssetName
    FROM Tickets t
    INNER JOIN Users uCreator ON t.CreatedByUserId = uCreator.UserId
    LEFT JOIN Users uAssigned ON t.AssignedToUserId = uAssigned.UserId
    LEFT JOIN Assets a ON t.RelatedAssetId = a.AssetId
    WHERE (@RoleName != 'Employee' OR t.CreatedByUserId = @UserId)
      AND (@StatusFilter IS NULL OR @StatusFilter = '' OR t.Status = @StatusFilter)
      AND (@PriorityFilter IS NULL OR @PriorityFilter = '' OR t.Priority = @PriorityFilter)
      AND (
          @SearchText IS NULL OR @SearchText = '' 
          OR t.Title LIKE '%' + @SearchText + '%' 
          OR t.TicketNumber LIKE '%' + @SearchText + '%'
          OR uCreator.FullName LIKE '%' + @SearchText + '%'
      )
    ORDER BY 
        CASE WHEN t.Priority = 'Critical' THEN 1
             WHEN t.Priority = 'High' THEN 2
             WHEN t.Priority = 'Medium' THEN 3
             ELSE 4 END ASC,
        t.CreatedAt DESC;
END
GO

-- 6. GET SINGLE TICKET BY ID
CREATE OR ALTER PROCEDURE sp_GetTicketById
    @TicketId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        t.TicketId,
        t.TicketNumber,
        t.CreatedByUserId,
        t.AssignedToUserId,
        t.RelatedAssetId,
        t.Title,
        t.Description,
        t.Category,
        t.Priority,
        t.Status,
        t.EstimatedHours,
        t.CreatedAt,
        t.ResolvedAt,
        uCreator.FullName AS CreatedByName,
        uCreator.Email AS CreatedByEmail,
        uCreator.Department AS CreatedByDepartment,
        uCreator.PhoneNumber AS CreatedByPhone,
        uAssigned.FullName AS AssignedToName,
        a.AssetTag,
        a.AssetName
    FROM Tickets t
    INNER JOIN Users uCreator ON t.CreatedByUserId = uCreator.UserId
    LEFT JOIN Users uAssigned ON t.AssignedToUserId = uAssigned.UserId
    LEFT JOIN Assets a ON t.RelatedAssetId = a.AssetId
    WHERE t.TicketId = @TicketId;
END
GO

-- 7. UPDATE TICKET STATUS & ASSIGNMENT
CREATE OR ALTER PROCEDURE sp_UpdateTicketStatus
    @TicketId INT,
    @Status NVARCHAR(30),
    @AssignedToUserId INT = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Tickets
    SET Status = @Status,
        AssignedToUserId = COALESCE(@AssignedToUserId, AssignedToUserId),
        ResolvedAt = CASE WHEN @Status IN ('Resolved', 'Closed') AND ResolvedAt IS NULL THEN GETDATE() 
                          WHEN @Status NOT IN ('Resolved', 'Closed') THEN NULL
                          ELSE ResolvedAt END
    WHERE TicketId = @TicketId;
END
GO

-- 8. GET TICKET UPDATES (AJAX COMMENTS THREAD)
CREATE OR ALTER PROCEDURE sp_GetTicketUpdates
    @TicketId INT,
    @IsITStaff BIT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        tu.UpdateId,
        tu.TicketId,
        tu.UserId,
        tu.CommentText,
        tu.IsInternalNote,
        tu.CreatedAt,
        u.FullName AS AuthorName,
        r.RoleName AS AuthorRole
    FROM TicketUpdates tu
    INNER JOIN Users u ON tu.UserId = u.UserId
    INNER JOIN Roles r ON u.RoleId = r.RoleId
    WHERE tu.TicketId = @TicketId
      AND (@IsITStaff = 1 OR tu.IsInternalNote = 0)
    ORDER BY tu.CreatedAt ASC;
END
GO

-- 9. ADD TICKET UPDATE / NOTE
CREATE OR ALTER PROCEDURE sp_AddTicketUpdate
    @TicketId INT,
    @UserId INT,
    @CommentText NVARCHAR(MAX),
    @IsInternalNote BIT = 0
AS
BEGIN
    SET NOCOUNT ON;

    INSERT INTO TicketUpdates (TicketId, UserId, CommentText, IsInternalNote, CreatedAt)
    VALUES (@TicketId, @UserId, @CommentText, @IsInternalNote, GETDATE());

    SELECT SCOPE_IDENTITY() AS NewUpdateId;
END
GO

-- 10. GET ALL ASSETS (FOR ASSET MANAGEMENT GRIDVIEW)
CREATE OR ALTER PROCEDURE sp_GetAllAssets
    @CategoryFilter NVARCHAR(50) = NULL,
    @StatusFilter NVARCHAR(30) = NULL,
    @SearchText NVARCHAR(100) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        a.AssetId,
        a.AssetTag,
        a.AssetName,
        a.Category,
        a.SerialNumber,
        a.PurchaseCost,
        a.PurchaseDate,
        a.Status,
        a.AssignedToUserId,
        COALESCE(u.FullName, 'Unassigned') AS AssignedToName,
        u.Department AS AssignedDepartment
    FROM Assets a
    LEFT JOIN Users u ON a.AssignedToUserId = u.UserId
    WHERE (@CategoryFilter IS NULL OR @CategoryFilter = '' OR a.Category = @CategoryFilter)
      AND (@StatusFilter IS NULL OR @StatusFilter = '' OR a.Status = @StatusFilter)
      AND (
          @SearchText IS NULL OR @SearchText = '' 
          OR a.AssetTag LIKE '%' + @SearchText + '%' 
          OR a.AssetName LIKE '%' + @SearchText + '%'
          OR a.SerialNumber LIKE '%' + @SearchText + '%'
      )
    ORDER BY a.AssetId DESC;
END
GO

-- 11. ASSIGN / UNASSIGN ASSET
CREATE OR ALTER PROCEDURE sp_AssignAsset
    @AssetId INT,
    @AssignedToUserId INT = NULL,
    @Status NVARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Assets
    SET AssignedToUserId = @AssignedToUserId,
        Status = @Status
    WHERE AssetId = @AssetId;
END
GO

-- 12. FAST ASSET SEARCH (FOR [WebMethod] / AUTOCOMPLETE)
CREATE OR ALTER PROCEDURE sp_SearchAssetsFast
    @SearchTerm NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT TOP 10 
        AssetId, 
        AssetTag, 
        AssetName, 
        Category, 
        Status
    FROM Assets
    WHERE AssetTag LIKE '%' + @SearchTerm + '%'
       OR AssetName LIKE '%' + @SearchTerm + '%'
       OR SerialNumber LIKE '%' + @SearchTerm + '%';
END
GO

-- ============================================================================
-- VERIFICATION
-- ============================================================================
SELECT ROUTINE_NAME, ROUTINE_TYPE 
FROM INFORMATION_SCHEMA.ROUTINES 
WHERE ROUTINE_TYPE = 'PROCEDURE' 
ORDER BY ROUTINE_NAME;
GO
