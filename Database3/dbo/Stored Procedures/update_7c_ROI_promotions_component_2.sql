-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-10
-- Description:	Script for component 2 of ROI for weekly and monthly promotions
-- =============================================
CREATE PROCEDURE [dbo].[update_7c_ROI_promotions_component_2]
	@run_nr INT = 177,
    @run_date DATE = '2019-02-03',
	@step INT = 1,
    @start_date DATE = '2018-09-16',
    @end_date DATE = '2018-09-30',
	@baseline_days INT = 28,
	@min_uplift FLOAT = 0.95,
	@max_uplift FLOAT = 100.0,
	@min_discount FLOAT = 0.05
AS
BEGIN

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Start of [update_7c_ROI_promotions_component_2]',
			SYSDATETIME()
		)

-- Calculates baseline days per promotion product

DROP TABLE ROI_component_2a_baseline_days_CTE;
SELECT	  cp.PromotionNumber,
		  cp.PromotionStartDate,
		  cp.PromotionEndDate,
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
			 OVER(PARTITION BY	 cp.PromotionNumber,
							 cp.PromotionStartDate,
							 cp.PromotionEndDate,
							 cp.ProductNumber,
							 cp.Branch_name_EN,
							 cp.SourceInd
			      ORDER BY		 ppi.TransactionDate DESC)
		  AS 'Day_index'
 into ROI_component_2a_baseline_days_CTE
 FROM PG_promotions_update cp
 INNER JOIN PG_promo_product_ind ppi
 ON		  ppi.TransactionDate BETWEEN DATEADD(day,-180,cp.PromotionStartDate) AND DATEADD(day,-1,cp.PromotionStartDate)
        AND ppi.ProductNumber = cp.ProductNumber
	   AND ppi.SourceInd = cp.SourceInd
	   AND ppi.Branch_name_EN = cp.Branch_name_EN
	   AND ppi.Promo_ind = 0
 LEFT JOIN  Staging_holidays_fix hd
 ON	ppi.TransactionDate =hd.[date]
 LEFT JOIN  PG_sales_per_product_per_day_wo_returns at
 ON		  at.TransactionDate = ppi.TransactionDate
        AND at.ProductNumber = cp.ProductNumber
	   AND at.SourceInd = cp.SourceInd
	   AND at.Branch_name_EN = cp.Branch_name_EN
 INNER JOIN PG_correction_factors cf
 ON		  cf.ProductNumber = cp.ProductNumber
	   AND cf.TransactionDate = ppi.TransactionDate
 INNER JOIN PG_correction_weekday wd
 ON		wd.date = ppi.TransactionDate
	 AND wd.Branch_name_EN = ppi.Branch_name_EN
	 AND wd.correction_weekday <> 0
 WHERE	  hd.holiday IS NULL


IF OBJECT_ID('tempdb.dbo.#ROI_component_2a_baseline_days', 'U') IS NOT NULL
    DROP TABLE #ROI_component_2a_baseline_days;
