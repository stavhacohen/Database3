-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-18
-- Description:	Script for components 4 and 5 of ROI for weekly and monthly promotions
-- =============================================
CREATE PROCEDURE [dbo].[update_7e_ROI_promotions_components_4_5]
	@run_nr INT = 23,
	@run_date DATE = '2018-05-25',
	@step INT = 1,
	@start_date DATE = '2018-05-08',
	@end_date DATE = '2018-05-14'

AS
BEGIN

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Start of [update_7e_ROI_promotions_components_4_5]',
			SYSDATETIME()
		)

-- Calculates what percentage of customers is recognizable in the loyalty club
TRUNCATE TABLE dbo.PG_ROI_component_4a_loyalty_perc_update;
INSERT INTO dbo.PG_ROI_component_4a_loyalty_perc_update
SELECT	  cp.TransactionDate,
		  cp.ProductNumber,
		  cp.SourceInd,
		  cp.Branch_name_EN,
		  ro.PromotionNumber,
		  ro.PromotionStartDate,
		  ro.PromotionEndDate,
		  CASE WHEN SUM(cp.Quantity) = 0 OR SUM(cp.Quantity) > ro.Quantity_1_promotion THEN 1
		       ELSE ro.Quantity_1_promotion / SUM(cp.Quantity) END AS 'loyalty_perc_quantity'
FROM		  PG_transactions_promotions cp
INNER JOIN  PG_ROI_component_1_update ro
ON		  ro.TransactionDate = cp.TransactionDate
	   AND ro.ProductNumber = cp.ProductNumber
	   AND ro.SourceInd = cp.SourceInd
	   AND ro.Branch_name_EN = cp.Branch_name_EN
	   AND ro.Ind_head_promotion = 1
GROUP BY	  cp.TransactionDate,
		  cp.ProductNumber,
		  cp.SourceInd,
		  cp.Branch_name_EN,
		  ro.PromotionNumber,
		  ro.PromotionStartDate,
		  ro.PromotionEndDate,
		  ro.Quantity_1_promotion,
		  ro.Revenue_1_promotion,
		  ro.Margin_1_promotion


SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Loyalty customer percentage per promotion calculated',
			SYSDATETIME()
		)

-- Indicates customer type (new/promotion) for these promotions
TRUNCATE TABLE dbo.PG_ROI_component_4b_customers_of_promotion_update;
INSERT INTO dbo.PG_ROI_component_4b_customers_of_promotion_update
SELECT	  cp.HouseholdID,
		  cp.TransactionDate,
		  cp.ProductNumber,
		  cp.SourceInd,
		  cp.Branch_name_EN,
		  ro.PromotionNumber,
		  ro.PromotionStartDate,
		  ro.PromotionEndDate,
		  ci.new_promo_customer_ind,
		  ci.new_customer_ind,
		  ci.promo_ind,
		  ci.Promo_quantity_at_date,
		  ci.Non_promo_quantity_at_date,
		  ci.Promo_revenue_at_date,
		  ci.Non_promo_revenue_at_date,
		  ci.Promo_margin_at_date,
		  ci.Non_promo_margin_at_date,
		  cp.Revenue,
		  SUM(cp.Revenue) OVER(PARTITION BY cp.HouseholdID, cp.TransactionDate, cp.Branch_name_EN, cp.SourceInd) AS 'Traffic_generating_sales'
FROM		  PG_transactions_promotions cp
INNER JOIN  PG_ROI_component_1_update ro
ON		  ro.TransactionDate = cp.TransactionDate
	   AND ro.ProductNumber = cp.ProductNumber
	   AND ro.SourceInd = cp.SourceInd
	   AND ro.Branch_name_EN = cp.Branch_name_EN
	   AND ro.Ind_head_promotion = 1
INNER JOIN  PG_customer_information_table ci
ON		  cp.HouseholdID = ci.HouseholdID
	 AND	  cp.TransactionDate = ci.TransactionDate

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Customer types assigned per customer of the promotion',
			SYSDATETIME()
		)

