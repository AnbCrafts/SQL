select * from labTest.QueryUser

--GET ALL USERS

create proc udp_GetAllUsers
as 
begin
select * from labTest.QueryUser
end


--GET USER BY ID
create proc udp_GetUserById
@userId int
as
begin 
select * from labTest.QueryUser as qu where qu.UserId = @userId
end;

-- CREATE USER

CREATE PROC udp_CreateUser
(
    @UserName      VARCHAR(100),
    @Email         VARCHAR(200),

    @FullName      VARCHAR(200) = NULL,
    @MobileNo      VARCHAR(20)  = NULL,
    @City          VARCHAR(100) = NULL,
    @StateName     VARCHAR(100) = NULL,
    @Country       VARCHAR(100) = NULL,
    @Gender        VARCHAR(20)  = NULL,
    @QueryText     VARCHAR(MAX) = NULL,
    @QueryAmount   DECIMAL(18,2) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

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
        QueryText,
        CreatedDate,
        IsActive,
        QueryAmount
    )
    VALUES
    (
        @UserName,
        @Email,
        @FullName,
        @MobileNo,
        @City,
        @StateName,
        @Country,
        @Gender,
        @QueryText,
        GETDATE(),
        1,
        @QueryAmount
    );

    SELECT SCOPE_IDENTITY() AS UserId;
END


-- DELETE USER

create proc udp_DeleteUserById
@userId int
as
begin
delete from labTest.QueryUser where UserId = @userId
end;


-- UPDATE USER

CREATE PROC udp_UpdateUser
(
    @UserId        INT,

    @UserName      VARCHAR(100) = NULL,
    @Email         VARCHAR(200) = NULL,
    @FullName      VARCHAR(200) = NULL,
    @MobileNo      VARCHAR(20) = NULL,
    @City          VARCHAR(100) = NULL,
    @StateName     VARCHAR(100) = NULL,
    @Country       VARCHAR(100) = NULL,
    @Gender        VARCHAR(20) = NULL,
    @QueryText     VARCHAR(MAX) = NULL,
    @IsActive      BIT = NULL,
    @QueryAmount   DECIMAL(18,2) = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE labTest.QueryUser
    SET
        UserName    = ISNULL(@UserName, UserName),
        Email       = ISNULL(@Email, Email),
        FullName    = ISNULL(@FullName, FullName),
        MobileNo    = ISNULL(@MobileNo, MobileNo),
        City        = ISNULL(@City, City),
        StateName   = ISNULL(@StateName, StateName),
        Country     = ISNULL(@Country, Country),
        Gender      = ISNULL(@Gender, Gender),
        QueryText   = ISNULL(@QueryText, QueryText),
        IsActive    = ISNULL(@IsActive, IsActive),
        QueryAmount = ISNULL(@QueryAmount, QueryAmount)
    WHERE UserId = @UserId;

    SELECT @@ROWCOUNT AS RowsAffected;
END




-- DYNAMIC PAGING

create proc udp_GetDynamicallyPaginatedUsersList

@pgIndex int,
@pageSize int,
@totalRows int out

as
begin
declare @start int
declare @end int

set @start = (@pgIndex*@pageSize) + 1
set @end = (@pgIndex + 1) * @pageSize

select * from 
(select ROW_NUMBER() over(order by userId) as RowNumber ,* from labTest.QueryUser ) as users
where @start<=RowNumber and RowNumber<=@end

select @totalRows = COUNT(*) from labTest.QueryUser

end;


declare @totalRows int
exec udp_GetDynamicallyPaginatedUsersList 4,20,@totalRows out

print @totalRows



-- small details

create proc udp_GetDynamicallyPaginatedUsersShortDescriptionList

@pgIndex int,
@pageSize int,
@totalRows int out

as
begin
declare @start int
declare @end int

set @start = (@pgIndex*@pageSize) + 1
set @end = (@pgIndex + 1) * @pageSize

select UserId,UserName,Email from 
(select ROW_NUMBER() over(order by userId) as RowNumber ,* from labTest.QueryUser ) as users
where @start<=RowNumber and RowNumber<=@end

select @totalRows = COUNT(*) from labTest.QueryUser

end;


declare @totalRows int
exec udp_GetDynamicallyPaginatedUsersShortDescriptionList 4,20,@totalRows out

print @totalRows

select * from labTest.QueryUser