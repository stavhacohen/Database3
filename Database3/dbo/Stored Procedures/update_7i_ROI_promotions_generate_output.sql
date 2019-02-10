-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-19
-- Description:	Generates output tables for promotions
-- =============================================
CREATE PROCEDURE [dbo].[update_7i_ROI_promotions_generate_output]
	@run_nr INT = 177,
	@run_date DATE = '2018-12-09',
	@step INT = 1,
	@start_date DATE = '2018-09-16',
	@end_date DATE = '2018-09-30',
	@bound_revenue FLOAT = 50000,
	@upper_bound_margin INT = 15000,
	@lower_bound_margin INT = 0
AS
BEGIN

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Start of [update_7i_ROI_promotions_generate_output]',
			SYSDATETIME()
		)

-- Combines components 1 and 2
IF OBJECT_ID('tempdb.dbo.#ROI_component_1_2','U') IS NOT NULL
    DROP TABLE #ROI_component_1_2
SELECT	  ro1.PromotionNumber,
		  ro1.PromotionCharacteristicsType,
		  ro1.PromotionStartDate,
		  ro1.PromotionEndDate,
		  ro1.ProductNumber,
		  ro1.Branch_name_EN,
		  ro1.SourceInd,
		  ro1.TransactionDate,
		  pio.Ind_in_plan,
		  CASE WHEN ISNULL(pio.Ind_in_plan,0) = 0 THEN NULL
		       WHEN ISNULL(ro1.Real_quantity * ro2.Baseline_quantity * ro2.Revenue_2_subs_promo,0) = 0 THEN NULL
			  ELSE 1 - (ro1.Revenue_1_promotion/ro1.Real_quantity) / (-ro2.Revenue_2_subs_promo/ro2.Baseline_quantity) END AS 'Discount',
		  ro1.Real_quantity,
		  ro2.Baseline_quantity,
		  CASE WHEN ISNULL(ro2.Baseline_quantity,0) = 0 THEN NULL
			  ELSE ro1.Real_quantity/ro2.Baseline_quantity END AS 'Uplift',
		  ro1.Revenue_1_promotion,
		  ro2.Revenue_2_subs_promo,
		  ro1.Margin_1_promotion,
		  ro2.Margin_2_subs_promo,
		  ro2.Baseline_days,
		  ro2.Valid_baseline_days,
		  ro2.Baseline_days_in_plan,
		  ro1.Ind_head_promotion,
		  ro2.Ind_less_28_baseline_days,
		  ro2.Ind_continuous_promotion,
		  ro2.Ind_sufficient_discount,
		  ro2.Ind_uplift_flag,
		  CASE WHEN ro2.Baseline_days_in_plan <= 7 AND pio.Ind_in_plan = 1 THEN 'In/out'
			  WHEN ro2.Baseline_days_in_plan > 7 AND pio.Ind_in_plan = 1 THEN 'In'
			  ELSE 'Out' END AS 'IO_indicator'
INTO		  #ROI_component_1_2
FROM		  PG_ROI_component_1 ro1
INNER JOIN  PG_dim_date dt
ON		  dt.date = ro1.TransactionDate
INNER JOIN  PG_product_in_out_indicators pio
ON		  pio.yearweek = dt.yearweek
	   AND pio.Branch_name_EN = ro1.Branch_name_EN
	   AND pio.ProductNumber = ro1.ProductNumber
INNER JOIN  PG_ROI_component_2 ro2
ON		  ro1.PromotionNumber = ro2.PromotionNumber
	   AND ro1.PromotionStartDate = ro2.PromotionStartDate
	   AND ro1.PromotionEndDate = ro2.PromotionEndDate
	   AND ro1.ProductNumber = ro2.ProductNumber
	   AND ro1.Branch_name_EN = ro2.Branch_name_EN
	   AND ro1.SourceInd = ro2.SourceInd
	   AND ro1.TransactionDate = ro2.TransactionDate

-- Adds components 3 to 8
IF OBJECT_ID('tempdb.dbo.#ROI_component_1_8','U') IS NOT NULL
    DROP TABLE #ROI_component_1_8
SELECT	  ro1.*,
		  ISNULL(ro3.Revenue_3_subs_group,0) AS 'Revenue_3_subs_group',
		  ISNULL(ro4.Revenue_4_promobuyer_existing,0) AS 'Revenue_4_promobuyer_existing',
		  ISNULL(ro4.Revenue_5_promobuyer_new,0) AS 'Revenue_5_promobuyer_new',
		  ISNULL(ro6.Revenue_6_new_customer,0) AS 'Revenue_6_new_customer',
		  ISNULL(ro7.Revenue_7_product_adoption,0) AS 'Revenue_7_product_adoption',
		  ISNULL(ro8.Revenue_8_hoarding,0) AS 'Revenue_8_hoarding',
		  ro1.Revenue_1_promotion+ro1.Revenue_2_subs_promo+ISNULL(ro3.Revenue_3_subs_group,0)+
			 ISNULL(ro4.Revenue_4_promobuyer_existing,0)+ISNULL(ro4.Revenue_5_promobuyer_new,0)+
			 ISNULL(ro6.Revenue_6_new_customer,0)+ISNULL(ro7.Revenue_7_product_adoption,0)+
			 ISNULL(ro8.Revenue_8_hoarding,0) AS 'Revenue_value_effect',
		  ISNULL(ro3.Margin_3_subs_group,0) AS 'Margin_3_subs_group',
		  ISNULL(ro4.Margin_4_promobuyer_existing,0) AS 'Margin_4_promobuyer_existing',
		  ISNULL(ro4.Margin_5_promobuyer_new,0) AS 'Margin_5_promobuyer_new',
		  ISNULL(ro6.Margin_6_new_customer,0) AS 'Margin_6_new_customer',
		  ISNULL(ro7.Margin_7_product_adoption,0) AS 'Margin_7_product_adoption',
		  ISNULL(ro8.Margin_8_hoarding,0) AS 'Margin_8_hoarding',
		  ro1.Margin_1_promotion+ro1.Margin_2_subs_promo+ISNULL(ro3.Margin_3_subs_group,0)+
			 ISNULL(ro4.Margin_4_promobuyer_existing,0)+ISNULL(ro4.Margin_5_promobuyer_new,0)+
			 ISNULL(ro6.Margin_6_new_customer,0)+ISNULL(ro7.Margin_7_product_adoption,0)+
			 ISNULL(ro8.Margin_8_hoarding,0) AS 'Margin_value_effect',
		  ro3.Ind_positive_subs,
		  ro3.Ind_high_subs
