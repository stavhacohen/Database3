-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-08
-- Description:	Calculates seasonal correction factors
-- =============================================
CREATE PROCEDURE [dbo].[update_4c_seasonal_correction_factors]
	@run_nr INT = 1,
	@step INT = 1,
    @run_date DATE = '2017-10-08',
    @start_date DATE = '2017-07-01',
    @end_date DATE = '2017-09-30'
AS
BEGIN

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			4,
			@step,
			'Start of [update_4c_seasonal_correction_factors]',
			SYSDATETIME()
		)

-- Calculates seasonal correction factors
IF OBJECT_ID('tempdb.dbo.#season_correction_factors','U') IS NOT NULL
    DROP TABLE #season_correction_factors
;WITH CTE AS
(SELECT	  Level,
		  Level_ID,
		  date
 FROM	  PG_hierarchy_names
 CROSS JOIN dbo.PG_dim_date
 WHERE	  date BETWEEN @start_date AND @end_date
 GROUP BY	  Level,
		  Level_ID,
		  date
)
SELECT	  cte.Level,
		  cte.Level_ID,
		  cte.date,
		  scf.correction_season
INTO		  #season_correction_factors
FROM		  CTE cte
LEFT JOIN   PG_season_correction_factors_year scf
ON		  MONTH(scf.date) = MONTH(cte.date)
	   AND DAY(scf.date) = DAY(cte.date)
	   AND scf.Level = cte.Level
	   AND scf.Level_ID = cte.Level_ID

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			4,
			@step,
			'Seasonal correction factors for entire period calculated',
			SYSDATETIME()
		)

-- Deletes rows from dbo.PG_correction_season between start date and end date
DELETE FROM dbo.PG_correction_season
WHERE	  date BETWEEN @start_date AND @end_date

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			4,
			@step,
			CONCAT('Rows deleted from dbo.PG_correction_season between ',@start_date,' and ',@end_date),
			SYSDATETIME()
		)

-- Writes output to table
INSERT INTO dbo.PG_correction_season
SELECT	  *
FROM		  #season_correction_factors

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			4,
			@step,
			'End of [update_4c_seasonal_correction_factors]',
			SYSDATETIME()
		)

END

