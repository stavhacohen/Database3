CREATE FUNCTION [input].[fn_transaction] ()
RETURNS 
@result TABLE 
(
	bk nvarchar(255) not null,
	time datetime,
	store_bk nvarchar(255),
	calendar_bk nvarchar(255),
	customer_bk nvarchar(255)

)
AS
BEGIN
	-- Fill the table variable with the rows for your result set
	INSERT INTO @result (bk, time, store_bk, calendar_bk, customer_bk)
	SELECT 
		  #BasketID							 as bk,
		  TransactionDate						 as time,
		  LocationID		  					 as store_bk,
		  CONVERT(varchar(10), TransactionDate, 112)	 as calendar_bk,
		  HouseholdID							 as customer_bk		  
	FROM [Shufersal].[dbo].[Staging_transactions_total]
	GROUP BY #BasketID, TransactionDate, LocationID, HouseholdID
	RETURN 
END