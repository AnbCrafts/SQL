SET STATISTICS IO ON;
SET STATISTICS TIME ON;

SELECT
    Id,
    ProductName,
    CustomerId
FROM labTest.tblOrder
WHERE ProductId = 'Product -101';

