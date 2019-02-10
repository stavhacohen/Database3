
-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-19
-- Description:	Generates input data for RAS
-- =============================================
CREATE PROCEDURE [dbo].[update_7k_ROI_promotions_input_ROI_explorer]
    @run_nr INT = 150,
    @run_date DATE = '2019-01-06',
    @step INT = 1,
    @start_date_expl DATE = '2017-11-26',
    @end_date_expl DATE = '2018-11-26'
AS
BEGIN

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Start of [update_7k_ROI_promotions_input_ROI_explorer]',
			SYSDATETIME()
		)

-- Creates table as input for ROI Explorer tab 'Promotions'
IF OBJECT_ID('tempdb.dbo.#ROI_input_ROI_explorer_promotions','U') IS NOT NULL
    DROP TABLE #ROI_input_ROI_explorer_promotions
SELECT	  ro.PromotionNumber,
		Case when len(ro.PromotionNumber) >8 then left(ro.PromotionNumber,len(ro.PromotionNumber)-3) else ro.PromotionNumber END PromotionNumberOriginal,
		  PromotionCharacteristicsType,
		  PromotionNumberUnv,
		  PromotionDesc,
		  PromotionStartDate,
		  PromotionEndDate,
		  dt.year,
		  dt.yearmonth,
		  dt.yearweek,
		  DATEDIFF(day,PromotionStartDate,PromotionEndDate)+1 AS 'Length',
		  SUM(Real_quantity) AS 'Sold_quantity',
		  SUM(Baseline_quantity) AS 'Baseline_quantity',
		  CASE WHEN SUM(Baseline_quantity) = 0 THEN NULL
			  ELSE SUM(Real_quantity)/SUM(Baseline_quantity) END AS 'Uplift',
		  CASE WHEN MAX(Department_name_EN) = MIN(Department_name_EN) THEN MAX(Department_name_EN) ELSE NULL END AS 'Department_name_EN',
		  CASE WHEN MAX(Department_name_EN) = MIN(Department_name_EN) THEN MAX(Department_name_HE) ELSE NULL END AS 'Department_name_HE',
		  CASE WHEN MAX(Subdepartment_name_EN) = MIN(Subdepartment_name_EN) THEN MAX(Subdepartment_name_EN) ELSE NULL END AS 'Subdepartment_name_EN',
		  CASE WHEN MAX(Subdepartment_name_EN) = MIN(Subdepartment_name_EN) THEN MAX(Subdepartment_name_HE) ELSE NULL END AS 'Subdepartment_name_HE',
		  CASE WHEN MAX(Category_name_EN) = MIN(Category_name_EN) THEN MAX(Category_name_EN) ELSE NULL END AS 'Category_name_EN',
		  CASE WHEN MAX(Category_name_EN) = MIN(Category_name_EN) THEN MAX(Category_name_HE) ELSE NULL END AS 'Category_name_HE',
		  SUM(Revenue_value_effect) AS 'Revenue_value_effect',
		  SUM(Margin_value_effect) AS 'Margin_value_effect',
		  SUM(Revenue_1_promotion) AS 'Revenue_1_promotion',
		  SUM(Revenue_2_subs_promo) AS 'Revenue_2_subs_promo',
		  SUM(Revenue_3_subs_group) AS 'Revenue_3_subs_group',
		  SUM(Revenue_4_promobuyer_existing) AS 'Revenue_4_promobuyer_existing',
		  SUM(Revenue_5_promobuyer_new) AS 'Revenue_5_promobuyer_new',
		  SUM(Revenue_6_new_customer) AS 'Revenue_6_new_customer',
		  SUM(Revenue_7_product_adoption) AS 'Revenue_7_product_adoption',
		  SUM(Revenue_8_hoarding) AS 'Revenue_8_hoarding',
		  SUM(Margin_1_promotion) AS 'Margin_1_promotion',
		  SUM(Margin_2_subs_promo) AS 'Margin_2_subs_promo',
		  SUM(Margin_3_subs_group) AS 'Margin_3_subs_group',
		  SUM(Margin_4_promobuyer_existing) AS 'Margin_4_promobuyer_existing',
		  SUM(Margin_5_promobuyer_new) AS 'Margin_5_promobuyer_new',
		  SUM(Margin_6_new_customer) AS 'Margin_6_new_customer',
		  SUM(Margin_7_product_adoption) AS 'Margin_7_product_adoption',
		  SUM(Margin_8_hoarding) AS 'Margin_8_hoarding',
		  CASE WHEN SUM(CASE WHEN ro.Branch_name_EN = 'Deal' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'Deal',
		  CASE WHEN SUM(CASE WHEN ro.Branch_name_EN = 'Extra' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'Extra',
		  CASE WHEN SUM(CASE WHEN ro.Branch_name_EN = 'Express' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'Express',
		  CASE WHEN SUM(CASE WHEN ro.Branch_name_EN = 'Sheli' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'Sheli',
		  CASE WHEN SUM(CASE WHEN ro.Branch_name_EN = 'Organic' THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'Organic',
		  MAX(DiscountType) AS 'DiscountType', --!!! Fix
		  Promotion_segment,
		  Place_in_store,
		  Folder,
		  Multibuy_quantity,
		  CASE WHEN SUM(Ind_in_plan * Real_quantity * Baseline_quantity * Revenue_2_subs_promo) = 0 THEN NULL
			  ELSE 1 - (SUM(Ind_in_plan*Revenue_1_promotion)/SUM(Ind_in_plan*Real_quantity)) / (-SUM(Ind_in_plan*Revenue_2_subs_promo)/SUM(Ind_in_plan*Baseline_quantity)) END AS 'Discount',
		  CASE WHEN CASE WHEN SUM(Ind_in_plan * Real_quantity * Baseline_quantity * Revenue_2_subs_promo) = 0 THEN NULL
			  ELSE 1 - (SUM(Ind_in_plan*Revenue_1_promotion)/SUM(Ind_in_plan*Real_quantity)) / (-SUM(Ind_in_plan*Revenue_2_subs_promo)/SUM(Ind_in_plan*Baseline_quantity)) END IS NULL THEN NULL
			  WHEN CASE WHEN SUM(Ind_in_plan * Real_quantity * Baseline_quantity * Revenue_2_subs_promo) = 0 THEN NULL
			  ELSE 1 - (SUM(Ind_in_plan*Revenue_1_promotion)/SUM(Ind_in_plan*Real_quantity)) / (-SUM(Ind_in_plan*Revenue_2_subs_promo)/SUM(Ind_in_plan*Baseline_quantity)) END <= 0.1 THEN '1. < 10%'
			  WHEN CASE WHEN SUM(Ind_in_plan * Real_quantity * Baseline_quantity * Revenue_2_subs_promo) = 0 THEN NULL
			  ELSE 1 - (SUM(Ind_in_plan*Revenue_1_promotion)/SUM(Ind_in_plan*Real_quantity)) / (-SUM(Ind_in_plan*Revenue_2_subs_promo)/SUM(Ind_in_plan*Baseline_quantity)) END <= 0.2 THEN '2. 10-20%'
			  WHEN CASE WHEN SUM(Ind_in_plan * Real_quantity * Baseline_quantity * Revenue_2_subs_promo) = 0 THEN NULL
			  ELSE 1 - (SUM(Ind_in_plan*Revenue_1_promotion)/SUM(Ind_in_plan*Real_quantity)) / (-SUM(Ind_in_plan*Revenue_2_subs_promo)/SUM(Ind_in_plan*Baseline_quantity)) END <= 0.3 THEN '3. 20-30%'
			  WHEN CASE WHEN SUM(Ind_in_plan * Real_quantity * Baseline_quantity * Revenue_2_subs_promo) = 0 THEN NULL
			  ELSE 1 - (SUM(Ind_in_plan*Revenue_1_promotion)/SUM(Ind_in_plan*Real_quantity)) / (-SUM(Ind_in_plan*Revenue_2_subs_promo)/SUM(Ind_in_plan*Baseline_quantity)) END <= 0.4 THEN '4. 30-40%'
			  ELSE '5. 40%+' END AS 'Discount_segment',
		  CASE WHEN SUM(Ind_in_plan * Real_quantity * Baseline_quantity * Revenue_2_subs_promo) = 0 THEN NULL
			  ELSE -SUM(Ind_in_plan*Revenue_2_subs_promo)/SUM(Ind_in_plan*Baseline_quantity)-SUM(Ind_in_plan*Revenue_1_promotion)/SUM(Ind_in_plan*Real_quantity) END AS 'Discount_in_ILS',
		  CASE WHEN SUM(CASE WHEN ro.IO_indicator = 'In/out' THEN 1 ELSE 0 END) >= 1 THEN 'In/out'
			  WHEN SUM(CASE WHEN ro.IO_indicator = 'In' THEN 1 ELSE 0 END) >= 1 THEN 'In'
				ELSE 'Out' END AS 'IO_indicator'
INTO		  #ROI_input_ROI_explorer_promotions
FROM		  PG_ROI_result_product_daily ro
INNER JOIN  PG_dim_date dt
ON		  dt.date = ro.PromotionStartDate
	   AND dt.date BETWEEN @start_date_expl AND @end_date_expl
GROUP BY	  ro.PromotionNumber,
Case when len(ro.PromotionNumber) >8 then left(ro.PromotionNumber,len(ro.PromotionNumber)-3) else ro.PromotionNumber END,
		  PromotionCharacteristicsType,
		  PromotionNumberUnv,
		  PromotionDesc,
		  PromotionStartDate,
		  PromotionEndDate,
		  dt.year,
		  dt.yearmonth,
		  dt.yearweek,
		  Promotion_segment,
		  Place_in_store,
		  Folder,
		  Multibuy_quantity

IF OBJECT_ID('tempdb.dbo.#promotions_brands_suppliers','U') IS NOT NULL
    DROP TABLE #promotions_brands_suppliers
SELECT	  ro.PromotionNumber,
		  MAX(ro.CampaignNumberPromo) AS 'CampaignNumberPromo',
		  MAX(ro.CampaignDesc) AS 'CampaignDesc',
		  CASE WHEN MAX(pa.Brand_name_HE) = MIN(pa.Brand_name_HE) THEN MAX(pa.Brand_name_HE) ELSE NULL END AS 'Brand_name',
		  CASE WHEN MAX(pa.Private_label) = MIN(pa.Private_label) THEN MAX(pa.Private_label) ELSE NULL END AS 'Private_label',
		  CASE WHEN MAX(pa.Category_manager_name_HE) = MIN(pa.Category_manager_name_HE) THEN MAX(pa.Category_manager_name_HE) ELSE NULL END AS 'Category_manager'
INTO		  #promotions_brands_suppliers
FROM		  PG_promotions ro
INNER JOIN  PG_product_assortment pa
ON		  pa.Product_ID = ro.ProductNumber
GROUP BY	  ro.PromotionNumber

IF OBJECT_ID('tempdb.dbo.#promotions__suppliers','U') IS NOT NULL
    DROP TABLE #promotions__suppliers
SELECT	  ro.PromotionNumber,
		  CASE WHEN MAX(pas.supplier) = MIN(pas.supplier) THEN MAX(pas.supplier) ELSE NULL END AS 'Supplier_ID'
INTO		  #promotions__suppliers
FROM		  PG_promotions ro
INNER JOIN  PG_supplier_assortment pas
ON		  ro.ProductNumber = pas.ProductNumber
	   AND ro.Branch_name_EN = pas.Branch_name_EN
GROUP BY	  ro.PromotionNumber

IF OBJECT_ID('dbo.PG_ROI_input_ROI_explorer_promotions','U') IS NOT NULL
    DROP TABLE PG_ROI_input_ROI_explorer_promotions
SELECT	  ro.[PromotionNumber]
	  ,[PromotionNumberOriginal]
	  ,[PromotionCharacteristicsType]
      ,[PromotionNumberUnv]
      ,[PromotionDesc]
      ,[PromotionStartDate]
      ,[PromotionEndDate]
      ,[year]
      ,[yearmonth]
      ,[yearweek]
      ,[Length]
      ,[Sold_quantity]
      ,[Baseline_quantity]
      ,[Uplift]
      ,[Department_name_EN]
      ,[Department_name_HE]
      ,[Subdepartment_name_EN]
      ,[Subdepartment_name_HE]
      ,[Category_name_EN]
      ,[Category_name_HE]
      ,[Revenue_value_effect]
      ,[Margin_value_effect]
      ,[Revenue_1_promotion]
      ,[Revenue_2_subs_promo]
      ,[Revenue_3_subs_group]
      ,[Revenue_4_promobuyer_existing]
      ,[Revenue_5_promobuyer_new]
      ,[Revenue_6_new_customer]
      ,[Revenue_7_product_adoption]
      ,[Revenue_8_hoarding]
      ,[Margin_1_promotion]
      ,[Margin_2_subs_promo]
      ,[Margin_3_subs_group]
      ,[Margin_4_promobuyer_existing]
      ,[Margin_5_promobuyer_new]
      ,[Margin_6_new_customer]
      ,[Margin_7_product_adoption]
      ,[Margin_8_hoarding]
      ,[Deal]
      ,[Extra]
      ,[Express]
      ,[Sheli]
      ,[Organic]
      ,[DiscountType]
      ,[Promotion_segment]
      ,[Place_in_store]
      ,[Folder]
      ,[Multibuy_quantity]
      ,[Discount]
      ,[Discount_segment]
      ,[Discount_in_ILS]
	 ,IO_indicator
	,pr.CampaignNumberPromo,
		  pr.CampaignDesc,
		  pr.Brand_name,
		  pr.Private_label,
		  pr.Category_manager,
		  ps.Supplier_ID
INTO		  dbo.PG_ROI_input_ROI_explorer_promotions
FROM		  #ROI_input_ROI_explorer_promotions ro
LEFT JOIN   #promotions_brands_suppliers pr
ON		  ro.PromotionNumber = pr.PromotionNumber
left join #promotions__suppliers ps
ON		  ro.PromotionNumber = ps.PromotionNumber


SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Input for ROI Explorer tab Promotions calculated',
			SYSDATETIME()
		)

-- Creates table as input for ROI Explorer tab 'Promotion_product'
IF OBJECT_ID('dbo.PG_ROI_input_ROI_explorer_promotion_product','U') IS NOT NULL
    DROP TABLE PG_ROI_input_ROI_explorer_promotion_product
SELECT	  PromotionNumber,
		  ProductNumber
INTO		  dbo.PG_ROI_input_ROI_explorer_promotion_product
FROM		  PG_ROI_result_product_daily
WHERE	  PromotionStartDate BETWEEN @start_date_expl AND @end_date_expl
GROUP BY	  PromotionNumber,
		  ProductNumber
ORDER BY	  ProductNumber

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Input for ROI Explorer tab Promotion_product calculated',
			SYSDATETIME()
		)

-- Creates table as input for ROI Explorer tab 'Products'
IF OBJECT_ID('dbo.PG_ROI_input_ROI_explorer_products','U') IS NOT NULL
    DROP TABLE PG_ROI_input_ROI_explorer_products
SELECT	  ProductNumber,
		  Product_name_HE,
		  Category_name_HE,
		  Group_name_HE,
		  Subgroup_name_HE
INTO		  dbo.PG_ROI_input_ROI_explorer_products
FROM		  PG_ROI_result_product_daily
WHERE	  PromotionStartDate BETWEEN @start_date_expl AND @end_date_expl
GROUP BY	  ProductNumber,
		  Product_name_HE,
		  Category_name_HE,
		  Group_name_HE,
		  Subgroup_name_HE

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Input for ROI Explorer tab Products calculated',
			SYSDATETIME()
		)

-- Creates table as input for ROI Explorer tab 'Suppliers'
IF OBJECT_ID('dbo.PG_ROI_input_ROI_explorer_suppliers','U') IS NOT NULL
    DROP TABLE PG_ROI_input_ROI_explorer_suppliers
SELECT	  Supplier_ID,
		  Supplier_name_HE
INTO		  dbo.PG_ROI_input_ROI_explorer_suppliers
FROM		  Staging_assortment_supplier
GROUP BY	  Supplier_ID,
		  Supplier_name_HE

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Input for ROI Explorer tab Suppliers calculated',
			SYSDATETIME()
		)

DROP TABLE  [Shufersal].[dbo].[PG_ROI_input_ROI_explorer_groceries_promotions]
SELECT	  *
INTO		  [Shufersal].[dbo].[PG_ROI_input_ROI_explorer_groceries_promotions]
FROM		  [Shufersal].[dbo].[PG_ROI_input_ROI_explorer_promotions]
WHERE	  Department_name_EN = 'Groceries'

DROP TABLE  [Shufersal].[dbo].[PG_ROI_input_ROI_explorer_groceries_promotion_product]
SELECT	  *
INTO		  [Shufersal].[dbo].[PG_ROI_input_ROI_explorer_groceries_promotion_product]
FROM		  [Shufersal].[dbo].[PG_ROI_input_ROI_explorer_promotion_product]
WHERE	  PromotionNumber IN (SELECT PromotionNumber FROM [Shufersal].[dbo].[PG_ROI_input_ROI_explorer_groceries_promotions])

DROP TABLE  [Shufersal].[dbo].[PG_ROI_input_ROI_explorer_groceries_products]
SELECT	  *
INTO		  [Shufersal].[dbo].[PG_ROI_input_ROI_explorer_groceries_products]
FROM		  [Shufersal].[dbo].[PG_ROI_input_ROI_explorer_products]
WHERE	  ProductNumber IN (SELECT ProductNumber FROM [Shufersal].[dbo].[PG_ROI_input_ROI_explorer_groceries_promotion_product])

DROP TABLE  [Shufersal].[dbo].[PG_ROI_input_ROI_explorer_groceries_suppliers]
SELECT	  *
INTO		  [Shufersal].[dbo].[PG_ROI_input_ROI_explorer_groceries_suppliers]
FROM		  [Shufersal].[dbo].[PG_ROI_input_ROI_explorer_suppliers]

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Input for ROI Explorer for Groceries calculated',
			SYSDATETIME()
		)

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'End of [update_7k_ROI_promotions_input_ROI_explorer]',
			SYSDATETIME()
		)

END