INTO		  #ROI_component_1_8
FROM		  #ROI_component_1_2 ro1
LEFT JOIN	  PG_ROI_component_3 ro3
ON		  ro1.PromotionNumber = ro3.PromotionNumber
	   AND ro1.PromotionStartDate = ro3.PromotionStartDate
	   AND ro1.PromotionEndDate = ro3.PromotionEndDate
	   AND ro1.ProductNumber = ro3.ProductNumber
	   AND ro1.Branch_name_EN = ro3.Branch_name_EN
	   AND ro1.SourceInd = ro3.SourceInd
	   AND ro1.TransactionDate = ro3.TransactionDate
LEFT JOIN	  PG_ROI_component_4_5 ro4
ON		  ro1.PromotionNumber = ro4.PromotionNumber
	   AND ro1.PromotionStartDate = ro4.PromotionStartDate
	   AND ro1.PromotionEndDate = ro4.PromotionEndDate
	   AND ro1.ProductNumber = ro4.ProductNumber
	   AND ro1.Branch_name_EN = ro4.Branch_name_EN
	   AND ro1.SourceInd = ro4.SourceInd
	   AND ro1.TransactionDate = ro4.TransactionDate
LEFT JOIN	  PG_ROI_component_6 ro6
ON		  ro1.PromotionNumber = ro6.PromotionNumber
	   AND ro1.PromotionStartDate = ro6.PromotionStartDate
	   AND ro1.PromotionEndDate = ro6.PromotionEndDate
	   AND ro1.ProductNumber = ro6.ProductNumber
	   AND ro1.Branch_name_EN = ro6.Branch_name_EN
	   AND ro1.SourceInd = ro6.SourceInd
	   AND ro1.TransactionDate = ro6.TransactionDate
LEFT JOIN	  PG_ROI_component_7 ro7
ON		  ro1.PromotionNumber = ro7.PromotionNumber
	   AND ro1.PromotionStartDate = ro7.PromotionStartDate
	   AND ro1.PromotionEndDate = ro7.PromotionEndDate
	   AND ro1.ProductNumber = ro7.ProductNumber
	   AND ro1.Branch_name_EN = ro7.Branch_name_EN
	   AND ro1.SourceInd = ro7.SourceInd
	   AND ro1.TransactionDate = ro7.TransactionDate
LEFT JOIN	  PG_ROI_component_8 ro8
ON		  ro1.PromotionNumber = ro8.PromotionNumber
	   AND ro1.PromotionStartDate = ro8.PromotionStartDate
	   AND ro1.PromotionEndDate = ro8.PromotionEndDate
	   AND ro1.ProductNumber = ro8.ProductNumber
	   AND ro1.Branch_name_EN = ro8.Branch_name_EN
	   AND ro1.SourceInd = ro8.SourceInd
	   AND ro1.TransactionDate = ro8.TransactionDate
DROP TABLE  #ROI_component_1_2

-- Adds additional information
IF OBJECT_ID('tempdb.dbo.#ROI_components_add_info','U') IS NOT NULL
    DROP TABLE #ROI_components_add_info
SELECT	  ro1.*,
		  pr.CampaignNumberPromo,
		  pr.CampaignDesc,
		  CASE WHEN pr.PromotionNumberUnv = 0 THEN NULL ELSE pr.PromotionNumberUnv END AS 'PromotionNumberUnv',
		  pr.PromotionDesc,
		  pt.Description AS 'DiscountType',
		  pr.Place_in_store,
		  pr.Folder,
		  pr.Multibuy_quantity,
		  pr.Promotion_perc_running_year,
		  ro4c.Number_customers,
		  ro4c.Existing_promotion_customers,
		  ro4c.New_promotion_customers,
		  ro4c.New_customers
		  --,ro7c.Adopting_customers
		  --,ro7a.Promo_accum_ind AS 'Ind_promo_directly_after'
INTO		  #ROI_components_add_info
FROM		  #ROI_component_1_8 ro1
INNER JOIN  PG_promotions pr
ON		  ro1.PromotionNumber = pr.PromotionNumber
	   AND ro1.PromotionStartDate = pr.PromotionStartDate
	   AND ro1.PromotionEndDate = pr.PromotionEndDate
	   AND ro1.ProductNumber = pr.ProductNumber
	   AND ro1.Branch_name_EN = pr.Branch_name_EN
	   AND ro1.SourceInd = pr.SourceInd
INNER JOIN  Staging_promotions_types pt
ON		  pr.DiscountType = pt.DiscountType
LEFT JOIN	  PG_ROI_component_4c_customer_totals ro4c
ON		  ro1.PromotionNumber = ro4c.PromotionNumber
	   AND ro1.PromotionStartDate = ro4c.PromotionStartDate
	   AND ro1.PromotionEndDate = ro4c.PromotionEndDate
	   AND ro1.ProductNumber = ro4c.ProductNumber
	   AND ro1.Branch_name_EN = ro4c.Branch_name_EN
	   AND ro1.SourceInd = ro4c.SourceInd
	   AND ro1.TransactionDate = ro4c.TransactionDate
/*
LEFT JOIN	  PG_ROI_component_7c_adopting_customers_update ro7c
ON		  ro1.PromotionNumber = ro7c.PromotionNumber
	   AND ro1.PromotionStartDate = ro7c.PromotionStartDate
	   AND ro1.PromotionEndDate = ro7c.PromotionEndDate
	   AND ro1.ProductNumber = ro7c.ProductNumber
	   AND ro1.Branch_name_EN = ro7c.Branch_name_EN
	   AND ro1.SourceInd = ro7c.SourceInd
	   AND ro1.TransactionDate = ro7c.TransactionDate
LEFT JOIN	  PG_ROI_component_7a_promo_product_ind_accum_update ro7a
ON		  ro1.PromotionNumber = ro7a.PromotionNumber
	   AND ro1.PromotionStartDate = ro7a.PromotionStartDate
	   AND ro1.PromotionEndDate = ro7a.PromotionEndDate
	   AND ro1.ProductNumber = ro7a.ProductNumber
	   AND ro1.Branch_name_EN = ro7a.Branch_name_EN
	   AND ro1.SourceInd = ro7a.SourceInd
	   AND ro1.TransactionDate = ro7a.TransactionDate
	   AND ro7a.Days_after_promotion = 1
*/
DROP TABLE  #ROI_component_1_8

-- Adds product name and hierarchy
IF OBJECT_ID('tempdb.dbo.#ROI_result_product_daily','U') IS NOT NULL
    DROP TABLE #ROI_result_product_daily
