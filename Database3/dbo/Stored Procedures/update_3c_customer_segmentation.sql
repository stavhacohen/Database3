-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-08-29
-- Description:	Creates customer segmentation
-- =============================================
CREATE PROCEDURE [dbo].[update_3c_customer_segmentation]
    @run_nr INT = 1,
    @run_date DATE = '2017-10-03',
    @step INT = 1,
    @start_date DATE = '2017-07-01',
    @end_date DATE = '2017-09-30',
    @nr_weeks INT = 13
AS
BEGIN
	
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,3,@step,'Start of [update_3c_customer_segmentation]',SYSDATETIME())

-- Purchase details per customer per yearweek
IF OBJECT_ID('tempdb.dbo.#customer_view_weekly','U') IS NOT NULL
    DROP TABLE #customer_view_weekly;
SELECT	  HouseholdID,
		  Yearweek,
		  COUNT(DISTINCT TransactionDate) AS 'Nr_visits',
		  SUM(Total_revenue) AS 'Revenue',
		  SUM(Total_margin) AS 'Margin'
INTO		  #customer_view_weekly
FROM		  dbo.PG_transactions_per_customer tc
INNER JOIN  dbo.PG_dim_date dt
ON		  tc.TransactionDate = dt.Date
WHERE	  dt.Date BETWEEN DATEADD(wk,-@nr_weeks,@start_date) AND @end_date
GROUP BY	  HouseholdID, Yearweek
SET @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,3,@step,'Purchase details per customer per yearweek calculated',SYSDATETIME())

-- Creates customer view over last 13 weeks
IF OBJECT_ID('tempdb.dbo.#customer_view_13weeks','U') IS NOT NULL
    DROP TABLE #customer_view_13weeks;
WITH CTE AS
(SELECT	  Yearweek,
		  MAX(date) AS 'last_day_of_week',
		  ROW_NUMBER() OVER(ORDER BY Yearweek ASC) AS 'ind'
 FROM	  dbo.PG_dim_date
 WHERE	  date BETWEEN DATEADD(wk,-@nr_weeks,@start_date) AND @end_date
 GROUP BY	  Yearweek
)
SELECT	  cte.Yearweek,
		  cvw.HouseholdID,
		  SUM(cvw.nr_visits) AS 'Nr_visits',
		  COUNT(DISTINCT cvw.Yearweek) AS 'Nr_weeks',
		  SUM(cvw.revenue) AS 'Revenue',
		  SUM(cvw.margin) AS 'Margin'
INTO		  #customer_view_13weeks
FROM		  CTE cte
INNER JOIN  CTE cte2
ON		  cte2.ind BETWEEN cte.ind-@nr_weeks+1 AND cte.ind
	   AND cte.last_day_of_week >= @start_date
INNER JOIN  #customer_view_weekly cvw
ON		  cvw.yearweek = cte2.yearweek
GROUP BY	  cte.yearweek,
		  cvw.householdID
SET @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,3,@step,'Customer view over 13 weeks calculated',SYSDATETIME())

-- Delete rows from dbo.PG_customer_view_13weeks between start date and end date
DELETE FROM dbo.PG_customer_view_13weeks
WHERE	  Yearweek BETWEEN (SELECT MIN(Yearweek) FROM #customer_view_13weeks) AND (SELECT MAX(Yearweek) FROM #customer_view_13weeks)
SET		  @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,1,@step,CONCAT('Deleted rows from dbo.PG_customer_view_13weeks between ',(SELECT MIN(Yearweek) FROM #customer_view_13weeks),' and ',(SELECT MAX(Yearweek) FROM #customer_view_13weeks)),SYSDATETIME())

-- Insert new data into customer view table
INSERT INTO dbo.PG_customer_view_13weeks
SELECT	  *
FROM		  #customer_view_13weeks
SET @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,3,@step,'End of [update_3c_customer_segmentation]',SYSDATETIME())

END
