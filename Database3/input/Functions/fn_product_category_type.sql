-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [input].[fn_product_category_type] ()
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
	insert into @result (bk, name)
	select 'department' as bk,
		'department' as name
	UNION ALL
	select 'subdepartment' as bk,
		'subdepartment' as name
	UNION ALL
	select 'category' as bk,
		'category' as name
	UNION ALL
	select 'group' as bk,
		'group' as name
	UNION ALL
	select 'subgroup' as bk,
		'subgroup' as name
	RETURN 
END