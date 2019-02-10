
-- =============================================
-- Author:		Jesper de Groot & Hagai Weiss
-- Create date:	2018-03-19
-- Description:	Generates input data for RAS
-- =============================================
CREATE PROCEDURE [dbo].[release19_update_7j_ROI_promotions_input_RAS]
    --@run_nr INT = 1,
    --@run_date DATE = '2017-10-09',
    --@step INT = 1
AS
BEGIN

--SET @step = @step + 1;
--INSERT INTO PG_update_log
--	VALUES(	@run_nr,
--			@run_date,
--			7,
--			@step,
--			'Start of [release19_update_7j_ROI_promotions_input_RAS]',
--			SYSDATETIME()
--		)

IF OBJECT_ID('tempdb.dbo.#release19_input_RAS','U') IS NOT NULL
    DROP TABLE #release19_input_RAS
SELECT	  PromotionNumber,
		  PromotionNumberUnv,
		  PromotionDesc,
		  CampaignNumberPromo, --added
		  CampaignDesc,--added
		  PromotionStartDate,
		  PromotionEndDate,
		  DATEDIFF(day,PromotionStartDate,PromotionEndDate)+1 AS 'Length',
		  ProductNumber,
		  Product_name_HE,
		  TransactionDate,
		  Branch_name_EN,
		  SourceInd,
		  DiscountType,
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
		  Multibuy_quantity,
		  Place_in_store,
		  Folder,
		  Real_quantity,
		  Baseline_quantity,
		  CASE WHEN Baseline_quantity = 0 THEN NULL
			  ELSE Real_quantity/Baseline_quantity END AS 'Uplift',
		  Revenue_1_promotion,
		  Revenue_2_subs_promo,
		  Revenue_3_subs_group,
		  Revenue_4_promobuyer_existing,
		  Revenue_5_promobuyer_new,
		  Revenue_6_new_customer,
		  Revenue_7_product_adoption,
		  Revenue_8_hoarding,
		  Revenue_value_effect,
		  Margin_1_promotion,
		  Margin_2_subs_promo,
		  Margin_3_subs_group,
		  Margin_4_promobuyer_existing,
		  Margin_5_promobuyer_new,
		  Margin_6_new_customer,
		  Margin_7_product_adoption,
		  Margin_8_hoarding,
		  Margin_value_effect,
		  Promotion_segment,
		  Number_customers,
		  Existing_promotion_customers+New_promotion_customers AS 'Promotion_customers',
		  New_customers,
		  NULL AS 'Adopting_customers',
		  NULL AS 'Total_supplier_participation',
		  CASE WHEN Real_quantity = 0 THEN NULL
			  ELSE Revenue_1_promotion/Real_quantity END AS 'Promotion_price_per_product',
		  CASE WHEN Baseline_quantity = 0 THEN NULL
			  ELSE -Revenue_2_subs_promo/Baseline_quantity END AS 'Regular_price_per_product',
		  Discount,
		  CASE WHEN Real_quantity = 0 THEN NULL
			  ELSE Margin_1_promotion/Real_quantity END AS 'Promotion_margin_per_product',
		  CASE WHEN Baseline_quantity = 0 THEN NULL
			  ELSE -Margin_2_subs_promo/Baseline_quantity END AS 'Regular_margin_per_product',
		  NULL AS 'Selling_price',
		  NULL AS 'Supplier_participation_per_product'
INTO		  #release19_input_RAS
FROM		  PG_ROI_result_product_daily

IF OBJECT_ID('dbo.release19_PG_input_RAS','U') IS NOT NULL
    DROP TABLE dbo.release19_PG_input_RAS
