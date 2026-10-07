DECLARE cursor_product CURSOR
FOR
SELECT
    p.productName,p.productId
FROM labTest.products as p;

OPEN cursor_product;

DECLARE
    @product_name VARCHAR(MAX),
    @product_id DECIMAL(10,2);

FETCH NEXT FROM cursor_product
INTO @product_name, @product_id;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT @product_name + ' - ' + CAST(@product_id AS VARCHAR(50)) ;

    FETCH NEXT FROM cursor_product
    INTO @product_name, @product_id;
END;

CLOSE cursor_product;
DEALLOCATE cursor_product;