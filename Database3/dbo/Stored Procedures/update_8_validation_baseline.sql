-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2018-01-05
-- Description:	Script that validates the baseline of the last complete week
-- =============================================
CREATE PROCEDURE [dbo].[update_8_validation_baseline]
     @run_nr INT = 1
    ,@run_date DATE = '2018-01-05'
    ,@start_date DATE = '2017-12-26'
    ,@baseline_days INT = 28
    ,@min_quantity INT = 2500
AS
BEGIN

DECLARE @step INT = 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			8,
			@step,
			'Start of [update_8_validation_baseline]',
			SYSDATETIME()
		)

-- Selects correct yearweek based on start date of update
DECLARE @yearweek INT = (SELECT yearweek FROM PG_dim_date WHERE date = @start_date);

-- Select products with more than a certain quantity sold per week
IF OBJECT_ID('tempdb.dbo.#product_sales_per_week', 'U') IS NOT NULL
    DROP TABLE #product_sales_per_week
SELECT	  dt.yearweek,
		  MIN(dt.date) AS 'FDOW',
		  MAX(dt.date) AS 'LDOW',
		  spp.ProductNumber,
		  spp.Branch_name_EN,
		  spp.SourceInd,
		  SUM(spp.Number_of_customers) AS 'Number_of_customers',
		  SUM(spp.Revenue) AS 'Revenue',
		  SUM(spp.Quantity) AS 'Quantity',
		  SUM(spp.Margin) AS 'Margin'
INTO		  #product_sales_per_week
FROM		  dbo.PG_sales_per_product_per_day_wo_returns spp
INNER JOIN  dbo.PG_dim_date dt
ON		  spp.TransactionDate = dt.Date
WHERE	  Branch_name_EN NOT IN ('Yesh','Online')
	   AND dt.yearweek = @yearweek
GROUP BY	  dt.yearweek,
		  spp.ProductNumber,
		  spp.Branch_name_EN,
		  spp.SourceInd
HAVING	  SUM(spp.Quantity) >= @min_quantity
	   AND SUM(spp.Revenue)*SUM(spp.Margin)*SUM(spp.Number_of_customers) <> 0

-- Selects those products that have not been in promotion during a week
IF OBJECT_ID('tempdb.dbo.#valid_products', 'U') IS NOT NULL
    DROP TABLE #valid_products
SELECT	  ROW_NUMBER() OVER(ORDER BY psw.yearweek, psw.ProductNumber, psw.Branch_name_EN, psw.SourceInd) AS 'Package_number',
		  psw.yearweek,
		  psw.FDOW,
		  psw.LDOW,
		  psw.ProductNumber,
		  psw.Branch_name_EN,
		  psw.SourceInd,
		  psw.Number_of_customers,
		  psw.Revenue,
		  psw.Quantity,
		  psw.Margin
INTO		  #valid_products
FROM		  #product_sales_per_week psw
INNER JOIN  dbo.PG_promo_product_ind ppi
ON		  ppi.ProductNumber = psw.ProductNumber
	   AND ppi.Branch_name_EN = psw.Branch_name_EN
	   AND ppi.SourceInd = psw.SourceInd
	   AND ppi.TransactionDate BETWEEN psw.FDOW AND psw.LDOW
WHERE	  yearweek > 201501
GROUP BY	  psw.yearweek,
		  psw.FDOW,
		  psw.LDOW,
		  psw.ProductNumber,
		  psw.Branch_name_EN,
		  psw.SourceInd,
		  psw.Number_of_customers,
		  psw.Revenue,
		  psw.Quantity,
		  psw.Margin
HAVING	  SUM(ppi.Promo_ind) = 0

IF OBJECT_ID('tempdb.dbo.#baseline_days', 'U') IS NOT NULL
    DROP TABLE #baseline_days
