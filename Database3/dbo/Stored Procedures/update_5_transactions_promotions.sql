
-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-03
-- Description:	Creates table with aggregated promotion sales per customer per day
-- =============================================
CREATE PROCEDURE [dbo].[update_5_transactions_promotions]
    @run_nr INT = 1,
    @run_date DATE = '2017-10-03',
    @start_date DATE = '2017-07-01',
    @end_date DATE = '2017-09-30'
AS
BEGIN

DECLARE @step INT = 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,5,@step,'Start of [update_5_transactions_promotions]',SYSDATETIME())

-- Drops and creates table with transactions of promotions
IF OBJECT_ID('dbo.PG_transactions_promotions_update','U') IS NOT NULL
    DROP TABLE dbo.PG_transactions_promotions_update;
CREATE TABLE dbo.PG_transactions_promotions_update
(ProductNumber		BIGINT,
 HouseholdID		BIGINT,
 TransactionDate	DATE,
 Branch_name_EN	VARCHAR(7),
 SourceInd		SMALLINT,
 Quantity			DECIMAL(15,2),
 Revenue			DECIMAL(15,2),
 Margin			DECIMAL(15,2)
);
SET		  @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,5,@step,'Table created with transactions of promotions',SYSDATETIME())

-- Fills table with the transactions of promotions
DECLARE @date DATE = @start_date
WHILE @date <= @end_date
BEGIN
    INSERT INTO PG_transactions_promotions_update
    SELECT	 tt.ProductNumber,
    			 tt.HouseholdID,
			 tt.TransactionDate,
			 br.Branch_name_EN,
			 tt.SourceInd,
			 CAST(SUM(tt.Quantity) AS DECIMAL(15,2)),
			 CAST(SUM(tt.NetSaleNoVAT) AS DECIMAL(15,2)),
			 CAST(SUM(tt.Range_Amtttt) AS DECIMAL(15,2))
    FROM		 Staging_transactions_total_update tt
    INNER JOIN  Staging_branches br
    ON		 tt.StoreFormatCode = br.Branch_ID
		  AND br.Branch_name_EN NOT IN ('Other')
    INNER JOIN  PG_promo_product_ind_update ppi
    ON		 ppi.TransactionDate = tt.TransactionDate
		  AND ppi.Branch_name_EN = br.Branch_name_EN
		  AND ppi.ProductNumber = tt.ProductNumber
		  AND ppi.SourceInd = tt.SourceInd
		  AND ppi.Promo_ind = 1
		  AND ppi.TransactionDate = @date
    WHERE		 tt.HouseholdID <> 0
		  AND tt.Quantity > 0
		  AND tt.TransactionDate BETWEEN @start_date AND @end_date
    GROUP BY	 tt.ProductNumber,
			 tt.HouseholdID,
			 tt.TransactionDate,
			 br.Branch_name_EN,
			 tt.SourceInd;

    SET @step = @step + 1;
    INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,5,@step,CONCAT('Promotion transactions of ',@date,' selected'),SYSDATETIME())
    SET @date = DATEADD(day,1,@date);
END

-- Delete rows from dbo.PG_transactions_promotions between start date and end date
DELETE FROM dbo.PG_transactions_promotions
WHERE	  TransactionDate BETWEEN @start_date AND @end_date
SET		  @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,5,@step,CONCAT('Deleted rows from dbo.PG_transactions_promotions between ',@start_date,' and ',@end_date),SYSDATETIME())

-- Insert rows into dbo.PG_transactions_promotions between start date and end date
INSERT INTO dbo.PG_transactions_promotions
SELECT	  *
FROM		  dbo.PG_transactions_promotions_update
SET		  @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,5,@step,CONCAT('Rows inserted into dbo.PG_transactions_promotions between ',@start_date,' and ',@end_date),SYSDATETIME())


SET @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,5,@step,'End of [update_5_transactions_promotions]',SYSDATETIME())

END

