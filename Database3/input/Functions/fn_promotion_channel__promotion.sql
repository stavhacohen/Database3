CREATE FUNCTION [input].[fn_promotion_channel__promotion] ()
RETURNS 
@result TABLE 
(
	promotionchannel_bk nvarchar(255) not null,
	promotion_bk nvarchar(255) not null
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	/****** Script for SelectTopNRows command from SSMS  ******/
	INSERT INTO @result (promotionchannel_bk, promotion_bk)

	SELECT DISTINCT
			'newspaper'		as promotionchannel_bk,
			PromotionNumber as promotion_bk
		FROM [Shufersal].[dbo].[Staging_promotions_2017]			 pro
		LEFT JOIN [Shufersal].[dbo].[Staging_promotions_display] prd	ON pro.PromotionNumberUnv = prd.Promotion_ID
	WHERE Newspaper_chapter = 1 

	UNION ALL 

		SELECT DISTINCT
			'newspaper'		as promotionchannel_bk,
			PromotionNumber as promotion_bk
		FROM [Shufersal].[dbo].[Staging_promotions_new]			 pro
		LEFT JOIN [Shufersal].[dbo].[Staging_promotions_display] prd	ON pro.PromotionNumberUnv = prd.Promotion_ID
	WHERE Newspaper_chapter = 1 
		
	RETURN 
END