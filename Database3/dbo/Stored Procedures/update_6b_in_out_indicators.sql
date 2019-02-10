-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-31
-- Description:	Updates table with in-out indicators
-- =============================================
CREATE PROCEDURE [dbo].[update_6b_in_out_indicators]
    @run_nr INT = 1,
    @run_date DATE = '2017-10-31',
    @start_date DATE = '2017-07-01',
    @end_date DATE = '2017-09-30',
    @step INT = 1,
    @start_date_hist DATE = '2015-01-01',
    @min_perc FLOAT = 0.05,
    @min_amount INT = 10
AS
BEGIN

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			6,
			@step,
			'Start of [update_6b_in_out_indicators]',
			SYSDATETIME()
		)

-- Selects quantities per product per week
IF OBJECT_ID('dbo.PG_product_week_quantities_update','U') IS NOT NULL
    DROP TABLE PG_product_week_quantities_update
SELECT	  pn.ProductNumber,
		  pn.Branch_name_EN,
		  dt.yearweek,
		  COUNT(DISTINCT dt2.date) AS 'number_days',
		  CAST(SUM(ISNULL(spp.Quantity,0)) AS DECIMAL(15,2)) AS 'week_quantity'
INTO		  dbo.PG_product_week_quantities_update
FROM		  (SELECT ProductNumber, Branch_name_EN FROM PG_sales_per_product_per_day_wo_returns GROUP BY ProductNumber, Branch_name_EN) pn
CROSS JOIN  (SELECT Yearweek FROM PG_dim_date WHERE Date BETWEEN @start_date AND @end_date GROUP BY Yearweek) dt
INNER JOIN  PG_dim_date dt2
ON		  dt2.yearweek = dt.yearweek
LEFT JOIN	  PG_sales_per_product_per_day_wo_returns spp
ON		  spp.ProductNumber = pn.ProductNumber
	   AND spp.Branch_name_EN = pn.Branch_name_EN
	   AND spp.TransactionDate = dt2.date
GROUP BY	  pn.ProductNumber,
		  pn.Branch_name_EN,
		  dt.yearweek

DELETE FROM PG_product_week_quantities
WHERE	  yearweek IN (SELECT yearweek FROM PG_product_week_quantities_update GROUP BY yearweek)
INSERT INTO PG_product_week_quantities
SELECT	  *
FROM		  PG_product_week_quantities_update

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			6,
			@step,
			'Quantities selected per product per week',
			SYSDATETIME()
		)

-- Calculates maximum sales of a product between start and end date
IF OBJECT_ID('dbo.PG_product_max_week_quantity_update','U') IS NOT NULL
    DROP TABLE PG_product_max_week_quantity_update
SELECT	  ProductNumber,
		  Branch_name_EN,
		  MAX(week_quantity) AS 'max_week_quantity'
INTO		  dbo.PG_product_max_week_quantity_update
FROM		  PG_product_week_quantities_update
GROUP BY	  ProductNumber,
		  Branch_name_EN

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			6,
			@step,
			'Maximum sales of a product between start and end date calculated',
			SYSDATETIME()
		)

-- Calculates maximum sales of a product over entire historic period
IF OBJECT_ID('tempdb.dbo.#product_max_week_quantity','U') IS NOT NULL
    DROP TABLE #product_max_week_quantity
SELECT	  ISNULL(q.ProductNumber,qu.ProductNumber) AS 'ProductNumber',
		  ISNULL(q.Branch_name_EN,qu.Branch_name_EN) AS 'Branch_name_EN',
		  CAST(CASE WHEN ISNULL(q.max_week_quantity,0) > ISNULL(qu.max_week_quantity,0) THEN
				q.max_week_quantity
			  ELSE qu.max_week_quantity END AS DECIMAL(15,2)) AS 'max_week_quantity'
INTO		  #product_max_week_quantity
FROM		  PG_product_max_week_quantity q
FULL JOIN	  PG_product_max_week_quantity_update qu
ON		  q.ProductNumber = qu.ProductNumber
	   AND q.Branch_name_EN = qu.Branch_name_EN

TRUNCATE TABLE PG_product_max_week_quantity
INSERT INTO PG_product_max_week_quantity
SELECT	  *
FROM		  #product_max_week_quantity

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			6,
			@step,
			'Maximum sales of a product over entire historic period calculated',
			SYSDATETIME()
		)

-- Calculates percentage in quantity of maximum week
IF OBJECT_ID('dbo.PG_product_perc_max_week_quantity_update','U') IS NOT NULL
    DROP TABLE dbo.PG_product_perc_max_week_quantity_update
