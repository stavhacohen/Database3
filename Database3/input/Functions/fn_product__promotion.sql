CREATE FUNCTION [input].[fn_product__promotion] ()
RETURNS 
@result TABLE 
(
	product_bk	 nvarchar(255) not null,
	promotion_bk nvarchar(255) not null
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	/****** Script for SelectTopNRows command from SSMS  ******/
	INSERT INTO @result (product_bk, promotion_bk)

	SELECT DISTINCT
			pra.[Product_ID]	as product_bk,
			pro.PromotionNumber	as promotion_bk
	FROM [Shufersal].[dbo].[Staging_product_assortment] pra
		LEFT JOIN [Shufersal].[dbo].[Staging_promotions] pro ON pra.Product_ID = pra.Product_ID


	RETURN 
END