SELECT	  cte.PromotionNumber,
		  cte.PromotionStartDate,
		  cte.PromotionEndDate,
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
		  AVG(cte.Number_of_customers*cte.correction_factor) OVER (PARTITION BY cte.PromotionNumber,
																	  cte.PromotionStartDate,
																	  cte.PromotionEndDate,
																	  cte.ProductNumber,
																	  cte.Branch_name_EN,
																	  cte.SourceInd) AS 'avg_number_of_customers',
		  AVG(cte.Quantity*cte.correction_factor) OVER (PARTITION BY cte.PromotionNumber,
																	  cte.PromotionStartDate,
																	  cte.PromotionEndDate,
																	  cte.ProductNumber,
																	  cte.Branch_name_EN,
																	  cte.SourceInd) AS 'avg_quantity',
		  AVG(cte.Revenue*cte.correction_factor) OVER (PARTITION BY cte.PromotionNumber,
																	  cte.PromotionStartDate,
																	  cte.PromotionEndDate,
																	  cte.ProductNumber,
																	  cte.Branch_name_EN,
																	  cte.SourceInd) AS 'avg_revenue',
		  AVG(cte.Margin*cte.correction_factor) OVER (PARTITION BY cte.PromotionNumber,
																	  cte.PromotionStartDate,
																	  cte.PromotionEndDate,
																	  cte.ProductNumber,
																	  cte.Branch_name_EN,
																	  cte.SourceInd) AS 'avg_margin',
		  STDEVP(cte.Quantity*cte.correction_factor) OVER (PARTITION BY cte.PromotionNumber,
																	  cte.PromotionStartDate,
																	  cte.PromotionEndDate,
																	  cte.ProductNumber,
																	  cte.Branch_name_EN,
																	  cte.SourceInd) AS 'stdevp_quantity',
		  CASE WHEN (cte.Quantity*cte.correction_factor - AVG(cte.Quantity*cte.correction_factor) OVER (PARTITION BY cte.PromotionNumber, cte.PromotionStartDate, cte.PromotionEndDate, cte.ProductNumber, cte.Branch_name_EN, cte.SourceInd))
					> 2*STDEVP(cte.Quantity*cte.correction_factor) OVER (PARTITION BY cte.PromotionNumber, cte.PromotionStartDate, cte.PromotionEndDate, cte.ProductNumber, cte.Branch_name_EN, cte.SourceInd)
			   THEN 0 ELSE 1 END AS 'Valid_ind',
		  pio.Ind_in_plan
INTO		  #ROI_component_2a_baseline_days
FROM		  ROI_component_2a_baseline_days_CTE cte
INNER JOIN  PG_dim_date dt
ON		  dt.date = cte.TransactionDate
INNER JOIN  PG_product_in_out_indicators pio
ON		  cte.ProductNumber = pio.ProductNumber
	   AND cte.Branch_name_EN = pio.Branch_name_EN
	   AND dt.yearweek = pio.yearweek
WHERE	  cte.Day_index <= @baseline_days

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Baseline days per promotion product calculated',
			SYSDATETIME()
		)

-- Calculates standard day per promotion product
IF OBJECT_ID('tempdb.dbo.#ROI_component_2b_standard_day', 'U') IS NOT NULL
    DROP TABLE #ROI_component_2b_standard_day;
SELECT	  cte.PromotionNumber,
		  cte.PromotionStartDate,
		  cte.PromotionEndDate,
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
		  CASE WHEN COUNT(valid_ind) = 28 THEN 0 ELSE 1 END AS 'Ind_less_28_baseline_days'
INTO		  #ROI_component_2b_standard_day
FROM		  #ROI_component_2a_baseline_days CTE
GROUP BY	  cte.PromotionNumber,
		  cte.PromotionStartDate,
		  cte.PromotionEndDate,
		  cte.ProductNumber,
		  cte.Branch_name_EN,
		  cte.SourceInd,
		  cte.avg_number_of_customers,
		  cte.avg_margin,
		  cte.avg_quantity,
		  cte.avg_revenue

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Standard day per promotion product calculated',
			SYSDATETIME()
		)

