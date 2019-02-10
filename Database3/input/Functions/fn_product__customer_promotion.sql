CREATE FUNCTION [input].[fn_product__customer_promotion] ()
RETURNS 
@result TABLE 
(
	product_bk nvarchar(255) not null,
	customer_promotion_bk nvarchar(255) not null
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	/****** Script for SelectTopNRows command from SSMS  ******/
	INSERT INTO @result (product_bk, customer_promotion_bk)
	SELECT DISTINCT
		pra.[Product_ID] as product_bk ,
		CONVERT(VARCHAR(255),cou.[HouseHoldID]) + '|' + cou.[FullCouponNum] as customer_promotion_bk
	FROM [Shufersal].[dbo].[Staging_product_assortment] pra
		LEFT JOIN [Shufersal].[dbo].[Staging_promotions] pro	ON pra.Product_ID = pro.ProductNumber
		LEFT JOIN [Shufersal].[dbo].[Staging_coupons_yr17] cou		ON pro.PromotionNumber = cou.RewardNr
	WHERE cou.FullCouponNum IS NOT NULL
		
	RETURN 
END