;WITH CTE AS
(SELECT	  cp.Package_number,
		  cp.FDOW,
		  cp.LDOW,
		  cp.ProductNumber,
		  cp.Branch_name_EN,
		  cp.SourceInd,
		  ppi.TransactionDate,
		  ISNULL(at.Number_of_customers,0) AS 'Number_of_customers',
		  ISNULL(at.Quantity,0) AS Quantity,
		  ISNULL(at.Revenue,0) AS Revenue,
		  ISNULL(at.Margin,0) AS Margin,
		  wd.correction_weekday*cf.correction_holiday*cf.correction_season AS 'correction_factor',
		  ROW_NUMBER()
			 OVER(PARTITION BY	 cp.Package_number,
							 cp.FDOW,
							 cp.LDOW,
							 cp.ProductNumber,
							 cp.Branch_name_EN,
							 cp.SourceInd
			      ORDER BY		 ppi.TransactionDate DESC)
		  AS 'Day_index'
 FROM	  #valid_products cp
 INNER JOIN dbo.PG_promo_product_ind ppi
 ON		  ppi.TransactionDate BETWEEN DATEADD(day,-180,cp.FDOW) AND DATEADD(day,-1,cp.LDOW)
        AND ppi.ProductNumber = cp.ProductNumber
	   AND ppi.SourceInd = cp.SourceInd
	   AND ppi.Branch_name_EN = cp.Branch_name_EN
	   AND ppi.Promo_ind = 0
 LEFT JOIN  Staging_holidays hd
 ON		  (hd.holiday = 'Pesach'or hd.holiday='Rosh Hashana' or hd.holiday='Sukkot')
	   AND ppi.TransactionDate BETWEEN DATEADD(day,-@baseline_days,hd.start_date) AND hd.end_date
 LEFT JOIN  dbo.PG_sales_per_product_per_day_wo_returns at
 ON		  at.TransactionDate = ppi.TransactionDate
        AND at.ProductNumber = cp.ProductNumber
	   AND at.SourceInd = cp.SourceInd
	   AND at.Branch_name_EN = cp.Branch_name_EN
 INNER JOIN dbo.PG_correction_factors cf
 ON		  cf.ProductNumber = cp.ProductNumber
	   AND cf.TransactionDate = ppi.TransactionDate
 INNER JOIN dbo.PG_correction_weekday wd
 ON		wd.date = ppi.TransactionDate
	 AND wd.Branch_name_EN = ppi.Branch_name_EN
	 AND wd.correction_weekday <> 0
 WHERE	  hd.holiday IS NULL
)
SELECT	  cte.Package_number,
		  cte.FDOW,
		  cte.LDOW,
		  cte.ProductNumber,
		  cte.Branch_name_EN,
		  cte.SourceInd,
		  cte.TransactionDate,
		  cte.Number_of_customers,
		  cte.Quantity,
		  cte.Revenue,
		  cte.Margin,
		  cte.correction_factor,
		  cte.Day_index,
		  AVG(cte.Number_of_customers*cte.correction_factor) OVER (PARTITION BY cte.Package_number,
																	  cte.FDOW,
																	  cte.LDOW,
																	  cte.ProductNumber,
																	  cte.Branch_name_EN,
																	  cte.SourceInd) AS 'avg_number_of_customers',
		  AVG(cte.Quantity*cte.correction_factor) OVER (PARTITION BY cte.Package_number,
																	  cte.FDOW,
																	  cte.LDOW,
																	  cte.ProductNumber,
																	  cte.Branch_name_EN,
																	  cte.SourceInd) AS 'avg_quantity',
		  AVG(cte.Revenue*cte.correction_factor) OVER (PARTITION BY cte.Package_number,
																	  cte.FDOW,
																	  cte.LDOW,
																	  cte.ProductNumber,
																	  cte.Branch_name_EN,
																	  cte.SourceInd) AS 'avg_revenue',
		  AVG(cte.Margin*cte.correction_factor) OVER (PARTITION BY cte.Package_number,
																	  cte.FDOW,
																	  cte.LDOW,
																	  cte.ProductNumber,
																	  cte.Branch_name_EN,
																	  cte.SourceInd) AS 'avg_margin',
		  STDEVP(cte.Quantity*cte.correction_factor) OVER (PARTITION BY cte.Package_number,
																	  cte.FDOW,
																	  cte.LDOW,
																	  cte.ProductNumber,
																	  cte.Branch_name_EN,
																	  cte.SourceInd) AS 'stdevp_quantity',
		  CASE WHEN (cte.Quantity*cte.correction_factor - AVG(cte.Quantity*cte.correction_factor) OVER (PARTITION BY cte.Package_number, cte.FDOW, cte.LDOW, cte.ProductNumber, cte.Branch_name_EN, cte.SourceInd))
					> 2*STDEVP(cte.Quantity*cte.correction_factor) OVER (PARTITION BY cte.Package_number, cte.FDOW, cte.LDOW, cte.ProductNumber, cte.Branch_name_EN, cte.SourceInd)
			   THEN 0 ELSE 1 END AS 'Valid_ind',
		  pio.Ind_in_plan