-- Selects continuous promotions and determines their category
TRUNCATE TABLE dbo.PG_ROI_component_2c_continuous_promotions_update;
WITH CTE AS
(SELECT	  pr.PromotionNumber,
		  pr.PromotionStartDate,
		  pr.PromotionEndDate,
		  pr.ProductNumber,
		  pr.Branch_name_EN,
		  pr.SourceInd
 FROM	  PG_promotions_update pr
 EXCEPT
 SELECT	  sd.PromotionNumber,
		  sd.PromotionStartDate,
		  sd.PromotionEndDate,
		  sd.ProductNumber,
		  sd.Branch_name_EN,
		  sd.SourceInd
 FROM	  #ROI_component_2b_standard_day sd
 WHERE	  sd.Ind_less_28_baseline_days = 0
)
INSERT INTO dbo.PG_ROI_component_2c_continuous_promotions_update
SELECT	  cte.PromotionNumber,
		  cte.PromotionStartDate,
		  cte.PromotionEndDate,
		  cte.ProductNumber,
		  cte.Branch_name_EN,
		  cte.SourceInd,
		  CASE WHEN SUM(ro1.Real_quantity) = 0 THEN NULL
			  ELSE SUM(ro1.Revenue_1_promotion)/SUM(ro1.Real_quantity)
		  END AS 'Avg_promotion_price',
		  CASE WHEN SUM(spp.Quantity) = 0 THEN NULL
			  ELSE SUM(spp.Revenue)/SUM(spp.Quantity)
		  END AS 'Avg_price_before',
		  CASE WHEN (SUM(spp.Revenue) = 0 OR SUM(spp.Quantity) = 0)
				   AND SUM(ro1.Real_quantity) > 0 THEN 1
			  WHEN (SUM(spp.Revenue) = 0 OR SUM(spp.Quantity) = 0)
				   AND SUM(ro1.Real_quantity) = 0 THEN 0
			  WHEN 1 - (CASE WHEN SUM(ro1.Real_quantity) = 0 THEN NULL
					   ELSE SUM(ro1.Revenue_1_promotion)/SUM(ro1.Real_quantity)
					   END)/
				      (CASE WHEN SUM(spp.Quantity) = 0 THEN NULL
					   ELSE SUM(spp.Revenue)/SUM(spp.Quantity)
					   END) > @min_discount THEN 1 ELSE 0 END AS 'Ind_sufficient_discount'
FROM		  CTE cte
INNER JOIN  dbo.PG_ROI_component_1 ro1
ON		  ro1.PromotionNumber = cte.PromotionNumber
	   AND ro1.PromotionStartDate = cte.PromotionStartDate
	   AND ro1.PromotionEndDate = cte.PromotionEndDate
	   AND ro1.ProductNumber = cte.ProductNumber
	   AND ro1.Branch_name_EN = cte.Branch_name_EN
	   AND ro1.SourceInd = cte.SourceInd
LEFT JOIN   PG_sales_per_product_per_day_wo_returns spp
ON		  spp.ProductNumber = cte.ProductNumber
	   AND spp.Branch_name_EN = cte.Branch_name_EN
	   AND spp.SourceInd = cte.SourceInd
	   AND spp.TransactionDate BETWEEN DATEADD(day,-@baseline_days,cte.PromotionStartDate) AND DATEADD(day,-1,cte.PromotionStartDate)
GROUP BY	  cte.PromotionNumber,
		  cte.PromotionStartDate,
		  cte.PromotionEndDate,
		  cte.ProductNumber,
		  cte.Branch_name_EN,
		  cte.SourceInd

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Continuous promotions selected and their category determined',
			SYSDATETIME()
		)

-- Calculates baseline days per promotion product for continuous promotions with sufficient promotions
IF OBJECT_ID('tempdb.dbo.#ROI_component_2a_baseline_days_continuous', 'U') IS NOT NULL
    DROP TABLE #ROI_component_2a_baseline_days_continuous;
