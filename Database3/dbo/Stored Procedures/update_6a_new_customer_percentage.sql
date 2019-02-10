-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-04
-- Description:	Calculates percentage of new customer per format
-- =============================================
CREATE PROCEDURE [dbo].[update_6a_new_customer_percentage]
    @run_nr INT = 1,
    @run_date DATE = '2017-10-04',
    @start_date DATE = '2017-07-01',
    @end_date DATE = '2017-09-30'
AS
BEGIN

DECLARE @step INT = 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			6,
			@step,
			'Start of [update_6_new_customer_percentage]',
			SYSDATETIME()
		)

-- Creates table for new customers per format per day
IF OBJECT_ID('tempdb.dbo.#new_customers','U') IS NOT NULL
    DROP TABLE #new_customers
CREATE TABLE #new_customers
(   TransactionDate		   DATE,
    Branch_name_EN		   VARCHAR(7),
    N_distinct_customers	   INT,
    N_new_customers		   INT
)

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			6,
			@step,
			'Table created for new customers per format per day',
			SYSDATETIME()
		)

-- Fills table with the transactions of promotions
DECLARE @date DATE = @start_date
WHILE @date <= @end_date
BEGIN
    INSERT INTO #new_customers
    SELECT	 tt.TransactionDate,
			 br.Branch_name_EN,
			 COUNT(DISTINCT tt.HouseholdID),
			 COUNT(DISTINCT(CASE WHEN ci.new_customer_ind = 1 THEN ci.HouseholdID ELSE NULL END))
    FROM		 Staging_transactions_total_update tt
    INNER JOIN	 PG_customer_information_table_update ci
    ON		 tt.HouseholdID = ci.HouseholdID
		  AND tt.TransactionDate = ci.TransactionDate
    INNER JOIN	 Staging_branches br
    ON		 tt.StoreFormatCode = br.Branch_ID
    WHERE		 tt.TransactionDate = @date
    GROUP BY	 tt.TransactionDate,
			 br.Branch_name_EN

    SET @step = @step + 1;
    INSERT INTO PG_update_log
	   VALUES( @run_nr,
			 @run_date,
			 6,
			 @step,
			 CONCAT('New customers per format calculated for ',@date),
			 SYSDATETIME()
		    )
    SET @date = DATEADD(day,1,@date);
END

-- Deletes rows from PG_new_customers_percentage between start and end date
DELETE FROM PG_new_customers_percentage
WHERE		TransactionDate BETWEEN @start_date AND @end_date

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			6,
			@step,
			CONCAT('Rows deleted from PG_new_customers_percentage between ',@start_date,' and ',@end_date),
			SYSDATETIME()
		)

-- Percentage of new customers per format per day calculated
INSERT INTO	PG_new_customers_percentage
SELECT	  TransactionDate,
		  Branch_name_EN,
		  N_distinct_customers,
		  N_new_customers,
		  CAST(1.0*N_new_customers/N_distinct_customers AS DECIMAL(7,6)) AS 'pct_new'
FROM		  #new_customers

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			6,
			@step,
			'End of [update_6_new_customer_percentage]',
			SYSDATETIME()
		)

END