SELECT	  ro.PromotionNumber,
		  ro.PromotionCharacteristicsType,
		  ro.PromotionStartDate,
		  ro.PromotionEndDate,
		  ro.ProductNumber,
		  ro.Branch_name_EN,
		  ro.SourceInd,
		  ro.TransactionDate,
		  hn1.Level_name_HE AS 'Department_name_HE',
		  hn1.Level_name_EN AS 'Department_name_EN',
		  hn2.Level_name_HE AS 'Subdepartment_name_HE',
		  hn2.Level_name_EN AS 'Subdepartment_name_EN',
		  hn3.Level_name_HE AS 'Category_name_HE',
		  hn3.Level_name_EN AS 'Category_name_EN',
		  hn4.Level_name_HE AS 'Group_name_HE',
		  hn4.Level_name_EN AS 'Group_name_EN',
		  hn5.Level_name_HE AS 'Subgroup_name_HE',
		  hn5.Level_name_EN AS 'Subgroup_name_EN',
		  pa.Product_name_HE AS 'Product_name_HE',
		  ro.CampaignNumberPromo,
		  ro.CampaignDesc,
		  ro.PromotionNumberUnv,
		  ro.PromotionDesc,
		  ro.DiscountType,
		  ro.Place_in_store,
		  ro.Folder,
		  ro.Multibuy_quantity,
		  ro.Promotion_perc_running_year,
		  ro.Ind_in_plan,
		  ro.Discount,
		  ro.Real_quantity,
		  ro.Baseline_quantity,
		  ro.Uplift,
		  ro.Revenue_1_promotion,
		  ro.Revenue_2_subs_promo,
		  ro.Revenue_3_subs_group,
		  ro.Revenue_4_promobuyer_existing,
		  ro.Revenue_5_promobuyer_new,
		  ro.Revenue_6_new_customer,
		  ro.Revenue_7_product_adoption,
		  ro.Revenue_8_hoarding,
		  ro.Revenue_value_effect,
		  ro.Margin_1_promotion,
		  ro.Margin_2_subs_promo,
		  ro.Margin_3_subs_group,
		  ro.Margin_4_promobuyer_existing,
		  ro.Margin_5_promobuyer_new,
		  ro.Margin_6_new_customer,
		  ro.Margin_7_product_adoption,
		  ro.Margin_8_hoarding,
		  ro.Margin_value_effect,
		  ro.Number_customers,
		  ro.Existing_promotion_customers,
		  ro.New_promotion_customers,
		  ro.New_customers,
		  --ro.Adopting_customers,
		  ro.Baseline_days,
		  ro.Valid_baseline_days,
		  ro.Baseline_days_in_plan,
		  ro.Ind_head_promotion,
		  ro.Ind_less_28_baseline_days,
		  ro.Ind_continuous_promotion,
		  ro.Ind_sufficient_discount,
		  ro.Ind_uplift_flag,
		  ro.Ind_positive_subs,
		  ro.Ind_high_subs,
		  ro.IO_indicator
		  --ro7a.Promo_accum_ind AS 'Ind_promo_directly_after'
INTO		  #ROI_result_product_daily
FROM		  #ROI_components_add_info ro
INNER JOIN  PG_product_assortment pa
ON		  pa.Product_ID = ro.ProductNumber
INNER JOIN  (select * from PG_hierarchy_names
where Level='Department') hn1
ON		  hn1.Level_ID = pa.Department_ID
INNER JOIN  (select * from PG_hierarchy_names
where Level='Subdepartment')  hn2
ON		   hn2.Level_ID = pa.Subdepartment_ID
INNER JOIN  (select * from PG_hierarchy_names
where Level='Category')  hn3
ON		   hn3.Level_ID = pa.Category_ID
INNER JOIN  (select * from PG_hierarchy_names
where Level='Group') hn4
ON		  hn4.Level_ID = pa.Group_ID
INNER JOIN  (select * from PG_hierarchy_names
where Level='Subgroup') hn5
ON		  hn5.Level_ID = pa.Group_ID*10+pa.Subgroup_ID
DROP TABLE  #ROI_components_add_info




-- Calculates promotion segments
IF OBJECT_ID('tempdb.dbo.#ROI_result_promotion_segments','U') IS NOT NULL
    DROP TABLE #ROI_result_promotion_segments
;WITH CTE AS
(SELECT	  PromotionNumber,
		  Branch_name_EN,
		  PromotionCharacteristicsType,
		  SUM(Revenue_1_promotion) Revenue_1_promotion,
		  SUM(Revenue_value_effect) AS 'Revenue_value_effect',
		  SUM(Margin_value_effect) AS 'Margin_value_effect'
FROM		  #ROI_result_product_daily ro
GROUP BY	  PromotionNumber,
		  Branch_name_EN,
		  PromotionCharacteristicsType
)
SELECT	  cte.PromotionNumber,PromotionCharacteristicsType,
		  CASE WHEN SUM(Revenue_1_promotion)=0 
			    THEN '9.Zero revenue'
			  WHEN SUM(Revenue_value_effect) >= SUM(br.Multiplier_percentage*@bound_revenue) AND SUM(Margin_value_effect) >= SUM(br.Multiplier_percentage*@upper_bound_margin)
				THEN '1. Winner'
			  WHEN SUM(Revenue_value_effect) < SUM(br.Multiplier_percentage*@bound_revenue) AND SUM(Margin_value_effect) >= SUM(br.Multiplier_percentage*@upper_bound_margin)
				THEN '2. Diamond'
			  WHEN SUM(Revenue_value_effect) >= SUM(br.Multiplier_percentage*@bound_revenue) AND SUM(Margin_value_effect) >= SUM(br.Multiplier_percentage*@lower_bound_margin)
				THEN '3. Potential winner'
			  WHEN SUM(Revenue_value_effect) < SUM(br.Multiplier_percentage*@bound_revenue) AND SUM(Margin_value_effect) >= SUM(br.Multiplier_percentage*@lower_bound_margin)
				THEN '4. Grey herd'
			  WHEN SUM(Revenue_value_effect) >= SUM(br.Multiplier_percentage*@bound_revenue) AND SUM(Margin_value_effect) < SUM(br.Multiplier_percentage*@lower_bound_margin)
				THEN '5. Bleeder'
			  WHEN SUM(Revenue_value_effect) < SUM(br.Multiplier_percentage*@bound_revenue) AND SUM(Margin_value_effect) < SUM(br.Multiplier_percentage*@lower_bound_margin)
				THEN '6. Margin killer'
		  END AS 'Promotion_segment'
