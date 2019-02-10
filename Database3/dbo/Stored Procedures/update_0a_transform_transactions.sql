-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-03
-- Description:	Transforms transaction file into readable input
-- =============================================
CREATE PROCEDURE [dbo].[update_0a_transform_transactions]
    @run_nr INT = 1,
    @step INT = 154,
    @run_date DATE = '2018-12-27',
    @source_data VARCHAR(100) = 'dbo.Staging_transactions_import'
AS
BEGIN

SET @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,0,@step,'Start of [update_0a_transform_transactions]',SYSDATETIME())

DECLARE @query VARCHAR(800);
SET @query =
'INSERT INTO dbo.Staging_transactions_total_update
SELECT  #BasketID,
	   HouseholdID,
	   SourceInd,
	   StoreFormatCode,
	   LocationID,
	   CONVERT(DATE,CONCAT(SUBSTRING(TransactionDate,7,4),SUBSTRING(TransactionDate,1,2),SUBSTRING(TransactionDate,4,2)),120) TransactionDate,
	   ProductNumber,
	   TRY_CONVERT(FLOAT,NetSaleNoVAT) NetSaleNoVAT,
	   TRY_CONVERT(FLOAT,Quantity) Quantity,
	   TRY_CONVERT(INT,ItemQuantity) ItemQuantity,
	   TRY_CONVERT(FLOAT,Price_Kg) Price_kg,
	   TRY_CONVERT(FLOAT,Range_Amtttt) Range_Amtttt
FROM ';

SET @query = CONCAT(@query,@source_data)
EXEC(@query)

SET @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,0,@step,'Data inserted into dbo.Staging_transactions_total_update',SYSDATETIME())

SET @query = CONCAT('TRUNCATE TABLE ',@source_data)
EXEC(@query)

SET @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,0,@step,'Source table of transactions dropped',SYSDATETIME())

SET @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,0,@step,'End of [update_0a_transform_transactions]',SYSDATETIME())

END
