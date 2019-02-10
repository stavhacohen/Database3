
-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-03
-- Description:	Calculates aggregated daily sales on product level
-- =============================================
CREATE PROCEDURE [dbo].[update_2_sales_per_product_per_day_wo_returns]
    @run_nr INT = 1,
    @run_date DATE = '2017-10-03',
    @start_date DATE = '2017-07-01',
    @end_date DATE = '2017-09-30'
AS
BEGIN

DECLARE @step INT = 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,2,@step,'Start of [update_2_sales_per_product_per_day_wo_returns]',SYSDATETIME())

-- Calculates sales per product per day without returns
IF OBJECT_ID('tempdb.dbo.#sales_per_product_per_day_wo_returns_update','U') IS NOT NULL
    DROP TABLE #sales_per_product_per_day_wo_returns_update;
SELECT	  tt.ProductNumber,
		  tt.TransactionDate,
		  tt.SourceInd,
		  CONVERT(VARCHAR(7),br.Branch_name_EN) AS 'Branch_name_EN',
		  		  CASE WHEN MIN(tt.HouseholdID) = 0
				THEN COUNT(DISTINCT tt.HouseholdID) - 1
			  ELSE COUNT(DISTINCT tt.HouseholdID)
		  END AS 'Number_of_customers',
		  CAST(SUM(CASE WHEN tt.Quantity > 0 THEN tt.NetSaleNoVAT ELSE 0 END) AS DECIMAL(10,2)) AS 'Revenue',
		  CAST(SUM(CASE WHEN tt.Quantity > 0 THEN tt.Quantity ELSE 0 END) AS DECIMAL(10,2)) AS 'Quantity',
		  CAST(SUM(CASE WHEN tt.Quantity > 0 THEN tt.Range_AMtttt ELSE 0 END) AS DECIMAL(10,2)) AS 'Margin'
INTO		  #sales_per_product_per_day_wo_returns_update
FROM		  dbo.Staging_transactions_total_update tt
INNER JOIN  dbo.Staging_branches br
ON		  tt.StoreFormatCode = br.Branch_ID
	   AND br.Branch_name_EN IN ('Sheli','Organic','Deal','Online','Extra','Express','Yesh')
WHERE	  tt.TransactionDate BETWEEN @start_date AND @end_date
GROUP BY	  tt.ProductNumber,
		  tt.TransactionDate,
		  tt.SourceInd,
		  br.Branch_name_EN
SET		  @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,2,@step,'Sales per product per day without returns calculated',SYSDATETIME())

-- Delete rows from dbo.PG_sales_per_product_per_day_wo_returns between start date and end date
DELETE FROM dbo.PG_sales_per_product_per_day_wo_returns
WHERE	  TransactionDate BETWEEN @start_date AND @end_date
SET		  @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,2,@step,CONCAT('Deleted rows from dbo.PG_sales_per_product_per_day_wo_returns between ',@start_date,' and ',@end_date),SYSDATETIME())

-- Inserts data into table
INSERT INTO dbo.PG_sales_per_product_per_day_wo_returns
SELECT	  *
FROM		  #sales_per_product_per_day_wo_returns_update

SET @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,2,@step,'End of [update_2_sales_per_product_per_day_wo_returns]',SYSDATETIME())


drop table #sales_per_product_per_day_wo_returns_update


END

