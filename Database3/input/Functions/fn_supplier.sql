-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [input].[fn_supplier] ()
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
	SELECT distinct
		Supplier_ID,
		Supplier_name_HE
	FROM [dbo].[Staging_supplier_assortment]

	RETURN 
END