WITH CTE AS
(SELECT	  cp.PromotionNumber,
		  cp.PromotionStartDate,
		  cp.PromotionEndDate,
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
			 OVER(PARTITION BY	 cp.PromotionNumber,
							 cp.PromotionStartDate,
							 cp.PromotionEndDate,
							 cp.ProductNumber,
							 cp.Branch_name_EN,
							 cp.SourceInd
			      ORDER BY		 ppi.TransactionDate DESC)
		  AS 'Day_index'
 FROM	  PG_ROI_component_2c_continuous_promotions_update cp
 INNER JOIN PG_promo_product_ind ppi
 ON		  ppi.TransactionDate BETWEEN DATEADD(day,-180,cp.PromotionStartDate) AND DATEADD(day,-1,cp.PromotionStartDate)
        AND ppi.ProductNumber = cp.ProductNumber
	   AND ppi.SourceInd = cp.SourceInd
	   AND ppi.Branch_name_EN = cp.Branch_name_EN
 LEFT JOIN  Staging_holidays hd
 ON		  (hd.holiday = 'Pesach' or hd.holiday='Rosh Hashana' or hd.holiday='Sukkot')
	   AND ppi.TransactionDate BETWEEN DATEADD(day,-@baseline_days,hd.start_date) AND hd.end_date
 LEFT JOIN  PG_sales_per_product_per_day_wo_returns at
 ON		  at.TransactionDate = ppi.TransactionDate
        AND at.ProductNumber = cp.ProductNumber
	   AND at.SourceInd = cp.SourceInd
	   AND at.Branch_name_EN = cp.Branch_name_EN
 INNER JOIN PG_correction_factors cf
 ON		  cf.ProductNumber = cp.ProductNumber
	   AND cf.TransactionDate = ppi.TransactionDate
 INNER JOIN PG_correction_weekday wd
 ON		wd.date = ppi.TransactionDate
	 AND wd.Branch_name_EN = ppi.Branch_name_EN
	 AND wd.correction_weekday <> 0
 WHERE	  cp.Ind_sufficient_discount = 1
	   AND hd.holiday IS NULL
)
SELECT	  cte.PromotionNumber,
		  cte.PromotionStartDate,
		  cte.PromotionEndDate,
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
		  AVG(cte.Number_of_customers*cte.correction_factor) OVER (PARTITION BY cte.PromotionNumber,
																	  cte.PromotionStartDate,
																	  cte.PromotionEndDate,
																	  cte.ProductNumber,
																	  cte.Branch_name_EN,
																	  cte.SourceInd) AS 'avg_number_of_customers',
		  AVG(cte.Quantity*cte.correction_factor) OVER (PARTITION BY cte.PromotionNumber,
																	  cte.PromotionStartDate,
																	  cte.PromotionEndDate,
																	  cte.ProductNumber,
																	  cte.Branch_name_EN,
																	  cte.SourceInd) AS 'avg_quantity',
		  AVG(cte.Revenue*cte.correction_factor) OVER (PARTITION BY cte.PromotionNumber,
																	  cte.PromotionStartDate,
																	  cte.PromotionEndDate,
																	  cte.ProductNumber,
																	  cte.Branch_name_EN,
																	  cte.SourceInd) AS 'avg_revenue',
		  AVG(cte.Margin*cte.correction_factor) OVER (PARTITION BY cte.PromotionNumber,
																	  cte.PromotionStartDate,
																	  cte.PromotionEndDate,
																	  cte.ProductNumber,
																	  cte.Branch_name_EN,
																	  cte.SourceInd) AS 'avg_margin',
		  STDEVP(cte.Quantity*cte.correction_factor) OVER (PARTITION BY cte.PromotionNumber,
																	  cte.PromotionStartDate,
																	  cte.PromotionEndDate,
																	  cte.ProductNumber,
																	  cte.Branch_name_EN,
																	  cte.SourceInd) AS 'stdevp_quantity',
		  CASE WHEN (cte.Quantity*cte.correction_factor - AVG(cte.Quantity*cte.correction_factor) OVER (PARTITION BY cte.PromotionNumber, cte.PromotionStartDate, cte.PromotionEndDate, cte.ProductNumber, cte.Branch_name_EN, cte.SourceInd))
					> 2*STDEVP(cte.Quantity*cte.correction_factor) OVER (PARTITION BY cte.PromotionNumber, cte.PromotionStartDate, cte.PromotionEndDate, cte.ProductNumber, cte.Branch_name_EN, cte.SourceInd)
			   THEN 0 ELSE 1 END AS 'Valid_ind',
		  pio.Ind_in_plan
INTO		  #ROI_component_2a_baseline_days_continuous
FROM		  CTE cte
INNER JOIN  PG_dim_date dt
ON		  dt.date = cte.TransactionDate
INNER JOIN  PG_product_in_out_indicators pio
ON		  cte.ProductNumber = pio.ProductNumber
	   AND cte.Branch_name_EN = pio.Branch_name_EN
	   AND dt.yearweek = pio.yearweek
WHERE	  cte.Day_index <= @baseline_days

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Baseline days per promotion product calculated for continuous promotions with sufficient discount',
			SYSDATETIME()
		)