INTO		  #baseline_days
FROM		  CTE cte
INNER JOIN  dbo.PG_dim_date dt
ON		  dt.date = cte.TransactionDate
INNER JOIN  dbo.PG_product_in_out_indicators pio
ON		  cte.ProductNumber = pio.ProductNumber
	   AND cte.Branch_name_EN = pio.Branch_name_EN
	   AND dt.yearweek = pio.yearweek
WHERE	  cte.Day_index <= @baseline_days

-- Calculates standard day per promotion product
IF OBJECT_ID('tempdb.dbo.#standard_day', 'U') IS NOT NULL
    DROP TABLE #standard_day;
SELECT	  cte.Package_number,
		  cte.FDOW,
		  cte.LDOW,
		  cte.ProductNumber,
		  cte.Branch_name_EN,
		  cte.SourceInd,
		  COUNT(Valid_ind) AS 'Baseline_days',
		  SUM(Valid_ind) AS 'Valid_baseline_days',
		  SUM(Ind_in_plan) AS 'Days_in_plan',
		  CASE WHEN SUM(valid_ind) = 0 THEN avg_number_of_customers*COUNT(cte.TransactionDate)
			  ELSE SUM(cte.Number_of_customers * cte.correction_factor * cte.valid_ind)/SUM(valid_ind) END AS 'Baseline_customers',
		  CASE WHEN SUM(valid_ind) = 0 THEN avg_quantity*COUNT(cte.TransactionDate)
			  ELSE SUM(cte.Quantity * cte.correction_factor * cte.valid_ind)/SUM(valid_ind) END AS 'Baseline_quantity',
		  CASE WHEN SUM(valid_ind) = 0 THEN avg_revenue*COUNT(cte.TransactionDate)
			  ELSE SUM(cte.Revenue * cte.correction_factor * cte.valid_ind)/SUM(valid_ind) END AS 'Baseline_revenue',
		  CASE WHEN SUM(valid_ind) = 0 THEN avg_margin*COUNT(cte.TransactionDate)
			  ELSE SUM(cte.Margin * cte.correction_factor * cte.valid_ind)/SUM(valid_ind) END AS 'Baseline_margin',
		  CASE WHEN COUNT(valid_ind) = @baseline_days THEN 0 ELSE 1 END AS 'Ind_less_28_baseline_days'
INTO		  #standard_day
FROM		  #baseline_days CTE
GROUP BY	  cte.Package_number,
		  cte.FDOW,
		  cte.LDOW,
		  cte.ProductNumber,
		  cte.Branch_name_EN,
		  cte.SourceInd,
		  cte.avg_number_of_customers,
		  cte.avg_margin,
		  cte.avg_quantity,
		  cte.avg_revenue

-- Calculates baseline per day
IF OBJECT_ID('tempdb.dbo.#daily_baseline','U') IS NOT NULL
    DROP TABLE #daily_baseline;