INTO		  #ROI_result_promotion_segments
FROM		  CTE cte
LEFT JOIN	  PG_branch_revenue_percentages br
ON		  cte.Branch_name_EN = br.Branch_name_EN
GROUP BY	  cte.PromotionNumber,cte.PromotionCharacteristicsType

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Segmentation of promotions combined',
			SYSDATETIME()
		)

-- Combined ROI results with segmentation on promotion level
IF OBJECT_ID('dbo.PG_ROI_result_product_daily','U') IS NOT NULL
    DROP TABLE dbo.PG_ROI_result_product_daily
SELECT	  ro.*,
		  ps.Promotion_segment
INTO		  dbo.PG_ROI_result_product_daily
FROM		  #ROI_result_product_daily ro
INNER JOIN  #ROI_result_promotion_segments ps
ON		  ro.PromotionNumber = ps.PromotionNumber
and (coalesce(ro.PromotionCharacteristicsType, -1) = coalesce(ps.PromotionCharacteristicsType, -1))


SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'PG_ROI_result_product_daily calculated',
			SYSDATETIME()
		)

-- Creates ROI table on a promotion level
IF OBJECT_ID('dbo.PG_ROI_result_promotion','U') IS NOT NULL
   DROP TABLE dbo.PG_ROI_result_promotion