SELECT [PromotionNumber]
	 ,[PromotionNumberUnv]
	 ,[PromotionDesc]
	 ,[CampaignNumberPromo] --added
	 ,[CampaignDesc] --added
      ,[PromotionStartDate]
      ,[PromotionEndDate]
      ,[Length]
      ,[ProductNumber]
      ,[Product_name_HE]
      ,[TransactionDate]
      ,[Branch_name_EN]
      ,[SourceInd]
      ,DiscountType AS [Promotion_type]
      ,Department_name_EN,
		  Department_name_HE,
		  Subdepartment_name_EN,
		  Subdepartment_name_HE,
		  Category_name_EN,
		  Category_name_HE,
		  Group_name_EN,
		  Group_name_HE,
		  Subgroup_name_EN,
		  Subgroup_name_HE
      ,[Multibuy_quantity]
      ,[Place_in_store]
      ,[Folder]
      ,CONVERT(DECIMAL(10,2),ROUND([Real_quantity],2)) AS 'Real_quantity'
      ,CONVERT(DECIMAL(10,2),ROUND([Baseline_quantity],2)) AS 'Baseline_quantity'
      ,CONVERT(DECIMAL(10,2),ROUND([Uplift],2)) AS 'Uplift'
      ,CONVERT(DECIMAL(10,2),ROUND([Revenue_1_promotion],2)) AS 'Revenue_1_promotion'
      ,CONVERT(DECIMAL(10,2),ROUND([Revenue_2_subs_promo],2)) AS 'Revenue_2_subs_promo'
      ,CONVERT(DECIMAL(10,2),ROUND([Revenue_3_subs_group],2)) AS 'Revenue_3_subs_group'
      ,CONVERT(DECIMAL(10,2),ROUND([Revenue_4_promobuyer_existing],2)) AS 'Revenue_4_promobuyer_existing'
      ,CONVERT(DECIMAL(10,2),ROUND([Revenue_5_promobuyer_new],2)) AS 'Revenue_5_promobuyer_new'
      ,CONVERT(DECIMAL(10,2),ROUND([Revenue_6_new_customer],2)) AS 'Revenue_6_new_customer'
      ,CONVERT(DECIMAL(10,2),ROUND([Revenue_7_product_adoption],2)) AS 'Revenue_7_product_adoption'
      ,CONVERT(DECIMAL(10,2),ROUND([Revenue_8_hoarding],2)) AS 'Revenue_8_hoarding'
      ,CONVERT(DECIMAL(10,2),ROUND([Revenue_value_effect],2)) AS 'Revenue_value_effect'
      ,CONVERT(DECIMAL(10,2),ROUND([Margin_1_promotion],2)) AS 'Margin_1_promotion'
      ,CONVERT(DECIMAL(10,2),ROUND([Margin_2_subs_promo],2)) AS 'Margin_2_subs_promo'
      ,CONVERT(DECIMAL(10,2),ROUND([Margin_3_subs_group],2)) AS 'Margin_3_subs_group'
      ,CONVERT(DECIMAL(10,2),ROUND([Margin_4_promobuyer_existing],2)) AS 'Margin_4_promobuyer_existing'
      ,CONVERT(DECIMAL(10,2),ROUND([Margin_5_promobuyer_new],2)) AS 'Margin_5_promobuyer_new'
      ,CONVERT(DECIMAL(10,2),ROUND([Margin_6_new_customer],2)) AS 'Margin_6_new_customer'
      ,CONVERT(DECIMAL(10,2),ROUND([Margin_7_product_adoption],2)) AS 'Margin_7_product_adoption'
      ,CONVERT(DECIMAL(10,2),ROUND([Margin_8_hoarding],2)) AS 'Margin_8_hoarding'
      ,CONVERT(DECIMAL(10,2),ROUND([Margin_value_effect],2)) AS 'Margin_value_effect'
      ,[Promotion_segment]
      ,[Number_customers]
      ,[Promotion_customers]
      ,[New_customers]
      ,[Adopting_customers]
      ,[Total_supplier_participation]
      ,CONVERT(DECIMAL(10,2),ROUND([Promotion_price_per_product],2)) AS 'Promotion_price_per_product'
      ,CONVERT(DECIMAL(10,2),ROUND([Regular_price_per_product],2)) AS 'Regular_price_per_product'
      ,CONVERT(DECIMAL(10,2),ROUND([Discount],2)) AS 'Discount'
      ,CONVERT(DECIMAL(10,2),ROUND([Promotion_margin_per_product],2)) AS 'Promotion_margin_per_product'
      ,CONVERT(DECIMAL(10,2),ROUND([Regular_margin_per_product],2)) AS 'Regular_margin_per_product'
      ,[Selling_price]
      ,[Supplier_participation_per_product]
INTO	   dbo.release19_PG_input_RAS
FROM	   #release19_input_RAS

--SET @step = @step + 1;
--INSERT INTO PG_update_log
--	VALUES(	@run_nr,
--			@run_date,
--			7,
--			@step,
--			'End of [release19_update_7j_ROI_promotions_input_RAS]',
--			SYSDATETIME()
--		)

END