;WITH CTE AS
(SELECT	  yearweek,
		  MAX(date) AS 'LDOW',
		  ROW_NUMBER() OVER(ORDER BY yearweek) AS 'yearweek_id'
 FROM	  PG_dim_date
 WHERE	  date BETWEEN @start_date_hist AND @end_date
 GROUP BY	  yearweek
),
CTE2 AS
(SELECT	  yearweek,
		  yearweek_id
 FROM	  CTE
 WHERE	  LDOW >= @start_date
)
SELECT	  cte.yearweek_id,
		  pwq.*,
		  paq.max_week_quantity,
		  CAST(CASE WHEN paq.max_week_quantity = 0 THEN 0
			  ELSE pwq.week_quantity/paq.max_week_quantity*7/number_days
		  END AS DECIMAL(5,4)) AS 'perc_max_week_quantity',
		  CASE WHEN paq.max_week_quantity <> 0 AND pwq.week_quantity/paq.max_week_quantity*7/number_days < @min_perc THEN 0
			  WHEN paq.max_week_quantity <= @min_amount THEN 0
			  ELSE 1 
		  END AS 'Ind_in_plan'
INTO		  dbo.PG_product_perc_max_week_quantity_update
FROM		  PG_product_week_quantities_update pwq
INNER JOIN  PG_product_max_week_quantity paq
ON		  pwq.ProductNumber = paq.ProductNumber
	   AND pwq.Branch_name_EN = paq.Branch_name_EN
INNER JOIN  CTE2 cte
ON		  cte.yearweek = pwq.yearweek

DELETE FROM PG_product_perc_max_week_quantity
WHERE	  yearweek_id IN (SELECT yearweek_id FROM PG_product_perc_max_week_quantity_update GROUP BY yearweek_id)
INSERT INTO PG_product_perc_max_week_quantity
SELECT	  *
FROM		  PG_product_perc_max_week_quantity_update

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			6,
			@step,
			'Percentage in quantity of maximum week calculated',
			SYSDATETIME()
		)

-- Creates update table with estimated IO-indicators
IF OBJECT_ID('dbo.PG_product_in_out_indicators_update','U') IS NOT NULL
    DROP TABLE dbo.PG_product_in_out_indicators_update
CREATE TABLE dbo.PG_product_in_out_indicators_update
(ProductNumber		BIGINT,
 Branch_name_EN	VARCHAR(7),
 yearweek_id		INT,
 yearweek			INT,
 number_days		INT,
 week_quantity		DECIMAL(15,2),
 max_week_quantity	DECIMAL(15,2),
 perc_max_week_quantity DECIMAL(5,4),
 Ind_in_plan		SMALLINT
)

DECLARE	  @max_week   INT = (SELECT MAX(yearweek_id) FROM PG_product_perc_max_week_quantity_update);
DECLARE	  @week_id    INT = @max_week;
WHILE @week_id >= (SELECT MIN(yearweek_id) - 3 FROM PG_product_perc_max_week_quantity_update)
BEGIN
    INSERT INTO PG_product_in_out_indicators_update
    SELECT	 pp.ProductNumber,
			 pp.Branch_name_EN,
			 pp.yearweek_id,
			 pp.yearweek,
			 pp.number_days,
			 pp.week_quantity,
			 pp.max_week_quantity,
			 pp.perc_max_week_quantity,
			 CASE WHEN pp.Ind_in_plan = 0 AND SUM(pp2.Ind_in_plan) = 0 THEN 0
				 ELSE 1 END AS 'Ind_in_plan'
    FROM		 PG_product_perc_max_week_quantity pp
    LEFT JOIN	 PG_product_perc_max_week_quantity pp2
    ON		 pp2.ProductNumber = pp.ProductNumber
		  AND pp2.Branch_name_EN = pp.Branch_name_EN
		  AND pp2.yearweek_id BETWEEN @week_id - 3 AND @week_id - 1
    LEFT JOIN	 PG_product_in_out_indicators_update pio
    ON		 pio.ProductNumber = pp.ProductNumber
		  AND pio.Branch_name_EN = pp.Branch_name_EN
		  AND pio.yearweek_id = @week_id + 1
    WHERE		 pp.yearweek_id = @week_id
    GROUP BY	 pp.ProductNumber,
			 pp.Branch_name_EN,
			 pp.yearweek_id,
			 pp.yearweek,
			 pp.number_days,
			 pp.week_quantity,
			 pp.max_week_quantity,
			 pp.perc_max_week_quantity,
			 pp.Ind_in_plan,
			 pio.Ind_in_plan

    SET @week_id = @week_id - 1;
END

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			6,
			@step,
			'Update table with estimated IO-indicators created',
			SYSDATETIME()
		)

-- Move IO-data to history
DELETE FROM PG_product_in_out_indicators
WHERE	  yearweek_id BETWEEN (SELECT MIN(yearweek_id) - 3 FROM PG_product_perc_max_week_quantity_update)
					   AND (SELECT MAX(yearweek_id) FROM PG_product_perc_max_week_quantity_update)
INSERT INTO PG_product_in_out_indicators
SELECT	  *
FROM		  PG_product_in_out_indicators_update

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			6,
			@step,
			'IO-data moved to history',
			SYSDATETIME()
		)

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			6,
			@step,
			'End of [update_6b_in_out_indicators]',
			SYSDATETIME()
		)

END
