-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-08
-- Description:	Calculation of weekday correction factors
-- =============================================
CREATE PROCEDURE [dbo].[update_4a_weekday_correction_factors]
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
			'Start of [update_4a_weekday_correction_factors]',
			SYSDATETIME()
		)

-- Selects seasonality measure
IF OBJECT_ID('tempdb.dbo.#seasonality_measure','U') IS NOT NULL
    DROP TABLE #seasonality_measure;
SELECT		week,
			correction_shabbat AS 'season'
INTO		#seasonality_measure
FROM		dbo.Staging_shabbat_times

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			4,
			@step,
			'Seasonality measure of weekdays selected',
			SYSDATETIME()
		)

-- Calculates daily quantity per branch
IF OBJECT_ID('tempdb.dbo.#daily_quantity_per_branch','U') IS NOT NULL
    DROP TABLE #daily_quantity_per_branch;
SELECT		dt.date,
			dt.yearweek,
			DATEPART(dw,dt.Date) as 'weekday',
			br.Branch_name_EN,
			ISNULL(SUM(spp.Quantity),0) AS 'quantity',
			AVG(ISNULL(SUM(spp.Quantity),0)) OVER(PARTITION BY br.Branch_name_EN, DATEPART(dw,dt.Date)) AS 'avg_weekday_quantity'
INTO		#daily_quantity_per_branch
FROM		dbo.PG_dim_date dt
CROSS JOIN	(SELECT Branch_name_EN FROM dbo.PG_branches_sources GROUP BY Branch_name_EN) br
LEFT JOIN	dbo.PG_sales_per_product_per_day_wo_returns spp
ON			spp.Branch_name_EN = br.Branch_name_EN
		AND spp.TransactionDate = dt.date
WHERE		dt.Date BETWEEN @start_date AND @end_date
GROUP BY	dt.date,
			dt.yearweek,
			DATEPART(dw,dt.Date),
			br.Branch_name_EN

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			4,
			@step,
			'Daily sold quantity per branch calculated',
			SYSDATETIME()
		)

-- Checks anomalies of certain weekdays due to holidays, closings etc.
IF OBJECT_ID('tempdb.dbo.#special_days','U') IS NOT NULL
    DROP TABLE #special_days;
SELECT		*, quantity/avg_weekday_quantity AS 'deviation'
INTO		#special_days
FROM		#daily_quantity_per_branch
WHERE		quantity < 0.25*avg_weekday_quantity
		 OR quantity > 4*avg_weekday_quantity

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			4,
			@step,
			'Check anomalies of certain weekdays due to holidays or closings',
			SYSDATETIME()
		)

-- Corrects quantities for the seasonality of weekdays
IF OBJECT_ID('tempdb.dbo.#corrected_weekday_quantities','U') IS NOT NULL
    DROP TABLE #corrected_weekday_quantities;
WITH CTE AS
(SELECT		branch_name_EN, weekday
 FROM		PG_seasonality_per_weekday
 WHERE		relative_correlation_weekday < -0.15
		 OR relative_correlation_weekday > 0.15
)
SELECT		dq.date,
			dq.weekday,
			dq.yearweek,
			dq.Branch_name_EN,
			dq.quantity,
			CASE WHEN sd.deviation < 0.01 THEN 0
				 WHEN (sd.date IS NOT NULL OR cte.weekday IS NOT NULL) AND dq.quantity <> 0 THEN dq.avg_weekday_quantity / dq.quantity
			     ELSE 1 END AS 'correction_factor',
			CASE WHEN sd.deviation < 0.01 THEN 0
				 WHEN (sd.date IS NOT NULL OR cte.weekday IS NOT NULL) AND dq.quantity <> 0 THEN dq.avg_weekday_quantity / dq.quantity
			     ELSE 1 END * dq.quantity AS 'corrected_quantity'
INTO		#corrected_weekday_quantities
FROM		#daily_quantity_per_branch dq
LEFT JOIN	CTE cte
ON			cte.Branch_name_EN = dq.Branch_name_EN
		AND cte.weekday = dq.weekday
LEFT JOIN	#special_days sd
ON			sd.Branch_name_EN = dq.Branch_name_EN
		AND sd.date = dq.date

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			4,
			@step,
			'Sold quantites corrected for seasonality of weekdays',
			SYSDATETIME()
		)

-- Calculates total weekday correction factors
IF OBJECT_ID('tempdb.dbo.#weekday_correction_factors','U') IS NOT NULL
    DROP TABLE #weekday_correction_factors;
SELECT		cwq.date,
			cwq.weekday,
			cwq.Branch_name_EN,
			CAST(cwq.correction_factor*ns.correction_weekday_non_seasonal AS DECIMAL(10,4)) AS 'correction_weekday'
INTO		#weekday_correction_factors
FROM		#corrected_weekday_quantities cwq
INNER JOIN	dbo.PG_non_seasonal_weekday_correction_factors ns
ON			ns.Branch_name_EN = cwq.Branch_name_EN
		AND ns.weekday = DATEPART(dw,cwq.date)

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			4,
			@step,
			'Weekday correction factors calculated with seasonality',
			SYSDATETIME()
		)

-- Deletes rows from dbo.PG_correction_weekday between start date and end date
DELETE FROM dbo.PG_correction_weekday
WHERE	  Date BETWEEN @start_date AND @end_date

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			4,
			@step,
			CONCAT('Rows deleted from dbo.PG_correction_weekday between ',@start_date,' and ',@end_date),
			SYSDATETIME()
		)

-- Calculates total weekday correction factors
INSERT INTO dbo.PG_correction_weekday
SELECT		*
FROM		#weekday_correction_factors

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			4,
			@step,
			'End of [update_4a_weekday_correction_factors]',
			SYSDATETIME()
		)

END