-- Calculates promotion customer effects per promotion (existing and new)
TRUNCATE TABLE dbo.PG_ROI_component_4_5_update;
INSERT INTO dbo.PG_ROI_component_4_5_update
SELECT	  cp.TransactionDate,
		  cp.ProductNumber,
		  cp.SourceInd,
		  cp.Branch_name_EN,
		  cp.PromotionNumber,
		  cp.PromotionStartDate,
		  cp.PromotionEndDate,
		  lp.loyalty_perc_quantity*SUM(CASE WHEN cp.new_promo_customer_ind <> 0 OR cp.Traffic_generating_sales = 0 THEN 0 ELSE cp.Revenue/cp.Traffic_generating_sales*cp.Non_promo_quantity_at_date END) AS 'Quantity_4_promobuyer_existing',
		  lp.loyalty_perc_quantity*SUM(CASE WHEN cp.new_promo_customer_ind <> 1 OR cp.Traffic_generating_sales = 0 THEN 0 ELSE cp.Revenue/cp.Traffic_generating_sales*cp.Non_promo_quantity_at_date END) AS 'Quantity_5_promobuyer_new',
		  lp.loyalty_perc_quantity*SUM(CASE WHEN cp.new_promo_customer_ind <> 0 OR cp.Traffic_generating_sales = 0 THEN 0 ELSE cp.Revenue/cp.Traffic_generating_sales*cp.Non_promo_revenue_at_date END) AS 'Revenue_4_promobuyer_existing',
		  lp.loyalty_perc_quantity*SUM(CASE WHEN cp.new_promo_customer_ind <> 1 OR cp.Traffic_generating_sales = 0 THEN 0 ELSE cp.Revenue/cp.Traffic_generating_sales*cp.Non_promo_revenue_at_date END) AS 'Revenue_5_promobuyer_new',
		  lp.loyalty_perc_quantity*SUM(CASE WHEN cp.new_promo_customer_ind <> 0 OR cp.Traffic_generating_sales = 0 THEN 0 ELSE cp.Revenue/cp.Traffic_generating_sales*cp.Non_promo_margin_at_date END) AS 'Margin_4_promobuyer_existing',
		  lp.loyalty_perc_quantity*SUM(CASE WHEN cp.new_promo_customer_ind <> 1 OR cp.Traffic_generating_sales = 0 THEN 0 ELSE cp.Revenue/cp.Traffic_generating_sales*cp.Non_promo_margin_at_date END) AS 'Margin_5_promobuyer_new'
FROM		  PG_ROI_component_4b_customers_of_promotion_update cp
INNER JOIN  PG_ROI_component_4a_loyalty_perc_update lp
ON		  cp.TransactionDate = lp.TransactionDate
	   AND cp.ProductNumber = lp.ProductNumber
	   AND cp.SourceInd = lp.SourceInd
	   AND cp.Branch_name_EN = lp.Branch_name_EN
	   AND cp.PromotionNumber = lp.PromotionNumber
	   AND cp.PromotionStartDate = lp.PromotionStartDate
	   AND cp.PromotionEndDate = lp.PromotionEndDate
WHERE	  cp.promo_ind = 1
GROUP BY	  cp.TransactionDate,
		  cp.ProductNumber,
		  cp.SourceInd,
		  cp.Branch_name_EN,
		  cp.PromotionNumber,
		  cp.PromotionStartDate,
		  cp.PromotionEndDate,
		  lp.loyalty_perc_quantity

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Promotion customer effects per promotion calculated',
			SYSDATETIME()
		)

--!!! Fix om floats af te kappen
UPDATE PG_ROI_component_4_5_update
SET Quantity_4_promobuyer_existing = 0, Revenue_4_promobuyer_existing = 0, Margin_4_promobuyer_existing = 0
WHERE ABS(Revenue_4_promobuyer_existing) > 1000000 OR ABS(Margin_4_promobuyer_existing) > 1000000 

