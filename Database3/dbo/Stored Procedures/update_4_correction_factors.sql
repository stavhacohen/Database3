-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-08
-- Description:	Calculates correction factors for weekdays, season and holidays
-- =============================================
CREATE PROCEDURE [dbo].[update_4_correction_factors]
    @run_nr INT = 1,
    @run_date DATE = '2017-10-08',
    @start_date DATE = '2017-07-01',
    @end_date DATE = '2017-09-30',
    @baseline_days INT = 28 --we use 28 days around a holiday period (apart from other holiday periods) to calculate the holiday baseline
AS
BEGIN

DECLARE @step INT = 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			4,
			@step,
			'Start of [update_4_correction_factors]',
			SYSDATETIME()
		)

-- Calculates correction factor per level
EXEC update_4a_weekday_correction_factors
	   @run_nr,
	   @step,
	   @run_date,
	   @start_date,
	   @end_date
SET @step = (SELECT MAX(step) FROM PG_update_log WHERE run_nr = @run_nr AND run_date = @run_date AND part = 4)
EXEC update_4b_holiday_correction_factors
	   @run_nr,
	   @step,
	   @run_date,
	   @start_date,
	   @end_date,
	   @baseline_days
SET @step = (SELECT MAX(step) FROM PG_update_log WHERE run_nr = @run_nr AND run_date = @run_date AND part = 4)
EXEC update_4c_seasonal_correction_factors
	   @run_nr,
	   @step,
	   @run_date,
	   @start_date,
	   @end_date

-- Calculates product of holiday and seasonal correction factors
IF OBJECT_ID('tempdb.dbo.#correction_total','U') IS NOT NULL
    DROP TABLE #correction_total;
SELECT	  hn.Level,
		  hn.Level_ID,
		  cs.date,
		  CAST(ch.correction_holiday AS DECIMAL(7,6)) 'correction_holiday',
		  CAST(cs.correction_season AS DECIMAL(7,6)) 'correction_season',
		  CAST(ch.correction_holiday*cs.correction_season AS DECIMAL(7,6)) AS 'correction_factor'
INTO		  #correction_total
FROM		  PG_hierarchy_names hn
INNER JOIN  PG_correction_season cs
ON		  cs.Level = hn.Level
	   AND cs.Level_ID = hn.Level_ID
	   AND cs.date BETWEEN @start_date AND @end_date
LEFT JOIN	  PG_correction_holiday ch
ON		  ch.Level = cs.Level
	   AND ch.Level_ID = cs.Level_ID
	   AND ch.date = cs.date

SET @step = (SELECT MAX(step) FROM PG_update_log WHERE run_nr = @run_nr AND run_date = @run_date AND part = 4)
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			4,
			@step,
			'Product of holiday and seasonal correction factors calculated',
			SYSDATETIME()
		)

-- Deletes rows from dbo.PG_correction_factors between start date and end date
DELETE FROM PG_correction_factors
WHERE	  TransactionDate BETWEEN @start_date AND @end_date

SET @step = (SELECT MAX(step) FROM PG_update_log WHERE run_nr = @run_nr AND run_date = @run_date AND part = 4)
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			4,
			@step,
			CONCAT('Rows deleted from dbo.PG_correction_factors between ',@start_date,' and ',@end_date),
			SYSDATETIME()
		)

-- Calculates correction factors on a product level
DECLARE @date DATE = @start_date
WHILE @date <= @end_date
BEGIN
INSERT INTO PG_correction_factors
SELECT	  pa.Product_ID,
		  @date,
		  CASE WHEN ct1.correction_factor IS NOT NULL THEN ct1.correction_holiday
			  WHEN ct2.correction_factor IS NOT NULL THEN ct2.correction_holiday
			  WHEN ct3.correction_factor IS NOT NULL THEN ct3.correction_holiday
			  WHEN ct4.correction_factor IS NOT NULL THEN ct4.correction_holiday
			  WHEN ct5.correction_factor IS NOT NULL THEN ct5.correction_holiday
			  ELSE 1 END AS 'correction_holiday',
		  CASE WHEN ct1.correction_factor IS NOT NULL THEN ct1.correction_season
			  WHEN ct2.correction_factor IS NOT NULL THEN ct2.correction_season
			  WHEN ct3.correction_factor IS NOT NULL THEN ct3.correction_season
			  WHEN ct4.correction_factor IS NOT NULL THEN ct4.correction_season
			  WHEN ct5.correction_factor IS NOT NULL THEN ct5.correction_season
			  ELSE 1 END AS 'correction_season',
		  CASE WHEN ct1.correction_factor IS NOT NULL THEN ct1.correction_factor
			  WHEN ct2.correction_factor IS NOT NULL THEN ct2.correction_factor
			  WHEN ct3.correction_factor IS NOT NULL THEN ct3.correction_factor
			  WHEN ct4.correction_factor IS NOT NULL THEN ct4.correction_factor
			  WHEN ct5.correction_factor IS NOT NULL THEN ct5.correction_factor
			  ELSE 1 END AS 'correction_factor'
FROM		  PG_product_assortment pa
LEFT JOIN	  #correction_total ct1
ON		  ct1.Level = 'Subgroup'
	   AND ct1.Level_ID = pa.Subgroup_ID
	   AND ct1.date = @date
LEFT JOIN	  #correction_total ct2
ON		  ct2.Level = 'Group'
	   AND ct2.Level_ID = pa.Group_ID
	   AND ct2.date = @date
LEFT JOIN	  #correction_total ct3
ON		  ct3.Level = 'Category'
	   AND ct3.Level_ID = pa.Category_ID
	   AND ct3.date = @date
LEFT JOIN	  #correction_total ct4
ON		  ct4.Level = 'Subdepartment'
	   AND ct4.Level_ID = pa.Subdepartment_ID
	   AND ct4.date = @date
LEFT JOIN	  #correction_total ct5
ON		  ct5.Level = 'Department'
	   AND ct5.Level_ID = pa.Department_ID
	   AND ct5.date = @date;
SET @date = DATEADD(day,1,@date)
END

SET @step = @step + 1
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			4,
			@step,
			'End of [update_4_correction_factors]',
			SYSDATETIME()
		)

END
