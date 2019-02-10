
-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-18
-- Description:	Script for component 8 of ROI for weekly and monthly promotions
-- =============================================
CREATE PROCEDURE [dbo].[update_7h_ROI_promotions_component_8]
	@run_nr INT = 1,
	@run_date DATE = '2017-10-18',
	@step INT = 1,
	@start_date DATE = '2015-01-01',
	@end_date DATE = '2017-06-30',
	@after_days INT = 28
AS
BEGIN

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Start of [update_7h_ROI_promotions_component_8]',
			SYSDATETIME()
		)

-- Calculates daily realization for the weeks after the promotion (taking into account other promotions that are more recent)
TRUNCATE TABLE PG_ROI_component_8a_hoarding_realization_update;
INSERT INTO PG_ROI_component_8a_hoarding_realization_update
SELECT	  cp.PromotionNumber,
		  cp.ProductNumber,
		  cp.PromotionStartDate,
		  cp.PromotionEndDate,
		  cp.SourceInd,
		  cp.Branch_name_EN,
		  at.TransactionDate,
		  at.Quantity,
		  at.Revenue,
		  at.Margin
FROM		  PG_promotions_update cp
INNER JOIN  PG_sales_per_product_per_day_wo_returns at
ON		  cp.ProductNumber = at.ProductNumber
	   AND cp.Branch_name_EN = at.Branch_name_EN
	   AND cp.SourceInd = at.SourceInd
	   AND at.TransactionDate BETWEEN DATEADD(day,1,cp.PromotionEndDate) AND DATEADD(day,@after_days,cp.PromotionEndDate)
INNER JOIN  PG_ROI_component_7a_promo_product_ind_accum_update ppi
ON		  ppi.Branch_name_EN = at.Branch_name_EN
	   AND ppi.SourceInd = at.SourceInd
	   AND ppi.PromotionStartDate = cp.PromotionStartDate
	   AND ppi.PromotionNumber = cp.PromotionNumber
	   AND ppi.PromotionEndDate = cp.PromotionEndDate
	   AND ppi.ProductNumber = at.ProductNumber
	   AND ppi.TransactionDate = at.TransactionDate
	   AND ppi.Promo_accum_ind = 0

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Daily realization for the weeks after the promotion calculated',
			SYSDATETIME()
		)

-- Calculates daily baseline vs. realization for the weeks after the promotion
TRUNCATE TABLE PG_ROI_component_8b_hoarding_effect_update;
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
	   AND cf.TransactionDate BETWEEN DATEADD(day,1,cp.PromotionEndDate) AND DATEADD(day,@after_days,cp.PromotionEndDate)
 INNER JOIN PG_correction_weekday wd
 ON		  wd.date = cf.TransactionDate
	   AND wd.Branch_name_EN = cp.Branch_name_EN
	   AND wd.correction_weekday <> 0
)
INSERT INTO dbo.PG_ROI_component_8b_hoarding_effect_update
SELECT	  cte.PromotionNumber,
		  cte.PromotionStartDate,
		  cte.PromotionEndDate,
		  cte.ProductNumber,
		  cte.Branch_name_EN,
		  cte.SourceInd,
		  sd.Baseline_days,
		  SUM(sd.Baseline_quantity / cte.correction_factor) AS 'Baseline_quantity',
		  SUM(ISNULL(hr.Quantity,0) - sd.Baseline_quantity / cte.correction_factor) AS 'Delta_quantity', --##
		  SUM(ISNULL(hr.Revenue,0) - sd.Baseline_revenue / cte.correction_factor) AS 'Delta_revenue', --##
		  SUM(ISNULL(hr.Margin,0) - sd.Baseline_margin / cte.correction_factor) AS 'Delta_margin' --##
FROM		  CTE cte
INNER JOIN  PG_ROI_component_2b_standard_day sd
ON		  sd.PromotionNumber = cte.PromotionNumber
	   AND sd.ProductNumber = cte.ProductNumber
	   AND sd.PromotionStartDate = cte.PromotionStartDate
	   AND sd.PromotionEndDate = cte.PromotionEndDate
	   AND sd.SourceInd = cte.SourceInd
	   AND sd.Branch_name_EN = cte.Branch_name_EN
INNER JOIN  PG_ROI_component_7a_promo_product_ind_accum_update ppi
ON		  ppi.Branch_name_EN = cte.Branch_name_EN
	   AND ppi.SourceInd = cte.SourceInd
	   AND ppi.PromotionStartDate = cte.PromotionStartDate
	   AND ppi.PromotionNumber = cte.PromotionNumber
	   AND ppi.PromotionEndDate = cte.PromotionEndDate
	   AND ppi.ProductNumber = cte.ProductNumber
	   AND ppi.TransactionDate = cte.TransactionDate
	   AND ppi.Promo_accum_ind = 0
LEFT JOIN   PG_ROI_component_8a_hoarding_realization_update hr
ON		  hr.PromotionNumber = cte.PromotionNumber
	   AND hr.ProductNumber = cte.ProductNumber
	   AND hr.PromotionStartDate = cte.PromotionStartDate
	   AND hr.PromotionEndDate = cte.PromotionEndDate
	   AND hr.SourceInd = cte.SourceInd
	   AND hr.Branch_name_EN = cte.Branch_name_EN
	   AND hr.TransactionDate = cte.TransactionDate