-- Baseline days per promotion product selected into dbo.PG_ROI_component_2a_baseline_days_update
TRUNCATE TABLE dbo.PG_ROI_component_2a_baseline_days_update;
INSERT INTO dbo.PG_ROI_component_2a_baseline_days_update
SELECT	  bd.*,
		  0 AS 'Continuous_promotion'
FROM		  #ROI_component_2a_baseline_days bd
LEFT JOIN	  PG_ROI_component_2c_continuous_promotions_update cp
ON		  cp.PromotionNumber = bd.PromotionNumber
	   AND cp.PromotionStartDate = bd.PromotionStartDate
	   AND cp.PromotionEndDate = bd.PromotionEndDate
	   AND cp.ProductNumber = bd.ProductNumber
	   AND cp.Branch_name_EN = bd.Branch_name_EN
	   AND cp.SourceInd = bd.SourceInd
WHERE	  cp.PromotionNumber IS NULL
UNION
SELECT	  bd.*,
		  1
FROM		  #ROI_component_2a_baseline_days_continuous bd

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Baseline days per promotion product selected into table dbo.PG_ROI_component_2a_baseline_days_update',
			SYSDATETIME()
		)

-- Calculates standard day per promotion product
IF OBJECT_ID('tempdb.dbo.#ROI_component_2b_standard_day_continuous', 'U') IS NOT NULL
    DROP TABLE #ROI_component_2b_standard_day_continuous;
SELECT	  cte.PromotionNumber,
		  cte.PromotionStartDate,
		  cte.PromotionEndDate,
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
		  CASE WHEN COUNT(valid_ind) = 28 THEN 0 ELSE 1 END AS 'Ind_less_28_baseline_days'
INTO		  #ROI_component_2b_standard_day_continuous
FROM		  #ROI_component_2a_baseline_days_continuous CTE
GROUP BY	  cte.PromotionNumber,
		  cte.PromotionStartDate,
		  cte.PromotionEndDate,
		  cte.ProductNumber,
		  cte.Branch_name_EN,
		  cte.SourceInd,
		  cte.avg_number_of_customers,
		  cte.avg_margin,
		  cte.avg_quantity,
		  cte.avg_revenue

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Standard day per promotion product calculated for continuous promotions with sufficient discount',
			SYSDATETIME()
		)

-- Standard day per promotion product selected into dbo.PG_ROI_component_2b_standard_day_update
TRUNCATE TABLE dbo.PG_ROI_component_2b_standard_day_update;
INSERT INTO dbo.PG_ROI_component_2b_standard_day_update
SELECT	  sd.*,
		  0 AS 'Continuous_promotion'
FROM		  #ROI_component_2b_standard_day sd
LEFT JOIN	  PG_ROI_component_2c_continuous_promotions_update cp
ON		  cp.PromotionNumber = sd.PromotionNumber
	   AND cp.PromotionStartDate = sd.PromotionStartDate
	   AND cp.PromotionEndDate = sd.PromotionEndDate
	   AND cp.ProductNumber = sd.ProductNumber
	   AND cp.Branch_name_EN = sd.Branch_name_EN
	   AND cp.SourceInd = sd.SourceInd
WHERE	  cp.PromotionNumber IS NULL
UNION
SELECT	  bd.*,
		  1
FROM		  #ROI_component_2b_standard_day_continuous bd

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Standard day per promotion product selected into table dbo.PG_ROI_component_2b_standard_day_update',
			SYSDATETIME()
		)

-- Moves standard day data to history
DELETE FROM PG_ROI_component_2b_standard_day
WHERE	  PromotionEndDate >= @start_date
INSERT INTO PG_ROI_component_2b_standard_day
SELECT	  *
FROM		  PG_ROI_component_2b_standard_day_update
WHERE	  PromotionEndDate >= @start_date

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Moved standard day data to history',
			SYSDATETIME()
		)

