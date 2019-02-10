CREATE FUNCTION [input].[fn_store__promotion] ()
RETURNS 
@result TABLE 
(
	store_bk nvarchar(255) not null,
	promotion_bk nvarchar(255) not null
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	/****** Script for SelectTopNRows command from SSMS  ******/
	INSERT INTO @result (store_bk, promotion_bk)
	SELECT DISTINCT
		sto.StoreName	     as store_bk,
		prm.PromotionNumber as promotion_bk
	FROM [Shufersal].[dbo].[Staging_promotions] prm
		LEFT JOIN [Shufersal].[dbo].[Staging_transactions_total] prd		     ON prm.ProductNumber = prd.ProductNumber
		LEFT JOIN [Shufersal].[dbo].[Staging_stores] sto						ON prd.StoreFormatCode = sto.#LocationID
	WHERE sto.StoreName IS NOT NULL
	AND prm.PromotionNumber IS NOT NULL

	RETURN 
END