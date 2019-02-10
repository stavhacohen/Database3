
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [input].[fn_campaign] ()
RETURNS 
@result TABLE 
(
	bk nvarchar(255) not null,
	name nvarchar(255) not null
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	/****** Script for SelectTopNRows command from SSMS  ******/
	INSERT INTO @result (bk, name)
	SELECT distinct
		CampaignNumberPromo as bk,
		CampaignDesc as name
	FROM [Shufersal].[dbo].[Staging_promotions]

	RETURN 
END