-- Calculates uncorrected baseline per day for promotion products
TRUNCATE TABLE dbo.PG_ROI_component_2d_daily_baseline_update;
WITH CTE AS
(SELECT	  cp.PromotionNumber,
		  cp.PromotionStartDate,
		  cp.PromotionEndDate,
		  cp.ProductNumber,
		  cp.Branch_name_EN,
		  cp.SourceInd,
		  cf.TransactionDate,
		  wd.correction_weekday*cf.correction_holiday*cf.correction_season AS 'correction_factor'
 FROM	  PG_promotions_update cp
 INNER JOIN PG_correction_factors cf
 ON		  cf.ProductNumber = cp.ProductNumber
	   AND cf.TransactionDate BETWEEN cp.PromotionStartDate AND cp.PromotionEndDate
 INNER JOIN dbo.PG_correction_weekday wd
 ON		wd.date = cf.TransactionDate
	 AND wd.Branch_name_EN = cp.Branch_name_EN
)
INSERT INTO dbo.PG_ROI_component_2d_daily_baseline_update
SELECT	  cte.PromotionNumber,
		  cte.PromotionStartDate,
		  cte.PromotionEndDate,
		  cte.ProductNumber,
		  cte.Branch_name_EN,
		  cte.SourceInd,
		  cte.TransactionDate,
		  sd.Baseline_days,
		  sd.Valid_baseline_days,
		  sd.Days_in_plan,
		  dt.Valid_ind AS 'Ind_head_promotion',
		  CASE WHEN cte.correction_factor = 0 THEN 0
			  ELSE dt.Valid_ind * sd.Baseline_customers / cte.correction_factor
		  END AS 'Baseline_customers',
		  CASE WHEN cte.correction_factor = 0 THEN 0
			  ELSE dt.Valid_ind * sd.Baseline_quantity / cte.correction_factor
		  END AS 'Baseline_quantity',
		  CASE WHEN cte.correction_factor = 0 THEN 0
			  ELSE -dt.Valid_ind * sd.Baseline_quantity / cte.correction_factor
		  END AS 'Quantity_2_subs_promo',
		  CASE WHEN cte.correction_factor = 0 THEN 0
			  ELSE -dt.Valid_ind * sd.Baseline_revenue / cte.correction_factor
		  END AS 'Revenue_2_subs_promo',
		  CASE WHEN cte.correction_factor = 0 THEN 0
			  ELSE -dt.Valid_ind * sd.Baseline_margin / cte.correction_factor
		  END AS 'Margin_2_subs_promo',
		  sd.Continuous_promotion AS 'Ind_continuous_promotion',
		  sd.Ind_less_28_baseline_days
FROM		  CTE cte
INNER JOIN  dbo.PG_ROI_component_2b_standard_day_update sd
ON		  sd.PromotionNumber = cte.PromotionNumber
	   AND sd.ProductNumber = cte.ProductNumber
	   AND sd.PromotionStartDate = cte.PromotionStartDate
	   AND sd.PromotionEndDate = cte.PromotionEndDate
	   AND sd.SourceInd = cte.SourceInd
	   AND sd.Branch_name_EN = cte.Branch_name_EN
INNER JOIN  dbo.PG_promotions_dates_update dt
ON		  dt.PromotionNumber = cte.PromotionNumber
	   AND dt.ProductNumber = cte.ProductNumber
	   AND dt.Branch_name_EN = cte.Branch_name_EN
	   AND dt.SourceInd = cte.SourceInd
	   AND dt.Date = cte.TransactionDate

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Uncorrected baseline per day for promotion products calculated',
			SYSDATETIME()
		)

-- Calculates uplift per promotion
TRUNCATE TABLE dbo.PG_ROI_component_2e_uplift_per_promotion_update;
INSERT INTO dbo.PG_ROI_component_2e_uplift_per_promotion_update
SELECT	  ro.PromotionNumber,
		  ro.PromotionStartDate,
		  ro.PromotionEndDate,
		  CASE WHEN SUM(ro.Real_quantity) = 0 OR SUM(db.Baseline_quantity) = 0 THEN NULL
			  ELSE SUM(ro.Real_quantity)/SUM(db.Baseline_quantity) END AS 'Uplift'
