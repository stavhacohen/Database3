CREATE FUNCTION [input].[fn_promotion__transaction] ()
RETURNS 
@result TABLE 
(
	promotion_bk nvarchar(255) not null,
	transaction_bk nvarchar(255) not null
)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	/****** Script for SelectTopNRows command from SSMS  ******/
	INSERT INTO @result (promotion_bk, transaction_bk)
	SELECT DISTINCT
			pro.PromotionNumber as promotion_bk,
			tra.#BasketID		as transaction_bk
	FROM [Shufersal].[dbo].[Staging_promotions] pro 
		INNER JOIN [Shufersal].[dbo].[Staging_transactions_total] tra ON
			tra.ProductNumber = pro.ProductNumber
			AND tra.TransactionDate BETWEEN pro.PromotionStartDate AND pro.PromotionEndDate
			AND pro.SourceInd = tra.SourceInd
	
	RETURN 
END