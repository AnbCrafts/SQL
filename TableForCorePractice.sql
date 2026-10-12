create table ProductTbl
(
Id int identity primary key,
Name varchar(200),
Price decimal(10,2),
Stock int 
)

select * from ProductTbl
delete from ProductTbl where id =2;