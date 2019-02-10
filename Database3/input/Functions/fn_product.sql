-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [input].[fn_product] ()
RETURNS 
@result TABLE 
(
	bk nvarchar(255) not null,
	name nvarchar(255) not null,
	[description] nvarchar(2000) null,
	[weight] decimal(19,8) null,
	[volume] decimal(19,8) null,
	[product_category_bk] nvarchar(255) not null
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	/****** Script for SelectTopNRows command from SSMS  ******/
	insert into @result (bk, [name], [product_category_bk])
	SELECT 
      [Product_ID] as bk
      ,[Product_name_HE] as name
	  ,[Subgroup_ID] as product_category_bk
	FROM [Shufersal].[dbo].[Staging_product_assortment]

	RETURN 
END