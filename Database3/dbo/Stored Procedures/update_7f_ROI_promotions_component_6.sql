
-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-18
-- Description:	Script for component 6 of ROI for weekly and monthly promotions
-- =============================================
CREATE PROCEDURE [dbo].[update_7f_ROI_promotions_component_6]
	@run_nr INT = 1,
	@run_date DATE = '2017-10-18',
	@step INT = 6000,
	@start_date DATE = '2017-07-01',
	@end_date DATE = '2017-09-30',
	@after_days INT = 28
AS
BEGIN

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Start of [update_7f_ROI_promotions_component_6]',
			SYSDATETIME()
		)

-- Calculates new customer multipliers per promotion
TRUNCATE TABLE dbo.PG_ROI_component_6a_new_customer_multipliers_update;
INSERT INTO dbo.PG_ROI_component_6a_new_customer_multipliers_update
SELECT	  cu.PromotionNumber,
		  cu.PromotionStartDate,
		  cu.PromotionEndDate,
		  cu.TransactionDate,
		  cu.Branch_name_EN,
		  SUM(cu.New_loyalty_customers) AS 'new_loyalty_customers',
		  SUM(ro.Baseline_customers) AS 'baseline_customers',
		  SUM(ro.Baseline_customers)*nc.N_new13weeks/nc.N_distinct_customers AS 'baseline_new_customers',
		  SUM(cu.New_loyalty_customers)-SUM(ro.Baseline_customers)*nc.N_new13weeks/nc.N_distinct_customers AS 'extra_new_customers',
		  CASE WHEN SUM(cu.New_loyalty_customers)-SUM(ro.Baseline_customers)*nc.N_new13weeks/nc.N_distinct_customers > 0 THEN 1 ELSE 0 END AS 'new_traffic_generator_ind',
		  CASE WHEN SUM(cu.New_loyalty_customers) = 0 THEN 0 ELSE
			 (CASE WHEN SUM(cu.New_loyalty_customers)-SUM(ro.Baseline_customers)*nc.N_new13weeks/nc.N_distinct_customers > 0 THEN SUM(cu.New_loyalty_customers)-SUM(ro.Baseline_customers)*nc.N_new13weeks/nc.N_distinct_customers ELSE 0 END
			  /SUM(cu.New_loyalty_customers)) END AS 'new_customers_multiplier'
FROM		  PG_ROI_component_4c_customer_totals cu
INNER JOIN  PG_ROI_component_2 ro
ON		  ro.PromotionNumber = cu.PromotionNumber
	   AND ro.PromotionStartDate = cu.PromotionStartDate
	   AND ro.PromotionEndDate = cu.PromotionEndDate
	   AND ro.TransactionDate = cu.TransactionDate
	   AND ro.Branch_name_EN = cu.Branch_name_EN
	   AND ro.Ind_head_promotion = 1
	   AND (ro.Ind_continuous_promotion = 0 OR ro.Ind_sufficient_discount = 1) --Continuous promotions with insufficient discount do not attract new customers
	   AND ro.PromotionEndDate >= DATEADD(day,-28,@start_date)
INNER JOIN  PG_new_customers_percentage nc
ON		  nc.Branch_name_EN = cu.Branch_name_EN
	   AND nc.Transactiondate = cu.TransactionDate
GROUP BY	  cu.PromotionNumber,
		  cu.PromotionStartDate,
		  cu.PromotionEndDate,
		  cu.TransactionDate,
		  cu.Branch_name_EN,
		  nc.N_new13weeks,
		  nc.N_distinct_customers

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'New customer multipliers per promotion calculated',
			SYSDATETIME()
		)

-- Move data to history
DELETE FROM dbo.PG_ROI_component_6a_new_customer_multipliers
WHERE		PromotionEndDate >= DATEADD(day,-28,@start_date)
INSERT INTO dbo.PG_ROI_component_6a_new_customer_multipliers
SELECT		*
FROM		dbo.PG_ROI_component_6a_new_customer_multipliers_update

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Moved data to history',
			SYSDATETIME()
		)

-- Calculates sales in 4 weeks after promotion for really new customers (not being promotion customers in the next weeks)
TRUNCATE TABLE dbo.PG_ROI_component_6b_new_customer_sales_update;
INSERT INTO dbo.PG_ROI_component_6b_new_customer_sales_update
SELECT	  cu.HouseholdID,
		  cu.TransactionDate,
		  cu.PromotionNumber,
		  cu.PromotionStartDate,
		  cu.PromotionEndDate,
		  cu.ProductNumber,
		  cu.Branch_name_EN,
		  cu.SourceInd,
		  cu.Revenue,
		  SUM(cu.Revenue) OVER(PARTITION BY cu.HouseholdID, cu.TransactionDate, cu.Branch_name_EN, cu.SourceInd) AS 'new_traffic_generating_sales',
		  SUM(ci.Promo_quantity_at_date) AS 'Promo_after_quantity',
		  SUM(ci.Non_promo_quantity_at_date) AS 'Non_promo_quantity',
		  SUM(ci.Promo_revenue_at_date) AS 'Promo_after_revenue',
		  SUM(ci.Non_promo_revenue_at_date) AS 'Non_promo_revenue',
		  SUM(ci.Promo_margin_at_date) AS 'Promo_after_margin',
		  SUM(ci.Non_promo_margin_at_date) AS 'Non_promo_margin'
