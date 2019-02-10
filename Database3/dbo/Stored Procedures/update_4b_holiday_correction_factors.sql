-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-08
-- Description:	Calculates holiday correction factors
-- =============================================
CREATE PROCEDURE [dbo].[update_4b_holiday_correction_factors]
    @run_nr INT = 1,
    @step INT = 1,
    @run_date DATE = '2017-10-08',
    @start_date DATE = '2017-07-01',
    @end_date DATE = '2017-09-30',
    @baseline_days INT = 28
AS
BEGIN

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			4,
			@step,
			'Start of [update_4b_holiday_correction_factors]',
			SYSDATETIME()
		)

DECLARE	  @excluded_holidays  TABLE(Holiday VARCHAR(9)); --holidays that are not expecting to have a high effect
INSERT INTO @excluded_holidays  VALUES ('Tu B''Av'),('Christmas'),('Sylvester')

-- Selects holidays
IF OBJECT_ID('tempdb.dbo.#selected_holidays','U') IS NOT NULL
    DROP TABLE #selected_holidays
SELECT	  holiday,
		  year,
		  start_date,
		  end_date
INTO		  #selected_holidays
FROM		  dbo.Staging_holidays
WHERE	  holiday NOT IN (SELECT * FROM @excluded_holidays)

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			4,
			@step,
			'Holidays selected',
			SYSDATETIME()
		)

-- Calculates holiday realization period
IF OBJECT_ID('tempdb.dbo.#holiday_realization_period_ungrouped','U') IS NOT NULL
    DROP TABLE #holiday_realization_period_ungrouped
SELECT	  hd.holiday,
		  hd.year,
		  dt.date,
		  DATEDIFF(day,dt.date,hd.start_date) AS 'days_before_holiday',
		  CASE WHEN dt.date BETWEEN DATEADD(day,-@baseline_days,hd.start_date) AND DATEADD(day,-@baseline_days+6,hd.start_date) THEN 4
			  WHEN dt.date BETWEEN DATEADD(day,-@baseline_days+7,hd.start_date) AND DATEADD(day,-@baseline_days+13,hd.start_date) THEN 3
			  WHEN dt.date BETWEEN DATEADD(day,-@baseline_days+14,hd.start_date) AND DATEADD(day,-@baseline_days+20,hd.start_date) THEN 2
			  WHEN dt.date BETWEEN DATEADD(day,-@baseline_days+21,hd.start_date) AND DATEADD(day,-@baseline_days+27,hd.start_date) THEN 1
			  WHEN dt.date BETWEEN hd.start_date AND hd.end_date THEN 0
			  END AS 'weeks_before_holiday'
INTO		  #holiday_realization_period_ungrouped
FROM		  #selected_holidays hd
INNER JOIN  PG_dim_date dt
ON		  dt.date BETWEEN DATEADD(day,-@baseline_days,hd.start_date) AND hd.end_date

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			4,
			@step,
			'Holiday realization period calculated',
			SYSDATETIME()
		)

-- Set dates that are in more holiday periods to the holiday that is the closest
IF OBJECT_ID('tempdb.dbo.#holiday_realization_period','U') IS NOT NULL
    DROP TABLE #holiday_realization_period
;WITH CTE AS
(SELECT	  date,
		  MIN(days_before_holiday) AS 'days_before_holiday'
 FROM	  #holiday_realization_period_ungrouped
 GROUP BY	  date
)
SELECT	  hd.holiday,
		  hd.year,
		  cte.date,
		  cte.days_before_holiday,
		  hd.weeks_before_holiday
INTO		  #holiday_realization_period
FROM		  CTE cte
INNER JOIN  #holiday_realization_period_ungrouped hd
ON		  hd.days_before_holiday = cte.days_before_holiday
	   AND hd.date = cte.date

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			4,
			@step,
			'Dates that are in more holiday periods set to the holiday that is the closest',
			SYSDATETIME()
		)

-- Selects per day the correction factor
IF OBJECT_ID('tempdb.dbo.#holiday_correction_factors','U') IS NOT NULL
    DROP TABLE #holiday_correction_factors
;WITH CTE AS
(SELECT	  Level,
		  Level_ID
 FROM	  PG_hierarchy_names
 GROUP BY	  Level,
		  Level_ID
)
SELECT	  cte.Level,
		  cte.Level_ID,
		  dt.Date,
		  CASE WHEN hu.correction_holiday IS NULL THEN 1 ELSE hu.correction_holiday END AS 'correction_holiday'
INTO		  #holiday_correction_factors
FROM		  CTE cte
CROSS JOIN  dbo.PG_dim_date dt
LEFT JOIN	  #holiday_realization_period hr
ON		  hr.date = dt.date
LEFT JOIN	  dbo.PG_holiday_uplift_corrected hu
ON		  hu.Level = cte.Level
	   AND hu.Level_ID = cte.Level_ID
	   AND hu.holiday = hr.holiday
	   AND hu.weeks_before_holiday = hr.weeks_before_holiday
WHERE	  dt.Date BETWEEN @start_date AND @end_date

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			4,
			@step,
			'Holiday correction factor per day calculated',
			SYSDATETIME()
		)

-- Deletes rows from table between start date and end date
DELETE FROM dbo.PG_correction_holiday
WHERE	  date BETWEEN @start_date AND @end_date

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			4,
			@step,
			CONCAT('Rows deleted from dbo.PG_correction_holiday between ',@start_date,' and ',@end_date),
			SYSDATETIME()
		)

-- Writes output to table
INSERT INTO dbo.PG_correction_holiday
SELECT	  *
FROM		  #holiday_correction_factors

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			4,
			@step,
			'End of [update_4b_holiday_correction_factors]',
			SYSDATETIME()
		)

END
