-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [input].[fn_transaction_detail] ()
RETURNS 
@result TABLE 
(
	bk nvarchar(255) not null,
	number_of_sold_items decimal(19,8) not null,
	revenue decimal(19,8) not null,
	margin decimal(19,8) not null,
	product_bk bigint not null,
	transaction_bk bigint not null
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	INSERT INTO @result (bk, number_of_sold_items, revenue, margin, product_bk, transaction_bk)
	SELECT 
		  CONCAT (CONVERT(nvarchar(125), #basketid),'|', CONVERT(nvarchar(125), ProductNumber))	  as bk,
		  Quantity							  as number_of_sold_items,
		  NetSaleNoVAT						  as revenue,
		  Range_Amtttt						  as margin,
		  ProductNumber						  as product_bk,
		  #BasketID							  as transaction_bk
	FROM [Shufersal].[dbo].[Staging_transactions_total]
		WHERE NetSaleNoVAT IS NOT NULL
		AND Quantity IS NOT NULL

	RETURN 
END
