-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [input].[fn_customer] ()
RETURNS 
@result TABLE 
(
	bk nvarchar(255) not null
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	/****** Script for SelectTopNRows command from SSMS  ******/
	insert into @result (bk)
	SELECT distinct HouseholdID as bk
	FROM [Shufersal].[dbo].[Staging_transactions_total]

	RETURN 
END