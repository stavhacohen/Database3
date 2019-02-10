CREATE FUNCTION [input].[fn_supplier__product] ()
RETURNS 
@result TABLE 
(
	supplier_bk nvarchar(255) not null,
	product_bk nvarchar(255) not null
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	/****** Script for SelectTopNRows command from SSMS  ******/
	INSERT INTO @result (supplier_bk, product_bk)
	SELECT distinct
		sup.Supplier_ID as supplier_bk,
		pro.Product_ID as product_bk
	FROM [Shufersal].[dbo].[Staging_supplier_assortment] sup 
		LEFT JOIN [Shufersal].[dbo].[Staging_product_assortment] pro ON sup.Product_ID = pro.Product_ID
	WHERE pro.Product_ID IS NOT NULL 
	RETURN 
END