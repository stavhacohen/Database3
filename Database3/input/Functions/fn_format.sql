CREATE FUNCTION [input].[fn_format] ()
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
	SELECT DISTINCT
		Format_name_EN	as bk,
		Format_name_EN	as name_EN,
		Format_name_HE	as name_HE
	FROM [Shufersal].[dbo].[Staging_stores_branches] 
		


	RETURN 
END