-- ============================================================================
-- DevHelper Learning Platform Database Script
-- Database: DevHelper_DB (or Practice)
-- Purpose: Dynamic topic management, theory notes, and progress tracking
-- ============================================================================

-- 1. Create Database if not exists (Uncomment if creating fresh DB)
-- CREATE DATABASE DevHelper_DB;
-- GO
-- USE DevHelper_DB;
-- GO

-- 2. Create Learning Modules / Categories Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Modules')
BEGIN
    CREATE TABLE Modules (
        ModuleId INT IDENTITY(1,1) PRIMARY KEY,
        ModuleName NVARCHAR(100) NOT NULL,
        ShortDesc NVARCHAR(255) NULL,
        IconClass NVARCHAR(50) DEFAULT 'bi-folder',
        BadgeColor NVARCHAR(30) DEFAULT 'bg-primary',
        DisplayOrder INT NOT NULL DEFAULT 1
    );
END
GO

-- 3. Create Topics Table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Topics')
BEGIN
    CREATE TABLE Topics (
        TopicId INT IDENTITY(1,1) PRIMARY KEY,
        ModuleId INT NOT NULL,
        Title NVARCHAR(150) NOT NULL,
        Slug NVARCHAR(100) NOT NULL UNIQUE,
        PageUrl NVARCHAR(255) NOT NULL,
        Difficulty NVARCHAR(20) DEFAULT 'Beginner', -- 'Beginner', 'Intermediate', 'Advanced'
        Summary NVARCHAR(500) NOT NULL,
        KeyTakeaways NVARCHAR(MAX) NULL,
        Status NVARCHAR(20) DEFAULT 'Not Started',   -- 'Not Started', 'In Progress', 'Completed'
        PracticeNotes NVARCHAR(MAX) NULL,
        LastUpdated DATETIME DEFAULT GETDATE(),
        CONSTRAINT FK_Topics_Modules FOREIGN KEY (ModuleId) REFERENCES Modules(ModuleId) ON DELETE CASCADE
    );
END
GO

-- 4. Seed Modules
IF NOT EXISTS (SELECT 1 FROM Modules)
BEGIN
    SET IDENTITY_INSERT Modules ON;
    INSERT INTO Modules (ModuleId, ModuleName, ShortDesc, IconClass, BadgeColor, DisplayOrder)
    VALUES
    (1, 'Architecture & Core Mental Model', 'How Web Forms works, Code-Behind, and the Page Life Cycle.', 'bi-diagram-3', 'bg-primary', 1),
    (2, 'Server Controls & Validation', 'Standard web controls and client/server validation controls.', 'bi-input-cursor-text', 'bg-success', 2),
    (3, 'Master Pages & Reusable Layouts', 'Layout inheritance, Site.Master, and custom user controls (.ascx).', 'bi-window-stack', 'bg-info', 3),
    (4, 'State Management', 'ViewState, Session, Cookies, Application state, and query strings.', 'bi-database-check', 'bg-warning text-dark', 4),
    (5, 'Data Binding & Rich Grid Controls', 'GridView, Repeater, ListView, DataTables, and ADO.NET.', 'bi-table', 'bg-danger', 5),
    (6, 'ASP.NET AJAX & Partial Rendering', 'ScriptManager, UpdatePanel, and flicker-free partial page updates.', 'bi-lightning-charge', 'bg-secondary', 6),
    (7, 'Security & Authentication', 'Forms Authentication, user sessions, role management, and SQL safety.', 'bi-shield-lock', 'bg-dark', 7),
    (8, 'Bridge: Web Forms to Web API', 'From server-rendered HTML pages to JSON/RESTful HTTP services.', 'bi-arrow-left-right', 'bg-primary', 8);
    SET IDENTITY_INSERT Modules OFF;
END
GO