-- Calculates number of promotion buyers (existing and new) per promotion per day
TRUNCATE TABLE dbo.PG_ROI_component_4c_customer_totals_update;
WITH CTE AS
(SELECT	  PromotionNumber,
		  PromotionStartDate,
		  PromotionEndDate,
		  ProductNumber,
		  TransactionDate,
		  HouseholdID,
		  Branch_name_EN,
		  SourceInd,
		  (CASE WHEN SUM(CASE WHEN promo_ind = 1 THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END)
			 * (CASE WHEN SUM(CASE WHEN new_promo_customer_ind = 1 THEN 1 ELSE 0 END) > 0 THEN 0 ELSE 1 END) AS 'Existing_promotion_customer',
		  (CASE WHEN SUM(CASE WHEN promo_ind = 1 THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END)
			 * (CASE WHEN SUM(CASE WHEN new_promo_customer_ind = 1 THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END) AS 'New_promotion_customer',
		  CASE WHEN SUM(CASE WHEN new_customer_ind = 1 THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'New_customer'
 FROM	  PG_ROI_component_4b_customers_of_promotion_update
 GROUP BY	  PromotionNumber,
		  PromotionStartDate,
		  PromotionEndDate,
		  ProductNumber,
		  TransactionDate,
		  HouseholdID,
		  Branch_name_EN,
		  SourceInd
)
INSERT INTO dbo.PG_ROI_component_4c_customer_totals_update
SELECT	  cp.PromotionNumber,
		  cp.PromotionStartDate,
		  cp.PromotionEndDate,
		  cp.ProductNumber,
		  cp.TransactionDate,
		  cp.Branch_name_EN,
		  cp.SourceInd,
		  COUNT(cp.HouseholdID) AS 'Number_loyalty_customers',
		  SUM(cp.New_customer) AS 'New_loyalty_customers',
		  lp.loyalty_perc_quantity*COUNT(cp.HouseholdID) AS 'Number_customers',
		  lp.loyalty_perc_quantity*SUM(cp.Existing_promotion_customer) AS 'Existing_promotion_customers',
		  lp.loyalty_perc_quantity*SUM(cp.New_promotion_customer) AS 'New_promotion_customers',
		  lp.loyalty_perc_quantity*SUM(cp.New_customer) AS 'New_customers'
FROM		  CTE cp
INNER JOIN  PG_ROI_component_4a_loyalty_perc_update lp
ON		  cp.TransactionDate = lp.TransactionDate
	   AND cp.ProductNumber = lp.ProductNumber
	   AND cp.SourceInd = lp.SourceInd
	   AND cp.Branch_name_EN = lp.Branch_name_EN
	   AND cp.PromotionNumber = lp.PromotionNumber
	   AND cp.PromotionStartDate = lp.PromotionStartDate
	   AND cp.PromotionEndDate = lp.PromotionEndDate
GROUP BY	  cp.PromotionNumber,
		  cp.PromotionStartDate,
		  cp.PromotionEndDate,
		  cp.ProductNumber,
		  cp.TransactionDate,
		  cp.Branch_name_EN,
		  cp.SourceInd,
		  lp.loyalty_perc_quantity

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Customer information calculated',
			SYSDATETIME()
		)

-- Move ROI component 4 and 5 data to history
DELETE FROM PG_ROI_component_4_5
WHERE	  TransactionDate BETWEEN @start_date AND @end_date
INSERT INTO PG_ROI_component_4_5
SELECT	  *
FROM		  PG_ROI_component_4_5_update
WHERE	  TransactionDate BETWEEN @start_date AND @end_date

-- Move data from tables in between to history
DELETE FROM PG_ROI_component_4a_loyalty_perc
WHERE	  TransactionDate BETWEEN @start_date AND @end_date
INSERT INTO PG_ROI_component_4a_loyalty_perc
SELECT	  *
FROM		  PG_ROI_component_4a_loyalty_perc_update
-- added based on compponent 1 script to avid duplicate 
WHERE	  TransactionDate BETWEEN @start_date AND @end_date

DELETE FROM PG_ROI_component_4b_customers_of_promotion
WHERE	  TransactionDate BETWEEN @start_date AND @end_date
INSERT INTO PG_ROI_component_4b_customers_of_promotion
SELECT	  *
FROM		  PG_ROI_component_4b_customers_of_promotion_update
-- added based on compponent 1 script to avid duplicate 
WHERE	  TransactionDate BETWEEN @start_date AND @end_date

DELETE FROM PG_ROI_component_4c_customer_totals
WHERE	  TransactionDate BETWEEN @start_date AND @end_date
INSERT INTO PG_ROI_component_4c_customer_totals
SELECT	  *
FROM		  PG_ROI_component_4c_customer_totals_update
-- added based on compponent 1 script to avid duplicate 
WHERE	  TransactionDate BETWEEN @start_date AND @end_date

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'End of [update_7e_ROI_promotions_components_4_5]',
			SYSDATETIME()
		)

END