FROM		  PG_ROI_component_4b_customers_of_promotion cu
INNER JOIN  PG_ROI_component_6a_new_customer_multipliers nc
ON		  nc.PromotionNumber = cu.PromotionNumber
	   AND nc.PromotionStartDate = cu.PromotionStartDate
	   AND nc.PromotionEndDate = cu.PromotionEndDate
	   AND nc.TransactionDate = cu.TransactionDate
	   AND nc.Branch_name_EN = cu.Branch_name_EN
	   AND nc.new_traffic_generator_ind = 1
INNER JOIN  PG_customer_information_table ci
ON		  ci.HouseholdID = cu.HouseholdID
	   AND ci.TransactionDate BETWEEN DATEADD(day,0,cu.TransactionDate) AND DATEADD(day,@after_days,cu.TransactionDate)
	   AND ci.promo_ind = 0 -- To prevent double counting for existing promotion customers at that moment (on the day and the four weeks after)
WHERE	  cu.new_customer_ind = 1
		AND cu.TransactionDate >= DATEADD(day,-28,@start_date)
GROUP BY	  cu.HouseholdID,
		  cu.TransactionDate,
		  cu.PromotionNumber,
		  cu.PromotionStartDate,
		  cu.PromotionEndDate,
		  cu.ProductNumber,
		  cu.Branch_name_EN,
		  cu.SourceInd,
		  cu.Revenue

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Sales in 4 weeks after promotion calculated for new customers',
			SYSDATETIME()
		)

-- Calculates new customer effects per promotion
TRUNCATE TABLE PG_ROI_component_6_update;
INSERT INTO dbo.PG_ROI_component_6_update
SELECT	  cu.TransactionDate,
		  cu.PromotionNumber,
		  cu.PromotionStartDate,
		  cu.PromotionEndDate,
		  cu.ProductNumber,
		  cu.Branch_name_EN,
		  cu.SourceInd,
		  lp.loyalty_perc_quantity*nc.new_customers_multiplier*SUM(CASE WHEN cu.New_traffic_generating_sales <> 0 THEN cu.Revenue/cu.New_traffic_generating_sales*cu.Non_promo_quantity ELSE 0 END) AS 'Quantity_6_new_customer',
		  lp.loyalty_perc_quantity*nc.new_customers_multiplier*SUM(CASE WHEN cu.New_traffic_generating_sales <> 0 THEN cu.Revenue/cu.New_traffic_generating_sales*cu.Non_promo_revenue ELSE 0 END) AS 'Revenue_6_new_customer',
		  lp.loyalty_perc_quantity*nc.new_customers_multiplier*SUM(CASE WHEN cu.New_traffic_generating_sales <> 0 THEN cu.Revenue/cu.New_traffic_generating_sales*cu.Non_promo_margin ELSE 0 END) AS 'Margin_6_new_customer'
FROM		  PG_ROI_component_6b_new_customer_sales_update cu
INNER JOIN  PG_ROI_component_6a_new_customer_multipliers_update nc
ON		  nc.TransactionDate = cu.TransactionDate
	   AND nc.PromotionNumber = cu.PromotionNumber
	   AND nc.PromotionStartDate = cu.PromotionStartDate
	   AND nc.PromotionEndDate = cu.PromotionEndDate
	   AND nc.Branch_name_EN = cu.Branch_name_EN
	   AND nc.new_traffic_generator_ind = 1
INNER JOIN  PG_ROI_component_4a_loyalty_perc lp
ON		  cu.TransactionDate = lp.TransactionDate
	   AND cu.ProductNumber = lp.ProductNumber
	   AND cu.SourceInd = lp.SourceInd
	   AND cu.Branch_name_EN = lp.Branch_name_EN
	   AND cu.PromotionNumber = lp.PromotionNumber
	   AND cu.PromotionStartDate = lp.PromotionStartDate
	   AND cu.PromotionEndDate = lp.PromotionEndDate
GROUP BY	  cu.TransactionDate,
		  cu.PromotionNumber,
		  cu.PromotionStartDate,
		  cu.PromotionEndDate,
		  cu.ProductNumber,
		  cu.Branch_name_EN,
		  cu.SourceInd,
		  lp.loyalty_perc_quantity,
		  nc.new_customers_multiplier

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'New customer effects calculated',
			SYSDATETIME()
		)

-- Move data for ROI component 6 to history
DELETE FROM PG_ROI_component_6
WHERE	  PromotionEndDate >= DATEADD(day,-28,@start_date)
INSERT INTO PG_ROI_component_6
SELECT	  *
FROM		  PG_ROI_component_6_update
WHERE	  PromotionEndDate >= DATEADD(day,-28,@start_date)

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'End of [update_7f_ROI_promotions_component_6]',
			SYSDATETIME()
		)

END


