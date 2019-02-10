
-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-03
-- Description:	Creates tables with information about customers
-- =============================================
CREATE PROCEDURE [dbo].[update_3_customer_information]
    @run_nr INT = 1,
    @run_date DATE = '2017-10-03',
    @start_date DATE = '2017-07-01',
    @end_date DATE = '2017-09-30',
    @customer_days int = 42, -- A customer is considered a promotion customer according to his sales in the previous 6 weeks
    @new_customer_days int = 91, -- A customer is considered a new customer after 13 weeks without a visit
    @promo_perc float = 0.6, -- Percentage when a customer is considered a promotion customer
    @customer_batch INT = 50000, -- Batches for creating of customers tables
    @nr_weeks INT = 13 -- Number of weeks for customer segmentation
AS
BEGIN

DECLARE @step INT = 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,3,@step,'Start of [update_3_customer_information]',SYSDATETIME())

 --Selects all customers that have not been in a previous period
IF OBJECT_ID('tempdb.dbo.#customers', 'U') IS NOT NULL
    DROP TABLE #customers;
SELECT	  HouseholdID
INTO		  #customers
FROM		  dbo.Staging_transactions_total_update
WHERE	  HouseholdID <> 0
	   AND TransactionDate BETWEEN @start_date AND @end_date
GROUP BY	  HouseholdID
UNION
SELECT	  HouseholdID
FROM		  PG_customers
GROUP BY	  HouseholdID

-- Selects all customers with a transaction in the entire period
IF OBJECT_ID('dbo.PG_customers', 'U') IS NOT NULL
    DROP TABLE dbo.PG_customers;
SELECT	  HouseholdID,
		  ROW_NUMBER() OVER(ORDER BY HouseholdID) AS 'Ind'
INTO		  dbo.PG_customers
FROM		  #customers
SET		  @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,3,@step,'Table created with all customers',SYSDATETIME())

-- Calculates total number of customers
IF OBJECT_ID('tempdb.dbo.#max_ind', 'U') IS NOT NULL
    DROP TABLE #max_ind;
SELECT	  MAX(Ind) AS 'max_ind'
INTO		  #max_ind
FROM		  dbo.PG_customers
SET		  @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,3,@step,'Total number of customers calculated',SYSDATETIME())

-- Delete rows from dbo.PG_transactions_per_customer between start date and end date
DELETE FROM dbo.PG_transactions_per_customer
WHERE	  TransactionDate BETWEEN @start_date AND @end_date
SET		  @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,3,@step,CONCAT('Deleted rows from dbo.PG_transactions_per_customer between ',@start_date,' and ',@end_date),SYSDATETIME())

-- Selects highest visit number per customer
IF OBJECT_ID('dbo.PG_transactions_per_customer_max_visit', 'U') IS NOT NULL
    DROP TABLE PG_transactions_per_customer_max_visit;
SELECT	  HouseholdID,
		  MAX(Visit_index) AS 'Max_visit_index'
INTO		  dbo.PG_transactions_per_customer_max_visit
FROM		  PG_transactions_per_customer
WHERE	  TransactionDate < @start_date
GROUP BY	  HouseholdID
SET		  @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,3,@step,'Highest visit number per customer selected',SYSDATETIME())

-- Creates table with aggregated transactions per customer
IF OBJECT_ID('dbo.PG_transactions_per_customer_update','U') IS NOT NULL
    DROP TABLE dbo.PG_transactions_per_customer_update;
CREATE TABLE dbo.PG_transactions_per_customer_update(
	[HouseholdID] [bigint] NOT NULL,
	[TransactionDate] [date] NOT NULL,
	[Total_revenue] DECIMAL(10,2) NOT NULL,
	[Promo_revenue] DECIMAL(10,2) NOT NULL,
	[Total_quantity] DECIMAL(10,2) NOT NULL,
	[Promo_quantity] DECIMAL(10,2) NOT NULL,
	[Total_margin] DECIMAL(10,2) NOT NULL,
	[Promo_margin] DECIMAL(10,2) NOT NULL,
	[Visit_index] [bigint] NOT NULL
)
SET		  @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,3,@step,'Table created with aggregated transactions per customer for update',SYSDATETIME())

