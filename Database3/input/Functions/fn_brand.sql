-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [input].[fn_brand] ()
RETURNS 
@result TABLE 
(
	bk nvarchar(255) not null,
	name_EN nvarchar(255) not null,
	name_HE nvarchar(255) not null
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	/****** Script for SelectTopNRows command from SSMS  ******/
	INSERT INTO @result (bk, name_EN, name_HE)
	SELECT Branch_name_HE as bk
       ,[Branch_name_EN] as name_EN
	   ,Branch_name_HE as name_HE
	FROM [Shufersal].[dbo].[Staging_branches]
	RETURN 
END