SELECT	  PromotionNumber,
		  PromotionNumberUnv,
		  PromotionStartDate,
		  PromotionEndDate,
		  PromotionDesc,
		  CampaignNumberPromo,
		  CampaignDesc,
		  CASE WHEN MAX(Department_name_EN) = MIN(Department_name_EN) THEN MAX(Department_name_EN) ELSE NULL END AS 'Department_name_EN',
		  CASE WHEN MAX(Department_name_EN) = MIN(Department_name_EN) THEN MAX(Department_name_HE) ELSE NULL END AS 'Department_name_HE',
		  CASE WHEN MAX(Subdepartment_name_EN) = MIN(Subdepartment_name_EN) THEN MAX(Subdepartment_name_EN) ELSE NULL END AS 'Subdepartment_name_EN',
		  CASE WHEN MAX(Subdepartment_name_EN) = MIN(Subdepartment_name_EN) THEN MAX(Subdepartment_name_HE) ELSE NULL END AS 'Subdepartment_name_HE',
		  CASE WHEN MAX(Category_name_EN) = MIN(Category_name_EN) THEN MAX(Category_name_EN) ELSE NULL END AS 'Category_name_EN',
		  CASE WHEN MAX(Category_name_EN) = MIN(Category_name_EN) THEN MAX(Category_name_HE) ELSE NULL END AS 'Category_name_HE',
		  CASE WHEN MAX(Group_name_EN) = MIN(Group_name_EN) THEN MAX(Group_name_EN) ELSE NULL END AS 'Group_name_EN',
		  CASE WHEN MAX(Group_name_EN) = MIN(Group_name_EN) THEN MAX(Group_name_HE) ELSE NULL END AS 'Group_name_HE',
		  CASE WHEN MAX(Subgroup_name_EN) = MIN(Subgroup_name_EN) THEN MAX(Subgroup_name_EN) ELSE NULL END AS 'Subgroup_name_EN',
		  CASE WHEN MAX(Subgroup_name_EN) = MIN(Subgroup_name_EN) THEN MAX(Subgroup_name_HE) ELSE NULL END AS 'Subgroup_name_HE',
		  CASE WHEN SUM(CASE WHEN Branch_name_EN = 'Deal' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'Deal',
		  CASE WHEN SUM(CASE WHEN Branch_name_EN = 'Extra' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'Extra',
		  CASE WHEN SUM(CASE WHEN Branch_name_EN = 'Express' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'Express',
		  CASE WHEN SUM(CASE WHEN Branch_name_EN = 'Sheli' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'Sheli',
		  CASE WHEN SUM(CASE WHEN Branch_name_EN = 'Organic' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'Organic',
		  DiscountType,
		  Place_in_store,
		  Folder,
		  Multibuy_quantity,
		  AVG(Promotion_perc_running_year) AS 'Promotion_perc_running_year',
		  CASE WHEN SUM(Ind_in_plan * Real_quantity * Baseline_quantity * Revenue_2_subs_promo) = 0 THEN NULL
			  ELSE 1 - (SUM(Ind_in_plan*Revenue_1_promotion)/SUM(Ind_in_plan*Real_quantity)) / (-SUM(Ind_in_plan*Revenue_2_subs_promo)/SUM(Ind_in_plan*Baseline_quantity)) END AS 'Discount',
		  SUM(Real_quantity) AS 'Real_quantity',
		  SUM(Baseline_quantity) AS 'Baseline_quantity',
		  CASE WHEN SUM(Baseline_quantity) = 0 THEN NULL
			  ELSE SUM(Real_quantity)/SUM(Baseline_quantity) END AS 'Uplift',
		  SUM(Revenue_1_promotion) AS 'Revenue_1_promotion',
		  SUM(Revenue_2_subs_promo) AS 'Revenue_2_subs_promo',
		  SUM(Revenue_3_subs_group) AS 'Revenue_3_subs_group',
		  SUM(Revenue_4_promobuyer_existing) AS 'Revenue_4_promobuyer_existing',
		  SUM(Revenue_5_promobuyer_new) AS 'Revenue_5_promobuyer_new',
		  SUM(Revenue_6_new_customer) AS 'Revenue_6_new_customer',
		  SUM(Revenue_7_product_adoption) AS 'Revenue_7_product_adoption',
		  SUM(Revenue_8_hoarding) AS 'Revenue_8_hoarding',
		  SUM(Revenue_value_effect) AS 'Revenue_value_effect',
		  SUM(Margin_1_promotion) AS 'Margin_1_promotion',
		  SUM(Margin_2_subs_promo) AS 'Margin_2_subs_promo',
		  SUM(Margin_3_subs_group) AS 'Margin_3_subs_group',
		  SUM(Margin_4_promobuyer_existing) AS 'Margin_4_promobuyer_existing',
		  SUM(Margin_5_promobuyer_new) AS 'Margin_5_promobuyer_new',
		  SUM(Margin_6_new_customer) AS 'Margin_6_new_customer',
		  SUM(Margin_7_product_adoption) AS 'Margin_7_product_adoption',
		  SUM(Margin_8_hoarding) AS 'Margin_8_hoarding',
		  SUM(Margin_value_effect) AS 'Margin_value_effect',
		  Promotion_segment
INTO		  dbo.PG_ROI_result_promotion
FROM		  PG_ROI_result_product_daily
WHERE	  PromotionStartDate <= '2016-05-31'
GROUP BY	  PromotionNumber,
		  PromotionStartDate,
		  PromotionEndDate,
		  PromotionDesc,
		  DiscountType,
		  Folder,
		  Multibuy_quantity,
		  Promotion_segment,
		  PromotionNumberUnv,
		  CampaignNumberPromo,
		  CampaignDesc,
		  Place_in_store

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Results per promotion for first third calculated',
			SYSDATETIME()
		)

INSERT INTO dbo.PG_ROI_result_promotion
SELECT	  PromotionNumber,
		  PromotionNumberUnv,
		  PromotionStartDate,
		  PromotionEndDate,
		  PromotionDesc,
		  CampaignNumberPromo,
		  CampaignDesc,
		  CASE WHEN MAX(Department_name_EN) = MIN(Department_name_EN) THEN MAX(Department_name_EN) ELSE NULL END AS 'Department_name_EN',
		  CASE WHEN MAX(Department_name_EN) = MIN(Department_name_EN) THEN MAX(Department_name_HE) ELSE NULL END AS 'Department_name_HE',
		  CASE WHEN MAX(Subdepartment_name_EN) = MIN(Subdepartment_name_EN) THEN MAX(Subdepartment_name_EN) ELSE NULL END AS 'Subdepartment_name_EN',
		  CASE WHEN MAX(Subdepartment_name_EN) = MIN(Subdepartment_name_EN) THEN MAX(Subdepartment_name_HE) ELSE NULL END AS 'Subdepartment_name_HE',
		  CASE WHEN MAX(Category_name_EN) = MIN(Category_name_EN) THEN MAX(Category_name_EN) ELSE NULL END AS 'Category_name_EN',
		  CASE WHEN MAX(Category_name_EN) = MIN(Category_name_EN) THEN MAX(Category_name_HE) ELSE NULL END AS 'Category_name_HE',
		  CASE WHEN MAX(Group_name_EN) = MIN(Group_name_EN) THEN MAX(Group_name_EN) ELSE NULL END AS 'Group_name_EN',
		  CASE WHEN MAX(Group_name_EN) = MIN(Group_name_EN) THEN MAX(Group_name_HE) ELSE NULL END AS 'Group_name_HE',
		  CASE WHEN MAX(Subgroup_name_EN) = MIN(Subgroup_name_EN) THEN MAX(Subgroup_name_EN) ELSE NULL END AS 'Subgroup_name_EN',
		  CASE WHEN MAX(Subgroup_name_EN) = MIN(Subgroup_name_EN) THEN MAX(Subgroup_name_HE) ELSE NULL END AS 'Subgroup_name_HE',
		  CASE WHEN SUM(CASE WHEN Branch_name_EN = 'Deal' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'Deal',
		  CASE WHEN SUM(CASE WHEN Branch_name_EN = 'Extra' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'Extra',
		  CASE WHEN SUM(CASE WHEN Branch_name_EN = 'Express' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'Express',
		  CASE WHEN SUM(CASE WHEN Branch_name_EN = 'Sheli' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'Sheli',
		  CASE WHEN SUM(CASE WHEN Branch_name_EN = 'Organic' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'Organic',
		  DiscountType,
		  Place_in_store,
		  Folder,
		  Multibuy_quantity,
		  AVG(Promotion_perc_running_year) AS 'Promotion_perc_running_year',
		  CASE WHEN SUM(Ind_in_plan * Real_quantity * Baseline_quantity * Revenue_2_subs_promo) = 0 THEN NULL
			  ELSE 1 - (SUM(Ind_in_plan*Revenue_1_promotion)/SUM(Ind_in_plan*Real_quantity)) / (-SUM(Ind_in_plan*Revenue_2_subs_promo)/SUM(Ind_in_plan*Baseline_quantity)) END AS 'Discount',
		  SUM(Real_quantity) AS 'Real_quantity',
		  SUM(Baseline_quantity) AS 'Baseline_quantity',
		  CASE WHEN SUM(Baseline_quantity) = 0 THEN NULL
			  ELSE SUM(Real_quantity)/SUM(Baseline_quantity) END AS 'Uplift',
		  SUM(Revenue_1_promotion) AS 'Revenue_1_promotion',
		  SUM(Revenue_2_subs_promo) AS 'Revenue_2_subs_promo',
		  SUM(Revenue_3_subs_group) AS 'Revenue_3_subs_group',
		  SUM(Revenue_4_promobuyer_existing) AS 'Revenue_4_promobuyer_existing',
		  SUM(Revenue_5_promobuyer_new) AS 'Revenue_5_promobuyer_new',
		  SUM(Revenue_6_new_customer) AS 'Revenue_6_new_customer',
		  SUM(Revenue_7_product_adoption) AS 'Revenue_7_product_adoption',
		  SUM(Revenue_8_hoarding) AS 'Revenue_8_hoarding',
		  SUM(Revenue_value_effect) AS 'Revenue_value_effect',
		  SUM(Margin_1_promotion) AS 'Margin_1_promotion',
		  SUM(Margin_2_subs_promo) AS 'Margin_2_subs_promo',
		  SUM(Margin_3_subs_group) AS 'Margin_3_subs_group',
		  SUM(Margin_4_promobuyer_existing) AS 'Margin_4_promobuyer_existing',
		  SUM(Margin_5_promobuyer_new) AS 'Margin_5_promobuyer_new',
		  SUM(Margin_6_new_customer) AS 'Margin_6_new_customer',
		  SUM(Margin_7_product_adoption) AS 'Margin_7_product_adoption',
		  SUM(Margin_8_hoarding) AS 'Margin_8_hoarding',
		  SUM(Margin_value_effect) AS 'Margin_value_effect',
		  Promotion_segment
--INTO		  PG_ROI_result_promotion
FROM		  PG_ROI_result_product_daily
WHERE	  PromotionStartDate BETWEEN '2016-05-31' AND '2017-02-28'
GROUP BY	  PromotionNumber,
		  PromotionStartDate,
		  PromotionEndDate,
		  PromotionDesc,
		  DiscountType,
		  Folder,
		  Multibuy_quantity,
		  Promotion_segment,
		  PromotionNumberUnv,
		  CampaignNumberPromo,
		  CampaignDesc,
		  Place_in_store

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Results for second third calculated',
			SYSDATETIME()
		)

INSERT INTO dbo.PG_ROI_result_promotion
SELECT	  PromotionNumber,
		  PromotionNumberUnv,
		  PromotionStartDate,
		  PromotionEndDate,
		  PromotionDesc,
		  CampaignNumberPromo,
		  CampaignDesc,
		  CASE WHEN MAX(Department_name_EN) = MIN(Department_name_EN) THEN MAX(Department_name_EN) ELSE NULL END AS 'Department_name_EN',
		  CASE WHEN MAX(Department_name_EN) = MIN(Department_name_EN) THEN MAX(Department_name_HE) ELSE NULL END AS 'Department_name_HE',
		  CASE WHEN MAX(Subdepartment_name_EN) = MIN(Subdepartment_name_EN) THEN MAX(Subdepartment_name_EN) ELSE NULL END AS 'Subdepartment_name_EN',
		  CASE WHEN MAX(Subdepartment_name_EN) = MIN(Subdepartment_name_EN) THEN MAX(Subdepartment_name_HE) ELSE NULL END AS 'Subdepartment_name_HE',
		  CASE WHEN MAX(Category_name_EN) = MIN(Category_name_EN) THEN MAX(Category_name_EN) ELSE NULL END AS 'Category_name_EN',
		  CASE WHEN MAX(Category_name_EN) = MIN(Category_name_EN) THEN MAX(Category_name_HE) ELSE NULL END AS 'Category_name_HE',
		  CASE WHEN MAX(Group_name_EN) = MIN(Group_name_EN) THEN MAX(Group_name_EN) ELSE NULL END AS 'Group_name_EN',
		  CASE WHEN MAX(Group_name_EN) = MIN(Group_name_EN) THEN MAX(Group_name_HE) ELSE NULL END AS 'Group_name_HE',
		  CASE WHEN MAX(Subgroup_name_EN) = MIN(Subgroup_name_EN) THEN MAX(Subgroup_name_EN) ELSE NULL END AS 'Subgroup_name_EN',
		  CASE WHEN MAX(Subgroup_name_EN) = MIN(Subgroup_name_EN) THEN MAX(Subgroup_name_HE) ELSE NULL END AS 'Subgroup_name_HE',
		  CASE WHEN SUM(CASE WHEN Branch_name_EN = 'Deal' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'Deal',
		  CASE WHEN SUM(CASE WHEN Branch_name_EN = 'Extra' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'Extra',
		  CASE WHEN SUM(CASE WHEN Branch_name_EN = 'Express' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'Express',
		  CASE WHEN SUM(CASE WHEN Branch_name_EN = 'Sheli' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'Sheli',
		  CASE WHEN SUM(CASE WHEN Branch_name_EN = 'Organic' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'Organic',
		  DiscountType,
		  Place_in_store,
		  Folder,
		  Multibuy_quantity,
		  AVG(Promotion_perc_running_year) AS 'Promotion_perc_running_year',
		  CASE WHEN SUM(Ind_in_plan * Real_quantity * Baseline_quantity * Revenue_2_subs_promo) = 0 THEN NULL
			  ELSE 1 - (SUM(Ind_in_plan*Revenue_1_promotion)/SUM(Ind_in_plan*Real_quantity)) / (-SUM(Ind_in_plan*Revenue_2_subs_promo)/SUM(Ind_in_plan*Baseline_quantity)) END AS 'Discount',
		  SUM(Real_quantity) AS 'Real_quantity',
		  SUM(Baseline_quantity) AS 'Baseline_quantity',
		  CASE WHEN SUM(Baseline_quantity) = 0 THEN NULL
			  ELSE SUM(Real_quantity)/SUM(Baseline_quantity) END AS 'Uplift',
		  SUM(Revenue_1_promotion) AS 'Revenue_1_promotion',
		  SUM(Revenue_2_subs_promo) AS 'Revenue_2_subs_promo',
		  SUM(Revenue_3_subs_group) AS 'Revenue_3_subs_group',
		  SUM(Revenue_4_promobuyer_existing) AS 'Revenue_4_promobuyer_existing',
		  SUM(Revenue_5_promobuyer_new) AS 'Revenue_5_promobuyer_new',
		  SUM(Revenue_6_new_customer) AS 'Revenue_6_new_customer',
		  SUM(Revenue_7_product_adoption) AS 'Revenue_7_product_adoption',
		  SUM(Revenue_8_hoarding) AS 'Revenue_8_hoarding',
		  SUM(Revenue_value_effect) AS 'Revenue_value_effect',
		  SUM(Margin_1_promotion) AS 'Margin_1_promotion',
		  SUM(Margin_2_subs_promo) AS 'Margin_2_subs_promo',
		  SUM(Margin_3_subs_group) AS 'Margin_3_subs_group',
		  SUM(Margin_4_promobuyer_existing) AS 'Margin_4_promobuyer_existing',
		  SUM(Margin_5_promobuyer_new) AS 'Margin_5_promobuyer_new',
		  SUM(Margin_6_new_customer) AS 'Margin_6_new_customer',
		  SUM(Margin_7_product_adoption) AS 'Margin_7_product_adoption',
		  SUM(Margin_8_hoarding) AS 'Margin_8_hoarding',
		  SUM(Margin_value_effect) AS 'Margin_value_effect',
		  Promotion_segment
--INTO		  PG_ROI_result_promotion
FROM		  dbo.PG_ROI_result_product_daily
WHERE	  PromotionStartDate > '2017-02-28'
GROUP BY	  PromotionNumber,
		  PromotionStartDate,
		  PromotionEndDate,
		  PromotionDesc,
		  DiscountType,
		  Folder,
		  Multibuy_quantity,
		  Promotion_segment,
		  PromotionNumberUnv,
		  CampaignNumberPromo,
		  CampaignDesc,
		  Place_in_store

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Results per promotion calculated',
			SYSDATETIME()
		)

-- Creates ROI table on a promotion level
IF OBJECT_ID('dbo.PG_ROI_result_promotion_only_in','U') IS NOT NULL
    DROP TABLE dbo.PG_ROI_result_promotion_only_in
SELECT	  PromotionNumber,
		  PromotionNumberUnv,
		  PromotionStartDate,
		  PromotionEndDate,
		  PromotionDesc,
		  CampaignNumberPromo,
		  CampaignDesc,
		  CASE WHEN MAX(Department_name_EN) = MIN(Department_name_EN) THEN MAX(Department_name_EN) ELSE NULL END AS 'Department_name_EN',
		  CASE WHEN MAX(Department_name_EN) = MIN(Department_name_EN) THEN MAX(Department_name_HE) ELSE NULL END AS 'Department_name_HE',
		  CASE WHEN MAX(Subdepartment_name_EN) = MIN(Subdepartment_name_EN) THEN MAX(Subdepartment_name_EN) ELSE NULL END AS 'Subdepartment_name_EN',
		  CASE WHEN MAX(Subdepartment_name_EN) = MIN(Subdepartment_name_EN) THEN MAX(Subdepartment_name_HE) ELSE NULL END AS 'Subdepartment_name_HE',
		  CASE WHEN MAX(Category_name_EN) = MIN(Category_name_EN) THEN MAX(Category_name_EN) ELSE NULL END AS 'Category_name_EN',
		  CASE WHEN MAX(Category_name_EN) = MIN(Category_name_EN) THEN MAX(Category_name_HE) ELSE NULL END AS 'Category_name_HE',
		  CASE WHEN MAX(Group_name_EN) = MIN(Group_name_EN) THEN MAX(Group_name_EN) ELSE NULL END AS 'Group_name_EN',
		  CASE WHEN MAX(Group_name_EN) = MIN(Group_name_EN) THEN MAX(Group_name_HE) ELSE NULL END AS 'Group_name_HE',
		  CASE WHEN MAX(Subgroup_name_EN) = MIN(Subgroup_name_EN) THEN MAX(Subgroup_name_EN) ELSE NULL END AS 'Subgroup_name_EN',
		  CASE WHEN MAX(Subgroup_name_EN) = MIN(Subgroup_name_EN) THEN MAX(Subgroup_name_HE) ELSE NULL END AS 'Subgroup_name_HE',
		  CASE WHEN SUM(CASE WHEN Branch_name_EN = 'Deal' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'Deal',
		  CASE WHEN SUM(CASE WHEN Branch_name_EN = 'Extra' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'Extra',
		  CASE WHEN SUM(CASE WHEN Branch_name_EN = 'Express' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'Express',
		  CASE WHEN SUM(CASE WHEN Branch_name_EN = 'Sheli' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'Sheli',
		  CASE WHEN SUM(CASE WHEN Branch_name_EN = 'Organic' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'Organic',
		  DiscountType,
		  Place_in_store,
		  Folder,
		  Multibuy_quantity,
		  AVG(Promotion_perc_running_year) AS 'Promotion_perc_running_year',
		  CASE WHEN SUM(Ind_in_plan * Real_quantity * Baseline_quantity * Revenue_2_subs_promo) = 0 THEN NULL
			  ELSE 1 - (SUM(Ind_in_plan*Revenue_1_promotion)/SUM(Ind_in_plan*Real_quantity)) / (-SUM(Ind_in_plan*Revenue_2_subs_promo)/SUM(Ind_in_plan*Baseline_quantity)) END AS 'Discount',
		  SUM(Real_quantity) AS 'Real_quantity',
		  SUM(Baseline_quantity) AS 'Baseline_quantity',
		  CASE WHEN SUM(Baseline_quantity) = 0 THEN NULL
			  ELSE SUM(Real_quantity)/SUM(Baseline_quantity) END AS 'Uplift',
		  SUM(Revenue_1_promotion) AS 'Revenue_1_promotion',
		  SUM(Revenue_2_subs_promo) AS 'Revenue_2_subs_promo',
		  SUM(Revenue_3_subs_group) AS 'Revenue_3_subs_group',
		  SUM(Revenue_4_promobuyer_existing) AS 'Revenue_4_promobuyer_existing',
		  SUM(Revenue_5_promobuyer_new) AS 'Revenue_5_promobuyer_new',
		  SUM(Revenue_6_new_customer) AS 'Revenue_6_new_customer',
		  SUM(Revenue_7_product_adoption) AS 'Revenue_7_product_adoption',
		  SUM(Revenue_8_hoarding) AS 'Revenue_8_hoarding',
		  SUM(Revenue_value_effect) AS 'Revenue_value_effect',
		  SUM(Margin_1_promotion) AS 'Margin_1_promotion',
		  SUM(Margin_2_subs_promo) AS 'Margin_2_subs_promo',
		  SUM(Margin_3_subs_group) AS 'Margin_3_subs_group',
		  SUM(Margin_4_promobuyer_existing) AS 'Margin_4_promobuyer_existing',
		  SUM(Margin_5_promobuyer_new) AS 'Margin_5_promobuyer_new',
		  SUM(Margin_6_new_customer) AS 'Margin_6_new_customer',
		  SUM(Margin_7_product_adoption) AS 'Margin_7_product_adoption',
		  SUM(Margin_8_hoarding) AS 'Margin_8_hoarding',
		  SUM(Margin_value_effect) AS 'Margin_value_effect',
		  Promotion_segment
INTO		  dbo.PG_ROI_result_promotion_only_in
FROM		  dbo.PG_ROI_result_product_daily
WHERE	  IO_indicator = 'In'
GROUP BY	  PromotionNumber,
		  PromotionStartDate,
		  PromotionEndDate,
		  PromotionDesc,
		  DiscountType,
		  Folder,
		  Multibuy_quantity,
		  Promotion_segment,
		  PromotionNumberUnv,
		  CampaignNumberPromo,
		  CampaignDesc,
		  Place_in_store

-- Creates ROI table on a total product level
TRUNCATE TABLE PG_ROI_result_product_total
DECLARE	  @date DATE = '2015-03-01'
WHILE	  @date <= @end_date
BEGIN
INSERT INTO PG_ROI_result_product_total
SELECT	  ProductNumber,
		  Product_name_HE,
		  ROW_NUMBER() OVER(PARTITION BY ProductNumber, Branch_name_EN ORDER BY PromotionStartDate ASC) AS 'Promotion_index',
		  PromotionNumber,
		  PromotionNumberUnv,
		  PromotionStartDate,
		  PromotionEndDate,
		  Branch_name_EN,
		  Department_name_EN,
		  Department_name_HE,
		  Subdepartment_name_EN,
		  Subdepartment_name_HE,
		  Category_name_EN,
		  Category_name_HE,
		  Group_name_EN,
		  Group_name_HE,
		  Subgroup_name_EN,
		  Subgroup_name_HE,
		  DiscountType,
		  Place_in_store,
		  Folder,
		  Multibuy_quantity,
		  Promotion_perc_running_year,
		  CASE WHEN SUM(Ind_in_plan) = 0 THEN NULL
		       WHEN SUM(Ind_in_plan * Real_quantity * Baseline_quantity * Revenue_2_subs_promo) = 0 THEN NULL
			  ELSE 1 - (SUM(Ind_in_plan*Revenue_1_promotion)/SUM(Ind_in_plan*Real_quantity)) / (-SUM(Ind_in_plan*Revenue_2_subs_promo)/SUM(Ind_in_plan*Baseline_quantity)) END AS 'Discount',
		  SUM(Real_quantity) AS 'Real_quantity',
		  SUM(Baseline_quantity) AS 'Baseline_quantity',
		  CASE WHEN SUM(Baseline_quantity) = 0 THEN NULL
			  ELSE SUM(Real_quantity)/SUM(Baseline_quantity) END AS 'Uplift',
		  SUM(Revenue_1_promotion) AS 'Revenue_1_promotion',
		  SUM(Revenue_2_subs_promo) AS 'Revenue_2_subs_promo',
		  SUM(Revenue_3_subs_group) AS 'Revenue_3_subs_group',
		  SUM(Revenue_4_promobuyer_existing) AS 'Revenue_4_promobuyer_existing',
		  SUM(Revenue_5_promobuyer_new) AS 'Revenue_5_promobuyer_new',
		  SUM(Revenue_6_new_customer) AS 'Revenue_6_new_customer',
		  SUM(Revenue_7_product_adoption) AS 'Revenue_7_product_adoption',
		  SUM(Revenue_8_hoarding) AS 'Revenue_8_hoarding',
		  SUM(Revenue_value_effect) AS 'Revenue_value_effect',
		  SUM(Margin_1_promotion) AS 'Margin_1_promotion',
		  SUM(Margin_2_subs_promo) AS 'Margin_2_subs_promo',
		  SUM(Margin_3_subs_group) AS 'Margin_3_subs_group',
		  SUM(Margin_4_promobuyer_existing) AS 'Margin_4_promobuyer_existing',
		  SUM(Margin_5_promobuyer_new) AS 'Margin_5_promobuyer_new',
		  SUM(Margin_6_new_customer) AS 'Margin_6_new_customer',
		  SUM(Margin_7_product_adoption) AS 'Margin_7_product_adoption',
		  SUM(Margin_8_hoarding) AS 'Margin_8_hoarding',
		  SUM(Margin_value_effect) AS 'Margin_value_effect',
		  Promotion_segment
FROM		  PG_ROI_result_product_daily
WHERE	  PromotionStartDate BETWEEN @date AND DATEADD(day,179,@date)
GROUP BY	  ProductNumber,
		  Product_name_HE,
		  PromotionNumber,
		  PromotionNumberUnv,
		  PromotionStartDate,
		  PromotionEndDate,
		  Branch_name_EN,
		  Department_name_EN,
		  Department_name_HE,
		  Subdepartment_name_EN,
		  Subdepartment_name_HE,
		  Category_name_EN,
		  Category_name_HE,
		  Group_name_EN,
		  Group_name_HE,
		  Subgroup_name_EN,
		  Subgroup_name_HE,
		  DiscountType,
		  Place_in_store,
		  Folder,
		  Multibuy_quantity,
		  Promotion_perc_running_year,
		  Promotion_segment

SET	   @date = DATEADD(day,180,@date)
END

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Total results per product calculated',
			SYSDATETIME()
		)

IF OBJECT_ID('dbo.PG_ROI_result_format_daily_LastUpdate','U') IS NOT NULL
    DROP TABLE PG_ROI_result_format_daily_LastUpdate
select *
into PG_ROI_result_format_daily_LastUpdate
from PG_ROI_result_format_daily

-- Creates ROI table on a day level per format
IF OBJECT_ID('dbo.PG_ROI_result_format_daily','U') IS NOT NULL
    DROP TABLE PG_ROI_result_format_daily
SELECT	  Branch_name_EN,
		  dt.date,
		  dt.yearweek,
		  dt.yearmonth,
		  dt.yearquarter,
		  dt.year,
		  CASE WHEN SUM(Ind_in_plan) = 0 THEN NULL
		       WHEN SUM(Ind_in_plan * Real_quantity * Baseline_quantity * Revenue_2_subs_promo) = 0 THEN NULL
			  ELSE 1 - (SUM(Ind_in_plan*Revenue_1_promotion)/SUM(Ind_in_plan*Real_quantity)) / (-SUM(Ind_in_plan*Revenue_2_subs_promo)/SUM(Ind_in_plan*Baseline_quantity)) END AS 'Discount',
		  SUM(Real_quantity) AS 'Real_quantity',
		  SUM(Baseline_quantity) AS 'Baseline_quantity',
		  CASE WHEN SUM(Baseline_quantity) = 0 THEN NULL
			  ELSE SUM(Real_quantity)/SUM(Baseline_quantity) END AS 'Uplift',
		  SUM(Revenue_1_promotion) AS 'Revenue_1_promotion',
		  SUM(Revenue_2_subs_promo) AS 'Revenue_2_subs_promo',
		  SUM(Revenue_3_subs_group) AS 'Revenue_3_subs_group',
		  SUM(Revenue_4_promobuyer_existing) AS 'Revenue_4_promobuyer_existing',
		  SUM(Revenue_5_promobuyer_new) AS 'Revenue_5_promobuyer_new',
		  SUM(Revenue_6_new_customer) AS 'Revenue_6_new_customer',
		  SUM(Revenue_7_product_adoption) AS 'Revenue_7_product_adoption',
		  SUM(Revenue_8_hoarding) AS 'Revenue_8_hoarding',
		  SUM(Revenue_value_effect) AS 'Revenue_value_effect',
		  SUM(Margin_1_promotion) AS 'Margin_1_promotion',
		  SUM(Margin_2_subs_promo) AS 'Margin_2_subs_promo',
		  SUM(Margin_3_subs_group) AS 'Margin_3_subs_group',
		  SUM(Margin_4_promobuyer_existing) AS 'Margin_4_promobuyer_existing',
		  SUM(Margin_5_promobuyer_new) AS 'Margin_5_promobuyer_new',
		  SUM(Margin_6_new_customer) AS 'Margin_6_new_customer',
		  SUM(Margin_7_product_adoption) AS 'Margin_7_product_adoption',
		  SUM(Margin_8_hoarding) AS 'Margin_8_hoarding',
		  SUM(Margin_value_effect) AS 'Margin_value_effect'
INTO		  dbo.PG_ROI_result_format_daily
FROM		  PG_ROI_result_product_daily ro
INNER JOIN  PG_dim_date dt
ON		  ro.TransactionDate = dt.date
GROUP BY	  Branch_name_EN,
		  dt.date,
		  dt.yearweek,
		  dt.yearmonth,
		  dt.yearquarter,
		  dt.year



SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Total results per format calculated',
			SYSDATETIME()
		)

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'End of [update_7i_ROI_promotions_generate_output]',
			SYSDATETIME()
		)

END