WITH CTE AS
(SELECT	  cp.Package_number,
		  cp.FDOW,
		  cp.LDOW,
		  cp.ProductNumber,
		  cp.Branch_name_EN,
		  cp.SourceInd,
		  cf.TransactionDate,
		  wd.correction_weekday*cf.correction_holiday*cf.correction_season AS 'correction_factor'
 FROM	  #valid_products cp
 INNER JOIN dbo.PG_correction_factors cf
 ON		  cf.ProductNumber = cp.ProductNumber
	   AND cf.TransactionDate BETWEEN cp.FDOW AND cp.LDOW
 INNER JOIN dbo.PG_correction_weekday wd
 ON		wd.date = cf.TransactionDate
	 AND wd.Branch_name_EN = cp.Branch_name_EN
)
SELECT	  cte.Package_number,
		  cte.FDOW,
		  cte.LDOW,
		  cte.ProductNumber,
		  cte.Branch_name_EN,
		  cte.SourceInd,
		  cte.TransactionDate,
		  sd.Baseline_days,
		  sd.Valid_baseline_days,
		  sd.Days_in_plan,
		  CASE WHEN cte.correction_factor = 0 THEN 0
			  ELSE sd.Baseline_customers / cte.correction_factor
		  END AS 'Baseline_customers',
		  CASE WHEN cte.correction_factor = 0 THEN 0
			  ELSE sd.Baseline_quantity / cte.correction_factor
		  END AS 'Baseline_quantity',
		  CASE WHEN cte.correction_factor = 0 THEN 0
			  ELSE sd.Baseline_revenue / cte.correction_factor
		  END AS 'Baseline_revenue',
		  CASE WHEN cte.correction_factor = 0 THEN 0
			  ELSE sd.Baseline_margin / cte.correction_factor
		  END AS 'Baseline_margin',
		  sd.Ind_less_28_baseline_days
INTO		  #daily_baseline
FROM		  CTE cte
INNER JOIN  #standard_day sd
ON		  sd.Package_number = cte.Package_number
	   AND sd.ProductNumber = cte.ProductNumber
	   AND sd.FDOW = cte.FDOW
	   AND sd.LDOW = cte.LDOW
	   AND sd.SourceInd = cte.SourceInd
	   AND sd.Branch_name_EN = cte.Branch_name_EN

-- Combines baseline and results per week
IF OBJECT_ID('tempdb.dbo.#baseline_vs_results','U') IS NOT NULL
    DROP TABLE #baseline_vs_results
SELECT	  db.Package_number,
		  vp.yearweek,
		  db.FDOW,
		  db.LDOW,
		  db.ProductNumber,
		  db.Branch_name_EN,
		  db.SourceInd,
		  db.Baseline_days,
		  db.Valid_baseline_days,
		  db.Days_in_plan,
		  SUM(db.Baseline_customers) AS 'Baseline_customers',
		  vp.Number_of_customers AS 'Real_customers',
		  SUM(db.Baseline_revenue) AS 'Baseline_revenue',
		  vp.Revenue AS 'Real_revenue',
		  SUM(db.Baseline_quantity) AS 'Baseline_quantity',
		  vp.Quantity AS 'Real_quantity',
		  SUM(db.Baseline_margin) AS 'Baseline_margin',
		  vp.Margin AS 'Real_margin'
INTO		  #baseline_vs_results
FROM		  #daily_baseline db
INNER JOIN  #valid_products vp
ON		  vp.Package_number = db.Package_number
GROUP BY	  db.Package_number,
		  vp.yearweek,
		  db.FDOW,
		  db.LDOW,
		  db.ProductNumber,
		  db.Branch_name_EN,
		  db.SourceInd,
		  db.Baseline_days,
		  db.Valid_baseline_days,
		  db.Days_in_plan,
		  vp.Number_of_customers,
		  vp.Revenue,
		  vp.Quantity,
		  vp.Margin