FROM		  dbo.PG_ROI_component_1 ro
INNER JOIN  dbo.PG_ROI_component_2d_daily_baseline_update db
ON		  ro.PromotionNumber = db.PromotionNumber
	   AND ro.PromotionStartDate = db.PromotionStartDate
	   AND ro.PromotionEndDate = db.PromotionEndDate
	   AND ro.ProductNumber = db.ProductNumber
	   AND ro.Branch_name_EN = db.Branch_name_EN
	   AND ro.TransactionDate = db.TransactionDate
	   AND ro.SourceInd = db.SourceInd
GROUP BY	  ro.PromotionNumber,
		  ro.PromotionStartDate,
		  ro.PromotionEndDate

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Uplift per promotion calculated',
			SYSDATETIME()
		)

-- Calculates substitution on promotion product
TRUNCATE TABLE dbo.PG_ROI_component_2_update;
INSERT INTO dbo.PG_ROI_component_2_update
SELECT	  db.PromotionNumber,
		  db.ProductNumber,
		  db.PromotionStartDate,
		  db.PromotionEndDate,
		  db.SourceInd,
		  db.Branch_name_EN,
		  db.TransactionDate,
		  db.Baseline_days,
		  db.Valid_baseline_days,
		  db.Days_in_plan AS 'Baseline_days_in_plan',
		  db.Ind_head_promotion,
		  db.Ind_continuous_promotion,
		  db.Ind_less_28_baseline_days,
		  CASE WHEN db.Ind_continuous_promotion = 1 THEN 1 ELSE NULL END AS 'Ind_sufficient_discount',
		  CASE WHEN pio.Ind_in_plan = 1
				AND (upp.Uplift <= @min_uplift OR upp.Uplift >= @max_Uplift) 
				AND db.Days_in_plan >= 14
				AND db.Ind_head_promotion = 1 THEN 1
			  ELSE 0 END AS 'Ind_uplift_flag',
		  -- Uplift is only cut of when the product is in plan
		  -- (and has been in plan for at least 2 weeks) and it is the most important promotion at that moment
		  CAST(CASE WHEN upp.Uplift <= @min_uplift AND pio.Ind_in_plan = 1 AND db.Days_in_plan >= 14 AND db.Ind_head_promotion = 1 THEN db.Baseline_customers*upp.Uplift/@min_uplift
		       WHEN upp.Uplift >= @max_uplift AND pio.Ind_in_plan = 1 AND db.Days_in_plan >= 14 AND db.Ind_head_promotion = 1 THEN db.Baseline_customers*upp.Uplift/@max_uplift
			  ELSE db.Baseline_customers END AS DECIMAL(15,2)) AS 'Baseline_customers',
		  CAST(CASE WHEN upp.Uplift <= @min_uplift AND pio.Ind_in_plan = 1 AND db.Days_in_plan >= 14 AND db.Ind_head_promotion = 1 THEN db.Baseline_quantity*upp.Uplift/@min_uplift
		       WHEN upp.Uplift >= @max_uplift AND pio.Ind_in_plan = 1 AND db.Days_in_plan >= 14 AND db.Ind_head_promotion = 1 THEN db.Baseline_quantity*upp.Uplift/@max_uplift
			  ELSE db.Baseline_quantity END AS DECIMAL(15,2)) AS 'Baseline_quantity',
		  CAST(CASE WHEN upp.Uplift <= @min_uplift AND pio.Ind_in_plan = 1 AND db.Days_in_plan >= 14 AND db.Ind_head_promotion = 1 THEN db.Quantity_2_subs_promo*upp.Uplift/@min_uplift
		       WHEN upp.Uplift >= @max_uplift AND pio.Ind_in_plan = 1 AND db.Days_in_plan >= 14 AND db.Ind_head_promotion = 1 THEN db.Quantity_2_subs_promo*upp.Uplift/@max_uplift
			  ELSE db.Quantity_2_subs_promo END AS DECIMAL(15,2)) AS 'Quantity_2_subs_promo',
		  CAST(CASE WHEN upp.Uplift <= @min_uplift AND pio.Ind_in_plan = 1 AND db.Days_in_plan >= 14 AND db.Ind_head_promotion = 1 THEN db.Revenue_2_subs_promo*upp.Uplift/@min_uplift
		       WHEN upp.Uplift >= @max_uplift AND pio.Ind_in_plan = 1 AND db.Days_in_plan >= 14 AND db.Ind_head_promotion = 1 THEN db.Revenue_2_subs_promo*upp.Uplift/@max_uplift
			  ELSE db.Revenue_2_subs_promo END AS DECIMAL(15,2)) AS 'Revenue_2_subs_promo',
		  CAST(CASE WHEN upp.Uplift <= @min_uplift AND pio.Ind_in_plan = 1 AND db.Days_in_plan >= 14 AND db.Ind_head_promotion = 1 THEN db.Margin_2_subs_promo*upp.Uplift/@min_uplift
		       WHEN upp.Uplift >= @max_uplift AND pio.Ind_in_plan = 1 AND db.Days_in_plan >= 14 AND db.Ind_head_promotion = 1 THEN db.Margin_2_subs_promo*upp.Uplift/@max_uplift
			  ELSE db.Margin_2_subs_promo END AS DECIMAL(15,2)) AS 'Margin_2_subs_promo'