-- 5. Seed Core Topics
IF NOT EXISTS (SELECT 1 FROM Topics)
BEGIN
    INSERT INTO Topics (ModuleId, Title, Slug, PageUrl, Difficulty, Summary, KeyTakeaways, Status)
    VALUES
    -- Module 1
    (1, 'Page Life Cycle & IsPostBack', 'page-lifecycle', '~/Labs/LifeCycleLab.aspx', 'Beginner',
        'Learn the 9 stages of page execution and master initial GET vs submit POST.',
        '1. PreInit -> Init -> LoadViewState -> Page_Load -> Events -> PreRender -> SaveViewState -> Render -> Unload.
2. IsPostBack check prevents wiping out user input on button clicks.
3. Every button click executes the whole lifecycle from scratch.',
        'Completed'),

    -- Module 2
    (2, 'Server Controls & Two-Layer Validation', 'validation-controls', '~/Labs/ValidationLab.aspx', 'Beginner',
        'Build forms with RequiredField, Range, RegularExpression, and Compare validators.',
        '1. runat="server" promotes HTML into a C# object.
2. Validators validate both in Browser (JS) and Server (Page.IsValid).
3. CausesValidation="false" bypasses checks for Cancel/Clear buttons.',
        'In Progress'),

    -- Module 3
    (3, 'Master Pages & User Controls (.ascx)', 'master-pages', '~/Labs/MasterPagesLab.aspx', 'Beginner',
        'Create modular layouts with ContentPlaceHolder and encapsulate widgets into .ascx.',
        '1. Site.Master defines shared header, navigation, and footer.
2. Child .aspx pages inject into ContentPlaceHolder using asp:Content.
3. User Controls (.ascx) create reusable UI components with their own C# events.',
        'Not Started'),

    -- Module 4
    (4, 'ViewState vs Session vs Application', 'state-management', '~/Labs/StateLab.aspx', 'Intermediate',
        'Demystify how Web Forms remembers state across stateless HTTP requests.',
        '1. ViewState: Serialized base64 hidden field (__VIEWSTATE) specific to one page.
2. Session: Server-side RAM specific to one logged-in browser session.
3. Application: Shared across all users and all tabs globally.',
        'Not Started'),

    -- Module 5
    (5, 'GridView CRUD & Data Binding Lab', 'gridview-crud', '~/Labs/GridViewLab.aspx', 'Intermediate',
        'Connect SQL Server / DataTables to GridView with sorting, editing, and deleting.',
        '1. DataSource + DataBind() turns C# collections into an HTML table.
2. BoundField outputs raw text; TemplateField allows custom badges and buttons.
3. DataKeyNames stores primary keys safely across postbacks.',
        'Not Started'),

    -- Module 6
    (6, 'UpdatePanel & Partial PostBack (AJAX)', 'updatepanel-ajax', '~/Labs/AjaxLab.aspx', 'Intermediate',
        'Update parts of your webpage asynchronously without full-page reloads.',
        '1. ScriptManager registers client scripts and manages AJAX communication.
2. Controls inside UpdatePanel perform async postbacks without page flicker.
3. UpdateProgress shows loading indicators during background operations.',
        'Not Started'),

    -- Module 7
    (7, 'Forms Authentication & User Sessions', 'auth-security', '~/Labs/AuthLab.aspx', 'Advanced',
        'Implement login tickets, password protection, and role-based page guards.',
        '1. FormsAuthentication creates encrypted HTTP auth cookies.
2. Session guards redirect unauthenticated users to Login.aspx.
3. Always use SQL Parameters to prevent SQL Injection.',
        'Not Started'),

    -- Module 8
    (8, 'Calling Web Methods & Transition to Web API', 'webforms-to-webapi', '~/Labs/WebMethodLab.aspx', 'Advanced',
        'Expose [WebMethod] endpoints for client JavaScript fetch() and prepare for Web API.',
        '1. [WebMethod] in Web Forms returns JSON instead of rendering HTML.
2. Client fetch() / jQuery $.ajax can call server C# methods directly.
3. Foundation for transitioning to ASP.NET Web API 2 and RESTful controllers.',
        'Not Started');
END
GO

-- 6. Stored Procedures

-- Procedure: Get all modules with topic counts and completion percentage
CREATE OR ALTER PROCEDURE sp_GetModulesDashboard
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        m.ModuleId,
        m.ModuleName,
        m.ShortDesc,
        m.IconClass,
        m.BadgeColor,
        m.DisplayOrder,
        COUNT(t.TopicId) AS TotalTopics,
        SUM(CASE WHEN t.Status = 'Completed' THEN 1 ELSE 0 END) AS CompletedTopics
    FROM Modules m
    LEFT JOIN Topics t ON m.ModuleId = t.ModuleId
    GROUP BY m.ModuleId, m.ModuleName, m.ShortDesc, m.IconClass, m.BadgeColor, m.DisplayOrder
    ORDER BY m.DisplayOrder ASC;
END
GO

-- Procedure: Get all topics for a module
CREATE OR ALTER PROCEDURE sp_GetTopicsByModule
    @ModuleId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        TopicId,
        ModuleId,
        Title,
        Slug,
        PageUrl,
        Difficulty,
        Summary,
        KeyTakeaways,
        Status,
        PracticeNotes,
        LastUpdated
    FROM Topics
    WHERE ModuleId = @ModuleId
    ORDER BY TopicId ASC;
END
GO

-- Procedure: Update Topic Status and Practice Notes
CREATE OR ALTER PROCEDURE sp_UpdateTopicProgress
    @TopicId INT,
    @Status NVARCHAR(20),
    @Notes NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE Topics
    SET Status = @Status,
        PracticeNotes = COALESCE(@Notes, PracticeNotes),
        LastUpdated = GETDATE()
    WHERE TopicId = @TopicId;
END
GO

-- 7. Verification Query
SELECT 'Modules Created' AS Entity, COUNT(*) AS TotalCount FROM Modules
UNION ALL
SELECT 'Topics Seeded' AS Entity, COUNT(*) AS TotalCount FROM Topics;
GO
