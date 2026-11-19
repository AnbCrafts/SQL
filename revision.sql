select * from labTest.QueryUser
order by Gender
offset 10 rows
--fetch Next 20 rows only
fetch first 20 rows only

--Pagination

declare @pageSize INT = 10
declare @pageNumber INT = 2
select * from labTest.QueryUser
order by Gender desc
offset (@pageNumber-1)*@pageSize rows
--fetch Next 20 rows only
fetch first @pageSize rows only