FROM		  dbo.PG_ROI_component_2d_daily_baseline_update db
INNER JOIN  dbo.PG_ROI_component_2e_uplift_per_promotion_update upp
ON		  db.PromotionNumber = upp.PromotionNumber
	   AND db.PromotionStartDate = upp.PromotionStartDate
	   AND db.PromotionEndDate = upp.PromotionEndDate
INNER JOIN  PG_dim_date dt
ON		  dt.date = db.TransactionDate
INNER JOIN  PG_product_in_out_indicators pio
ON		  pio.yearweek = dt.yearweek
	   AND pio.ProductNumber = db.ProductNumber
	   AND pio.Branch_name_EN = db.Branch_name_EN
UNION
SELECT	  cp.PromotionNumber,
	       cp.ProductNumber,
		  cp.PromotionStartDate,
		  cp.PromotionEndDate,
		  cp.SourceInd,
		  cp.Branch_name_EN,
		  ro.TransactionDate,
		  NULL AS 'Baseline_days',
		  NULL AS 'Valid_baseline_days',
		  NULL AS 'Baseline_days_in_plan',
		  ro.Ind_head_promotion,
		  1 AS 'Ind_continuous_promotion',
		  1 AS 'Ind_less_28_baseline_days',
		  cp.Ind_sufficient_discount,
		  0 AS 'Ind_uplift_flag',
		  ro.Number_of_customers,
		  ro.Real_quantity,
		  -ro.Quantity_1_promotion,
		  -ro.Revenue_1_promotion,
		  -ro.Margin_1_promotion
FROM		  dbo.PG_ROI_component_2c_continuous_promotions_update cp
INNER JOIN  PG_ROI_component_1 ro
ON		  ro.PromotionNumber = cp.PromotionNumber
	   AND ro.PromotionStartDate = cp.PromotionStartDate
	   AND ro.PromotionEndDate = cp.PromotionEndDate
	   AND ro.ProductNumber = cp.ProductNumber
	   AND ro.Branch_name_EN = cp.Branch_name_EN
	   AND ro.SourceInd = cp.SourceInd
WHERE	  cp.Ind_sufficient_discount = 0

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'ROI component 2 calculated',
			SYSDATETIME()
		)

-- Move ROI component 2 data to history
DELETE FROM PG_ROI_component_2
WHERE	  PromotionEndDate >= @start_date
INSERT INTO PG_ROI_component_2
SELECT	  *
FROM		  PG_ROI_component_2_update
WHERE	  PromotionEndDate >= @start_date


SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'End of [update_7c_ROI_promotions_component_2]',
			SYSDATETIME()
		)
drop table #ROI_component_2a_baseline_days
END