-- Calculates MPE and MAPE for this yearweek
DELETE FROM dbo.PG_baseline_validation_weekly
WHERE	  yearweek = @yearweek;

INSERT INTO dbo.PG_baseline_validation_weekly
SELECT	  yearweek,
		  COUNT(*) AS 'Nr_products',
		  SUM(Baseline_customers-Real_customers)/SUM(Real_customers) AS 'Customers_MPE',
		  SUM(ABS(Baseline_customers-Real_customers))/SUM(Real_customers) AS 'Customers_MAPE',
		  SUM(Baseline_quantity-Real_quantity)/SUM(Real_quantity) AS 'Quantity_MPE',
		  SUM(ABS(Baseline_quantity-Real_quantity))/SUM(Real_quantity) AS 'Quantity_MAPE',
		  SUM(Baseline_revenue-Real_revenue)/SUM(Real_revenue) AS 'Revenue_MPE',
		  SUM(ABS(Baseline_revenue-Real_revenue))/SUM(Real_revenue) AS 'Revenue_MAPE',
		  SUM(Baseline_margin-Real_margin)/SUM(Real_margin) AS 'Margin_MPE',
		  SUM(ABS(Baseline_margin-Real_margin))/SUM(Real_margin) AS 'Margin_MAPE'
FROM		  #baseline_vs_results
GROUP BY	  yearweek

-- Calculates PE on a product level to sort it
DELETE FROM dbo.PG_baseline_validation_product
WHERE	  yearweek = @yearweek;

INSERT INTO dbo.PG_baseline_validation_product
SELECT	  br.yearweek,
		  br.Package_number,
		  br.FDOW,
		  br.LDOW,
		  br.ProductNumber,
		  br.Branch_name_EN,
		  br.SourceInd,
		  br.Baseline_days,
		  br.Valid_baseline_days,
		  br.Days_in_plan,
		  br.Baseline_customers,
		  br.Real_customers,
		  br.Baseline_quantity,
		  br.Real_quantity,
		  br.Baseline_revenue,
		  br.Real_revenue,
		  br.Baseline_margin,
		  br.Real_margin,
		  (br.Baseline_customers - br.Real_customers)/br.Real_customers AS 'Customers_PE',
		  (br.Baseline_quantity - br.Real_quantity)/br.Real_quantity AS 'Quantity_PE',
		  (br.Baseline_revenue - br.Real_revenue)/br.Real_revenue AS 'Revenue_PE',
		  (br.Baseline_margin - br.Real_margin)/br.Real_margin AS 'Margin_PE',
		  -- 1) Deviation through 28 days of baseline
		  (SUM(bd.Number_of_customers)/4.0-br.Real_customers)/(1.0*br.Real_customers) AS '1_Customers_PE',
		  (SUM(bd.Quantity)/4.0 - br.Real_quantity)/br.Real_quantity AS '1_Quantity_PE',
		  (SUM(bd.Revenue)/4.0 - br.Real_revenue)/br.Real_revenue AS '1_Revenue_PE',
		  (SUM(bd.Margin)/4.0 - br.Real_margin)/br.Real_margin AS '1_Margin_PE'
FROM		  #baseline_vs_results br
LEFT JOIN	  #baseline_days bd
ON		  br.Package_number = bd.Package_number
GROUP BY	  br.yearweek,
		  br.Package_number,
		  br.FDOW,
		  br.LDOW,
		  br.ProductNumber,
		  br.Branch_name_EN,
		  br.SourceInd,
		  br.Baseline_days,
		  br.Valid_baseline_days,
		  br.Days_in_plan,
		  br.Baseline_customers,
		  br.Real_customers,
		  br.Baseline_quantity,
		  br.Real_quantity,
		  br.Baseline_revenue,
		  br.Real_revenue,
		  br.Baseline_margin,
		  br.Real_margin

SET		  @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			8,
			@step,
			'End of [update_8_validation_baseline]',
			SYSDATETIME()
		)

END
