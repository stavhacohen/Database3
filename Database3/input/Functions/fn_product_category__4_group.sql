﻿-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [input].[fn_product_category__4_group] ()
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
    select distinct
      group_id as [bk]
      ,[group_name_EN] as [name_EN]
	  ,[group_name_HE] as [name_HE]
      ,category_id as [parent_product_category_bk]
	  ,'group' as product_category_type_bk
  FROM [Shufersal].[dbo].[Staging_product_assortment]
	RETURN 
END