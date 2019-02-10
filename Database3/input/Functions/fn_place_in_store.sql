-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [input].[fn_place_in_store] ()
RETURNS 
@result TABLE 
(
	bk nvarchar(255) not null,
	display nvarchar(255) not null,
	zone int
)
AS
BEGIN
	INSERT INTO @result (bk, display, zone)
	SELECT DISTINCT
		  Promotion_ID											 as bk,
		  [Display_name_EN]										 as display,
		  Display_number										 as zone
	FROM [Shufersal].[dbo].[Staging_promotions_display]
	WHERE Promotion_ID	IS NOT NULL

	UNION 

	SELECT 0, 'No info', 0

	RETURN 
END