-- Fill table with aggregated transactions per customer
DECLARE @countX INT = 1;
DECLARE @countY INT = @customer_batch;
WHILE @countX <= (SELECT max_ind FROM #max_ind)
BEGIN
    EXEC dbo.update_3a_transactions_per_customer
		  @start_date,
		  @end_date,
		  @countX,
		  @countY
    SET @step = @step + 1;
    INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,3,@step,CONCAT('Aggregated transactions per customer calculated for ',@countY,' customers'),SYSDATETIME())
    SET @countX = @countX + @customer_batch;
    SET @countY = @countY + @customer_batch;
END

-- Creates indexes on table with transactions per customer
CREATE CLUSTERED INDEX cl_index_householdID ON dbo.PG_transactions_per_customer_update(HouseholdID)
SET @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,3,@step,'Clustered index on householdID created',SYSDATETIME())
CREATE INDEX index_date ON dbo.PG_transactions_per_customer_update(TransactionDate)
SET @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,3,@step,'Nonclustered index on transaction date created',SYSDATETIME())

-- Select updated data for dbo.PG_transactions_per_customer into history
INSERT INTO dbo.PG_transactions_per_customer
SELECT	  *
FROM		  dbo.PG_transactions_per_customer_update
SET		  @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,3,@step,CONCAT('Inserted rows into dbo.PG_transactions_per_customer between ',@start_date,' and ',@end_date),SYSDATETIME())

-- Delete rows from dbo.PG_customer_information_table between start date and end date
DELETE FROM dbo.PG_customer_information_table
WHERE	  TransactionDate BETWEEN @start_date AND @end_date
SET		  @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,3,@step,CONCAT('Deleted rows from dbo.PG_customer_information_table between ',@start_date,' and ',@end_date),SYSDATETIME())

-- Creates table with information about customers looking back 6 weeks
IF OBJECT_ID('dbo.PG_customer_information_table_update','U') IS NOT NULL
    DROP TABLE dbo.PG_customer_information_table_update;
CREATE TABLE dbo.PG_customer_information_table_update(
	[HouseholdID] [bigint] NOT NULL,
	[TransactionDate] [date] NOT NULL,
	[Visit_index] [bigint] NOT NULL,
	[PreviousTransactionDate] [date] NULL,
	[new_promo_customer_ind] [int] NOT NULL,
	[new_customer_ind] [int] NOT NULL,
	[Promo_revenue_at_date] DECIMAL(10,2) NOT NULL,
	[Non_promo_revenue_at_date] DECIMAL(10,2) NOT NULL,
	[Promo_margin_at_date] DECIMAL(10,2) NOT NULL,
	[Non_promo_margin_at_date] DECIMAL(10,2) NOT NULL,
	[Promo_quantity_at_date] DECIMAL(10,2) NOT NULL,
	[Non_promo_quantity_at_date] DECIMAL(10,2) NOT NULL,
	[Perc_promo] DECIMAL(3,2) NOT NULL,
	[promo_ind] [int] NOT NULL
)
SET		  @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,3,@step,'Table created with information about customers looking back 6 weeks',SYSDATETIME())

-- Fill table with information about customers looking back 6 weeks
SET @countX = 1;
SET @countY = @customer_batch;
WHILE @countX <= (SELECT max_ind FROM #max_ind)
BEGIN
    EXEC dbo.update_3b_customer_information_table
	   @start_date,
	   @end_date,
	   @countX,
	   @countY,
	   @customer_days,
	   @new_customer_days,
	   @promo_perc
    SET @step = @step + 1;
    INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,3,@step,CONCAT('Information about customers looking back 6 weeks calculated for ',@countY,' customers'),SYSDATETIME())
    SET @countX = @countX + @customer_batch;
    SET @countY = @countY + @customer_batch;
END

-- Select updated data for dbo.PG_customer_information_table into history
INSERT INTO dbo.PG_customer_information_table
SELECT	  *
FROM		  dbo.PG_customer_information_table_update
SET		  @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,3,@step,CONCAT('Inserted rows into dbo.PG_customer_information_table between ',@start_date,' and ',@end_date),SYSDATETIME())

-- Creates customer segmentation
EXEC dbo.update_3c_customer_segmentation
	   @run_nr,
	   @run_date,
	   @step,
	   @start_date,
	   @end_date,
	   @nr_weeks

SET @step = @step + 4;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,3,@step,'End of [update_3_customer_information]',SYSDATETIME())

END

