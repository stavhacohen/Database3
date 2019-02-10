-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [input].[fn_product_category] ()
RETURNS 
@result TABLE 
(
	bk nvarchar(255) not null,
	name_EN nvarchar(255) not null,
	name_HE nvarchar(255) not null,
	[parent_product_category_bk] nvarchar(255) not null,
	product_category_type_bk nvarchar(255) not null
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	/****** Script for SelectTopNRows command from SSMS  ******/
	insert into @result (bk, [name_EN], [name_HE], [parent_product_category_bk], product_category_type_bk)
	SELECT *
	FROM [input].[fn_product_category__1_department]()

	UNION 

	SELECT *
	FROM [input].[fn_product_category__2_subdepartment]()

	UNION 

	SELECT *
	FROM [input].[fn_product_category__3_category]()

	UNION 

	SELECT *
	FROM [input].[fn_product_category__4_group]()


	UNION 

	SELECT *
	FROM [input].[fn_product_category__5_subgroup]()

	RETURN 
END