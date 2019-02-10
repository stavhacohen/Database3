CREATE FUNCTION [input].[fn_promotion] ()
RETURNS 
@result TABLE 
(
	bk nvarchar(255) not null,
	name nvarchar(255) not null,
	start_date date not null,
	end_date date,
	place_in_store_bk INT not null,
	campaign_bk INT not null

)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	INSERT INTO @result (bk, name, start_date, end_date, place_in_store_bk, campaign_bk)
	SELECT 
		  PromotionNumber		 				 as bk,
		  PromotionDesc					  		 as name,
		  sp.PromotionStartDate					 as start_date,
		  sp.PromotionEndDate					 as end_date,
		  ISNULL(spd.Promotion_ID,0)	 		 as place_in_store_bk,  
		  CampaignNumberPromo					 as campaign_bk
	FROM [Shufersal].[dbo].[Staging_promotions] sp 
	   LEFT JOIN [Shufersal].[dbo].[Staging_promotions_display] spd ON sp.PromotionNumberUnv = spd.Promotion_ID
	WHERE PromotionNumber IS NOT NULL
		AND PromotionStartDate IS NOT NULL

	RETURN 
END