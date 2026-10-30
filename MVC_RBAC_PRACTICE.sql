-- =============================================
-- Database Script: MVC RBAC Practice
-- Schema: rbacPractice
-- File: D:\Anubhaw\SQL\MVC_RBAC_PRACTICE.sql
-- =============================================


-- 3. Create Users Table
CREATE TABLE [rbacPractice].[Users]
(
    [UserID]    BIGINT IDENTITY(1,1) NOT NULL,
    [UserName]  VARCHAR(100) NOT NULL,            -- Email / Username (Unique)
    [Roles]     VARCHAR(100) NOT NULL,            -- Comma-separated roles: SUPERADMIN, ADMIN, USER
    [Password]  VARCHAR(100) NOT NULL,            -- Password
    [FullName]  VARCHAR(100) NULL,                -- Optional User Display Name
    [CreatedAt] DATETIME DEFAULT GETDATE(),

    CONSTRAINT [PK_rbacPractice_Users] PRIMARY KEY CLUSTERED ([UserID] ASC),
    CONSTRAINT [UQ_rbacPractice_Users_UserName] UNIQUE ([UserName])
);
PRINT 'Table rbacPractice.Users created successfully.';
GO

-- 4. Insert Test Seed Data (matching the demo slides)
INSERT INTO [rbacPractice].[Users] ([UserName], [Roles], [Password], [FullName])
VALUES 
    ('superadmin@gmail.com', 'SUPERADMIN,ADMIN,USER', 'superadmin', 'Super Administrator'),
    ('admin@gmail.com',      'ADMIN',                  'admin',      'System Administrator'),
    ('adminuser@gmail.com',  'ADMIN,USER',             'adminuser',  'Admin & Standard User'),
    ('user@gmail.com',       'USER',                   'user',       'Standard User');
GO

-- 5. Verify Inserted Data
SELECT 
    [UserID],
    [UserName],
    [Roles],
    [Password],
    [FullName],
    [CreatedAt]
FROM [rbacPractice].[Users];
GO


create proc loginUser
@Username VARCHAR(200),
@Password VARCHAR(100)

as
begin
SELECT * 
FROM rbacPractice.Users 
WHERE 
LOWER(UserName) = LOWER(@UserName) 
AND 
Password = @Password
end;