GROUP BY	  cte.PromotionNumber,
		  cte.PromotionStartDate,
		  cte.PromotionEndDate,
		  cte.ProductNumber,
		  cte.Branch_name_EN,
		  cte.SourceInd,
		  sd.Baseline_days

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Daily baseline vs. realization for the weeks after the promotion calculated',
			SYSDATETIME()
		)

-- Calculate hoarding effect per day by dividing it over the days of the promotion based on the revenue per day and substracting the product adoption effect, as these customers can cause positive hoarding
TRUNCATE TABLE PG_ROI_component_8_update;
;WITH CTE AS
(SELECT	  re.PromotionNumber,
		  re.ProductNumber,
		  re.PromotionStartDate,
		  re.PromotionEndDate,
		  re.SourceInd,
		  re.Branch_name_EN,
		  re.TransactionDate,
		  CASE WHEN (SUM(re.Revenue_1_promotion) OVER(PARTITION BY re.PromotionNumber, re.ProductNumber, re.PromotionStartDate, re.PromotionEndDate, re.SourceInd, re.Branch_name_EN)) = 0 THEN 0
			  ELSE re.Revenue_1_promotion / (SUM(re.Revenue_1_promotion) OVER(PARTITION BY re.PromotionNumber, re.ProductNumber, re.PromotionStartDate, re.PromotionEndDate, re.SourceInd, re.Branch_name_EN))
			  END AS 'Perc_revenue'
 FROM	  PG_ROI_component_1 re
 WHERE	  re.PromotionEndDate >= DATEADD(day,-28,@start_date)
)
INSERT INTO dbo.PG_ROI_component_8_update
SELECT	  cte.PromotionNumber,
		  cte.ProductNumber,
		  cte.PromotionStartDate,
		  cte.PromotionEndDate,
		  cte.SourceInd,
		  cte.Branch_name_EN,
		  cte.TransactionDate,
		  cte.Perc_revenue*he.Delta_quantity - ISNULL(ro.Quantity_7_product_adoption,0) AS 'Quantity_8_hoarding',
		  CASE WHEN cte.Perc_revenue*he.Delta_revenue - ISNULL(ro.Revenue_7_product_adoption,0) > 0 THEN 0
			  WHEN cte.Perc_revenue*he.Delta_revenue - ISNULL(ro.Revenue_7_product_adoption,0) < -ro1.Revenue_1_promotion THEN -ro1.Revenue_1_promotion
			  ELSE cte.Perc_revenue*he.Delta_revenue - ISNULL(ro.Revenue_7_product_adoption,0) END AS 'Revenue_8_hoarding',
		  CASE WHEN cte.Perc_revenue*he.Delta_revenue - ISNULL(ro.Revenue_7_product_adoption,0) > 0 THEN 0
			  WHEN cte.Perc_revenue*he.Delta_revenue - ISNULL(ro.Revenue_7_product_adoption,0) < -ro1.Revenue_1_promotion THEN -ro1.Margin_1_promotion
			  ELSE cte.Perc_revenue*he.Delta_margin - ISNULL(ro.Margin_7_product_adoption,0) END AS 'Margin_8_hoarding'
FROM		  CTE cte
INNER JOIN  PG_ROI_component_8b_hoarding_effect_update he
ON		  he.PromotionNumber = cte.PromotionNumber
	   AND he.ProductNumber = cte.ProductNumber
	   AND he.PromotionStartDate = cte.PromotionStartDate
	   AND he.PromotionEndDate = cte.PromotionEndDate
	   AND he.SourceInd = cte.SourceInd
	   AND he.Branch_name_EN = cte.Branch_name_EN
LEFT JOIN	  PG_ROI_component_7_update ro
ON		  ro.PromotionNumber = cte.PromotionNumber
	   AND ro.ProductNumber = cte.ProductNumber
	   AND ro.PromotionStartDate = cte.PromotionStartDate
	   AND ro.PromotionEndDate = cte.PromotionEndDate
	   AND ro.SourceInd = cte.SourceInd
	   AND ro.Branch_name_EN = cte.Branch_name_EN
	   AND ro.TransactionDate = cte.TransactionDate
INNER JOIN  PG_ROI_component_1 ro1
ON		  ro1.PromotionNumber = cte.PromotionNumber
	   AND ro1.ProductNumber = cte.ProductNumber
	   AND ro1.PromotionStartDate = cte.PromotionStartDate
	   AND ro1.PromotionEndDate = cte.PromotionEndDate
	   AND ro1.SourceInd = cte.SourceInd
	   AND ro1.Branch_name_EN = cte.Branch_name_EN
	   AND ro1.TransactionDate = cte.TransactionDate

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Hoarding effects calculated',
			SYSDATETIME()
		)

-- Move data for ROI component 6 to history
DELETE FROM PG_ROI_component_8
WHERE	  PromotionEndDate >= DATEADD(day,-28,@start_date)
INSERT INTO PG_ROI_component_8
SELECT	  *
FROM		  PG_ROI_component_8_update

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'End of [update_7h_ROI_promotions_component_8]',
			SYSDATETIME()
		)

END

