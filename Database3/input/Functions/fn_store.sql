CREATE FUNCTION [input].[fn_store] ()
RETURNS 
@result TABLE 
(
	bk nvarchar(255) not null,
	name nvarchar(255) not null,
	address nvarchar(2000) not null,
	format_bk nvarchar(255) not null

)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	INSERT INTO @result (bk, name)
	SELECT #LocationID							as bk,
		  StoreName						 as name
		  FROM [Shufersal].[dbo].[Staging_stores] ss
	
	RETURN 
END