CREATE FUNCTION [input].[fn_customer_promotion] ()
RETURNS 
@result TABLE 
(
	bk nvarchar(255) not null,
	name nvarchar(255) not null,
	campaign_bk nvarchar(255) not null,
	customer_bk nvarchar(255) not null
)
AS
BEGIN
	insert into @result (bk, name, campaign_bk, customer_bk)
	SELECT CONVERT(VARCHAR(255),[HouseHoldID]) + '|' + [FullCouponNum] as bk
		,Offername as name
		,CampaignNumberPromo as campaign_bk
		,HouseHoldID as customer_bk
	FROM [Shufersal].[dbo].[Staging_coupons_yr17] sc
	   LEFT JOIN [Shufersal].[dbo].[Staging_promotions_2017] sp ON sc.RewardNr = sp.PromotionNumber
	WHERE CampaignNumberPromo IS NOT NULL
	--UNION ALL

	--SELECT CONVERT(VARCHAR(255),[HouseHoldID]) + '|' + CONVERT(VARCHAR(255),[RewardNr]) as bk
	--	,[OfferDsc]
	--	,null as campaign_bk --TODO: add correct campaign bk
	--	,HouseHoldID as customer_bk
	--FROM [Shufersal].[dbo].[Staging_coupons_yrs1516]

	RETURN 
END
