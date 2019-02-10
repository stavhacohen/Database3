-- =============================================
-- Author:		Dylan Goldsborough & Jesper de Groot
-- Create date: 2018-02-27
-- Description:	Creates fact_performance and dim-tables
-- =============================================
CREATE PROCEDURE [dbo].[update_9_create_fact_performance]
    @run_nr INT, @run_date DATE
AS
BEGIN

DECLARE @step INT = 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			8,
			@step,
			'Start of [update_9_create_fact_performance]',
			SYSDATETIME()
		)

/* Write old data from 'fact_performance' to a back-up table */
TRUNCATE TABLE promotions.fact_performance_last_update;
INSERT INTO promotions.fact_performance_last_update
SELECT	  *
FROM		  promotions.fact_performance;

DELETE
FROM promotions.fact_performance

DECLARE @updateid UNIQUEIDENTIFIER = NEWID()
DECLARE @maxdate date = (SELECT	  MAX(transactiondate)
						  FROM		  PG_input_RAS)

SET IDENTITY_INSERT [promotions].[dim_promotion] ON



DELETE
FROM promotions.dim_promotion
WHERE id_promotion <> 0

INSERT INTO promotions.dim_promotion (
	meta_valid_from
	,meta_valid_to
	,meta_id_update
	,meta_loaded
	,meta_loaded_by
	,id_promotion
	,promotion_start
	,NAME
	,business_id
	,universal_id--Added (Also to table using: ALTER TABLE [promotions].[dim_promotion] ADD [universal_id] [bigint] )
	,folder
	)
SELECT CURRENT_TIMESTAMP meta_valid_from
	,'9999-12-31 00:00:00.000' meta_valid_to
	,@updateid
	,CURRENT_TIMESTAMP
	,CURRENT_USER
	,ROW_NUMBER() OVER (
		ORDER BY a.PromotionNumber, a.PromotionStartDate
		) id
     ,a.PromotionStartDate
	,ISNULL(a.PromotionDesc, 'Unknown')
	,a.PromotionNumber
	,a.PromotionNumberUNV--ADDED as part of release #19
	,a.folder
FROM (
	SELECT DISTINCT PromotionNumber
		,PromotionNumberUNV --ADDED as part of release #19
		,PromotionStartDate 
		,folder
		,PromotionDesc
	FROM PG_input_RAS WHERE TransactionDate <= @maxdate
	) a

SET IDENTITY_INSERT [promotions].[dim_promotion] OFF
SET IDENTITY_INSERT [promotions].[dim_place_in_store] ON

DELETE
FROM promotions.dim_place_in_store
WHERE id_place_in_store <> 0

INSERT INTO promotions.dim_place_in_store (
	meta_valid_from
	,meta_valid_to
	,meta_id_update
	,meta_loaded
	,meta_loaded_by
	,id_place_in_store
	,NAME
	)
SELECT CURRENT_TIMESTAMP meta_valid_from
	,'9999-12-31 00:00:00.000' meta_valid_to
	,@updateid
	,CURRENT_TIMESTAMP
	,CURRENT_USER
	,ROW_NUMBER() OVER (
		ORDER BY place_in_store
		) id
	,place_in_store
FROM (
	SELECT DISTINCT Place_in_store
	FROM PG_input_RAS WHERE TransactionDate <= @maxdate 
	) a

SET IDENTITY_INSERT [promotions].[dim_place_in_store] OFF
SET IDENTITY_INSERT [promotions].[dim_format] ON

DELETE
FROM promotions.dim_format
WHERE id_format <> 0

INSERT INTO promotions.dim_format (
	meta_valid_from
	,meta_valid_to
	,meta_id_update
	,meta_loaded
	,meta_loaded_by
	,id_format
	,name_EN
	,name_HE
	)
SELECT CURRENT_TIMESTAMP meta_valid_from
	,'9999-12-31 00:00:00.000' meta_valid_to
	,@updateid
	,CURRENT_TIMESTAMP
	,CURRENT_USER
	,ROW_NUMBER() OVER (
		ORDER BY Branch_name_EN
		) id
	,Branch_name_EN
	,Branch_name_EN
FROM (
	SELECT DISTINCT Branch_name_EN
	FROM PG_input_RAS WHERE TransactionDate <= @maxdate 
	) a

SET IDENTITY_INSERT [promotions].[dim_format] OFF
SET IDENTITY_INSERT [promotions].[dim_promotion_type] ON

DELETE
FROM promotions.dim_promotion_type
WHERE id_promotion_type <> 0

INSERT INTO promotions.dim_promotion_type (
	meta_valid_from
	,meta_valid_to
	,meta_id_update
	,meta_loaded
	,meta_loaded_by
	,id_promotion_type
	,NAME
	)
SELECT CURRENT_TIMESTAMP meta_valid_from
	,'9999-12-31 00:00:00.000' meta_valid_to
	,@updateid
	,CURRENT_TIMESTAMP
	,CURRENT_USER
	,ROW_NUMBER() OVER (
		ORDER BY Promotion_type
		) id
	,Promotion_type
FROM (
	SELECT DISTINCT Promotion_type
	FROM PG_input_RAS WHERE TransactionDate <= @maxdate 
	) a

SET IDENTITY_INSERT [promotions].[dim_promotion_type] OFF
SET IDENTITY_INSERT [promotions].[dim_date] ON

DELETE
FROM promotions.dim_date
WHERE id_date <> 0

INSERT INTO promotions.dim_date (
	meta_valid_from
	,meta_valid_to
	,meta_id_update
	,meta_loaded
	,meta_loaded_by
	,id_date
	,[date]
	,[month]
	,[quarter]
	,[week]
	,[year]
	)
SELECT CURRENT_TIMESTAMP meta_valid_from
	,'9999-12-31 00:00:00.000' meta_valid_to
	,@updateid
	,CURRENT_TIMESTAMP
	,CURRENT_USER
	,id
	,[date]
	,MONTH([date])
	,DATEPART(QUARTER, [date])
	,DATEPART(WEEK, [date])
	,YEAR([date])
FROM (
	SELECT *
	FROM input.calendar
	) a

SET IDENTITY_INSERT [promotions].[dim_date] OFF
SET IDENTITY_INSERT [promotions].[dim_campaign] ON

DELETE
FROM [promotions].[dim_campaign]
WHERE id_campaign <> 0

INSERT INTO [promotions].[dim_campaign] (
	meta_valid_from
	,meta_valid_to
	,meta_id_update
	,meta_loaded
	,meta_loaded_by
	,id_campaign
	,business_id
	,NAME
	)
SELECT CURRENT_TIMESTAMP meta_valid_from
	,'9999-12-31 00:00:00.000' meta_valid_to
	,@updateid
	,CURRENT_TIMESTAMP
	,CURRENT_USER
	,ROW_NUMBER() OVER (
		ORDER BY a.CampaignNumberPromo
		) id
     ,a.CampaignNumberPromo
	,ISNULL(a.CampaignDesc, 'Unknown')
FROM (
	SELECT CampaignNumberPromo
		,MIN(CampaignDesc) as CampaignDesc
	FROM PG_input_RAS WHERE TransactionDate<= @maxdate
	GROUP BY CampaignNumberPromo
	) a

SET IDENTITY_INSERT [promotions].[dim_campaign] OFF
SET IDENTITY_INSERT [promotions].[dim_product] ON

DELETE
FROM promotions.dim_product
WHERE id_product <> 0

INSERT INTO promotions.dim_product (
	meta_valid_from
	,meta_valid_to
	,meta_id_update
	,meta_loaded
	,meta_loaded_by
	,id_product
	,NAME
	,business_id
	)
SELECT CURRENT_TIMESTAMP meta_valid_from
	,'9999-12-31 00:00:00.000' meta_valid_to
	,@updateid
	,CURRENT_TIMESTAMP
	,CURRENT_USER
	,ROW_NUMBER() OVER (
		ORDER BY ProductNumber
		) id
	,Product_name_HE
	,ProductNumber
FROM (
	SELECT DISTINCT ProductNumber
		,Product_name_HE
	FROM PG_input_RAS WHERE TransactionDate <= @maxdate 
	) a

SET IDENTITY_INSERT [promotions].[dim_product] OFF
SET IDENTITY_INSERT [promotions].[dim_product_category_type] ON

DELETE
FROM promotions.dim_product_category_type
WHERE id_product_category_type <> 0

INSERT INTO promotions.dim_product_category_type (
	meta_valid_from
	,meta_valid_to
	,meta_id_update
	,meta_loaded
	,meta_loaded_by
	,id_product_category_type
	,NAME
	)
SELECT CURRENT_TIMESTAMP meta_valid_from
	,'9999-12-31 00:00:00.000' meta_valid_to
	,@updateid
	,CURRENT_TIMESTAMP
	,CURRENT_USER
	,id
	,NAME
FROM (
	SELECT *
	FROM input.product_category_type
	) a

SET IDENTITY_INSERT [promotions].[dim_product_category_type] OFF

IF OBJECT_ID('tempdb.#categories2', 'U') IS NOT NULL
	DROP TABLE #categories2

SELECT DISTINCT [Department_name_EN]
	,[Category_name_HE]	AS [Category_name_EN] 		 -- JA: aangepast naar Category_name_HE omdat Category_name_EN niet altijd gevuld is
 	,[Group_name_HE]
	,[Subgroup_name_HE]
INTO #categories2
FROM PG_input_RAS WHERE TransactionDate <= @maxdate 

SET IDENTITY_INSERT [promotions].[dim_product_category] ON

DELETE
FROM promotions.dim_product_category
WHERE id_product_category <> 0

INSERT INTO promotions.dim_product_category (
	meta_valid_from
	,meta_valid_to
	,meta_id_update
	,meta_loaded
	,meta_loaded_by
	,id_product_category
	,parent_id
	,product_category_type_id
	,name_EN
	,name_HE
	)
SELECT CURRENT_TIMESTAMP meta_valid_from
	,'9999-12-31 00:00:00.000' meta_valid_to
	,@updateid
	,CURRENT_TIMESTAMP
	,CURRENT_USER
	,ROW_NUMBER() OVER (
		ORDER BY NAME
		) id
	,- 1
	,1
	,NAME
	,NAME
FROM (
	SELECT DISTINCT Department_name_EN AS NAME
	FROM #categories2
	) a

INSERT INTO promotions.dim_product_category (
	meta_valid_from
	,meta_valid_to
	,meta_id_update
	,meta_loaded
	,meta_loaded_by
	,id_product_category
	,parent_id
	,product_category_type_id
	,name_EN
	,name_HE
	)
SELECT CURRENT_TIMESTAMP meta_valid_from
	,'9999-12-31 00:00:00.000' meta_valid_to
	,@updateid
	,CURRENT_TIMESTAMP
	,CURRENT_USER
	,(
		SELECT MAX(id_product_category)
		FROM promotions.dim_product_category
		) + ROW_NUMBER() OVER (
		ORDER BY NAME
		) id
	,b.id_product_category
	,3
	,NAME
	,NAME
FROM (
	SELECT DISTINCT Category_name_EN AS NAME
		,Department_name_EN AS parent
	FROM #categories2
	) a
LEFT JOIN promotions.dim_product_category b ON a.parent = b.name_EN

INSERT INTO promotions.dim_product_category (
	meta_valid_from
	,meta_valid_to
	,meta_id_update
	,meta_loaded
	,meta_loaded_by
	,id_product_category
	,parent_id
	,product_category_type_id
	,name_EN
	,name_HE
	)
SELECT CURRENT_TIMESTAMP meta_valid_from
	,'9999-12-31 00:00:00.000' meta_valid_to
	,@updateid
	,CURRENT_TIMESTAMP
	,CURRENT_USER
	,(
		SELECT MAX(id_product_category)
		FROM promotions.dim_product_category
		) + ROW_NUMBER() OVER (
		ORDER BY NAME
		) id
	,b.id_product_category
	,4
	,NAME
	,NAME
FROM (
	SELECT DISTINCT Group_name_HE AS NAME
		,Category_name_EN AS parent
	FROM #categories2
	) a
LEFT JOIN promotions.dim_product_category b ON a.parent = b.name_EN

INSERT INTO promotions.dim_product_category (
	meta_valid_from
	,meta_valid_to
	,meta_id_update
	,meta_loaded
	,meta_loaded_by
	,id_product_category
	,parent_id
	,product_category_type_id
	,name_EN
	,name_HE
	)
SELECT CURRENT_TIMESTAMP meta_valid_from
	,'9999-12-31 00:00:00.000' meta_valid_to
	,@updateid
	,CURRENT_TIMESTAMP
	,CURRENT_USER
	,(
		SELECT MAX(id_product_category)
		FROM promotions.dim_product_category
		) + ROW_NUMBER() OVER (
		ORDER BY NAME
		) id
	,b.id_product_category
	,5
	,NAME
	,NAME
FROM (
	SELECT DISTINCT Subgroup_name_HE AS NAME
		,Group_name_HE AS parent
	FROM #categories2
	) a
LEFT JOIN promotions.dim_product_category b ON a.parent = b.name_EN

SET IDENTITY_INSERT [promotions].[dim_product_category] OFF
SET IDENTITY_INSERT [promotions].[dim_promotion_segment] ON

DELETE
FROM promotions.dim_promotion_segment
WHERE id_promotion_segment <> 0

INSERT INTO promotions.dim_promotion_segment (
	meta_valid_from
	,meta_valid_to
	,meta_id_update
	,meta_loaded
	,meta_loaded_by
	,id_promotion_segment
	,NAME
	)
SELECT CURRENT_TIMESTAMP meta_valid_from
	,'9999-12-31 00:00:00.000' meta_valid_to
	,@updateid
	,CURRENT_TIMESTAMP
	,CURRENT_USER
	,1
	,'winner'

UNION

SELECT CURRENT_TIMESTAMP meta_valid_from
	,'9999-12-31 00:00:00.000' meta_valid_to
	,@updateid
	,CURRENT_TIMESTAMP
	,CURRENT_USER
	,2
	,'diamond'

UNION

SELECT CURRENT_TIMESTAMP meta_valid_from
	,'9999-12-31 00:00:00.000' meta_valid_to
	,@updateid
	,CURRENT_TIMESTAMP
	,CURRENT_USER
	,3
	,'potential winner'

UNION

SELECT CURRENT_TIMESTAMP meta_valid_from
	,'9999-12-31 00:00:00.000' meta_valid_to
	,@updateid
	,CURRENT_TIMESTAMP
	,CURRENT_USER
	,4
	,'grey herd'

UNION

SELECT CURRENT_TIMESTAMP meta_valid_from
	,'9999-12-31 00:00:00.000' meta_valid_to
	,@updateid
	,CURRENT_TIMESTAMP
	,CURRENT_USER
	,5
	,'bleeder'

UNION

SELECT CURRENT_TIMESTAMP meta_valid_from
	,'9999-12-31 00:00:00.000' meta_valid_to
	,@updateid
	,CURRENT_TIMESTAMP
	,CURRENT_USER
	,6
	,'margin killer'

SET IDENTITY_INSERT [promotions].[dim_promotion_segment] OFF

ALTER TABLE promotions.fact_performance NOCHECK CONSTRAINT all

TRUNCATE TABLE promotions.fact_performance

INSERT INTO promotions.fact_performance (
	[measure_revenue_value_effect]
	,[measure_r9_discarded_products]
	,[measure_r8_hoarding]
	,[measure_r7_product_adoption]
	,[measure_r6_new_customer]
	,[measure_r5_promobuyer_new]
	,[measure_r4_promobuyer_existing]
	,[measure_r3_subs_group]
	,[measure_r2_subs_promo]
	,[measure_r1_promotion]
	,[measure_margin_value_effect]
	,[measure_m9_discarded_products]
	,[measure_m8_hoarding]
	,[measure_m7_product_adoption]
	,[measure_m6_new_customer]
	,[measure_m5_promobuyer_new]
	,[measure_m4_promobuyer_existing]
	,[measure_m3_subs_group]
	,[measure_m2_subs_promo]
	,[measure_m1_promotion]
	,[measure_kpi_supplier_participation_per_product]
	,[measure_kpi_selling_price]
	,[measure_kpi_regular_price_per_product]
	,[measure_kpi_regular_margin_per_product]
	,[measure_kpi_promotion_price_per_product]
	,[measure_kpi_promotion_margin_per_product]
	,[measure_kpi_promotion_customers]
	,[measure_kpi_number_customers]
	,[measure_kpi_new_customers]
	,[measure_kpi_discount]
	,[measure_kpi_bruto_uplift_revenue]
	,[measure_kpi_total_supplier_participation]
	,[measure_kpi_adopting_customers]
	,[measure_kpi_netto_uplift_revenue]
	,[measure_kpi_bruto_uplift_margin]
	,[measure_kpi_netto_uplift_margin]
	,[id_promotion_type]
	,[id_product_category]
	,[id_place_in_store]
	,[id_kpi_promotion_segment]
	,[id_campaign]
	,[id_meta_load_date]
	,[measure_length]
	,[measure_quantity_real]
	,[measure_quantity_baseline]
	,[id_date]
	,[id_promotion]
	,[id_product]
	,[id_format]
	,[id_promotion_start]
	,[id_promotion_end]
	,[id_date_last_year]
	,[id_date_next_year]
	)
SELECT SUM(revenue_value_effect)
	,0
	,SUM(Revenue_8_hoarding)
	,SUM(Revenue_7_product_adoption)
	,SUM(Revenue_6_new_customer)
	,SUM(Revenue_5_promobuyer_new)
	,SUM(Revenue_4_promobuyer_existing)
	,SUM(Revenue_3_subs_group)
	,SUM(Revenue_2_subs_promo)
	,SUM(Revenue_1_promotion)
	,SUM(Margin_value_effect)
	,0
	,SUM(Margin_8_hoarding)
	,SUM(Margin_7_product_adoption)
	,SUM(Margin_6_new_customer)
	,SUM(Margin_5_promobuyer_new)
	,SUM(Margin_4_promobuyer_existing)
	,SUM(Margin_3_subs_group)
	,SUM(Margin_2_subs_promo)
	,SUM(Margin_1_promotion)
	,SUM([Supplier_participation_per_product])
	,SUM([selling_price])
	,SUM([regular_price_per_product])
	,SUM([regular_margin_per_product])
	,SUM([promotion_price_per_product])
	,SUM([promotion_margin_per_product])
	,SUM([promotion_customers])
	,SUM([number_customers])
	,SUM([new_customers])
	,SUM([discount])
	,CASE 
		WHEN SUM(Revenue_2_subs_promo) <> 0
			THEN SUM(Revenue_1_promotion) / - SUM(Revenue_2_subs_promo)
		ELSE NULL
		END [bruto uplift revenue]
	,SUM([Total_supplier_participation])
	,SUM([adopting_customers])
	,CASE 
		WHEN SUM(Revenue_2_subs_promo) <> 0
			THEN (SUM(Revenue_value_effect) - SUM(Revenue_2_subs_promo)) / - SUM(Revenue_2_subs_promo)
		ELSE NULL
		END [netto uplift revenue]
	,SUM(Margin_1_promotion) - SUM(Margin_2_subs_promo) [bruto uplift margin]
	,CASE 
		WHEN SUM(Margin_2_subs_promo) <> 0
			THEN (SUM(Margin_value_effect) - SUM(Margin_2_subs_promo)) / - SUM(Margin_2_subs_promo)
		ELSE NULL
		END [netto uplift margin]
	,MAX(dimprtyp.id_promotion_type) [id_promotion_type]
	,MAX(dimprcat.id_product_category) [id_product_category]
	,MAX(ISNULL(dimpis.id_place_in_store, 0)) [id_place_in_store]
	,MAX(CAST(LEFT(Promotion_segment, 1) AS INT)) [id_kpi_promotion_segment]
	--WAS:,0 [id_campaign] -- campaign is leeg
	,dimcamp.id_campaign [id_campaign] --added releases 19
	,0 -- dummy
	,MAX([length])
	,SUM(real_quantity)
	,SUM(baseline_quantity)
	,dimdate.id_date [id_date]
	,dimprom.id_promotion [id_promotion]
	,dimprod.id_product [id_product]
	,dimformat.id_format [id_format]
	,ISNULL(pstart.id_date, 0) [id_promotion_start]
	,ISNULL(pend.id_date, 0) [id_promotion_end] -- fix if annoying
	,ISNULL(dim_last_year.id_date, 0)
	,ISNULL(dim_next_year.id_date, 0)
FROM PG_input_RAS  a
LEFT JOIN promotions.dim_date dimdate ON dimdate.[date] = a.TransactionDate
LEFT JOIN promotions.dim_promotion dimprom ON dimprom.business_id = a.PromotionNumber
								    AND dimprom.promotion_start = a.PromotionStartDate
LEFT JOIN promotions.dim_campaign dimcamp ON dimcamp.business_id = a.CampaignNumberPromo-- NEW join for campaign release 19
LEFT JOIN promotions.dim_product dimprod ON dimprod.business_id = a.ProductNumber
LEFT JOIN promotions.dim_format dimformat ON dimformat.name_EN = a.Branch_name_EN
LEFT JOIN (
--WAS(before fixing wrong depratment issue)
	--SELECT MAX(id_product_category) id_product_category
	--	,name_HE
	--FROM promotions.dim_product_category
	--GROUP BY name_HE
	--) dimprcat ON dimprcat.name_HE = a.Subgroup_name_HE

--Now(after fixing fixing wrong depratment issue)
	SELECT MAX(r.id_product_category) id_product_category
	,r.name_HE,MAX(r.parent_id) parent_id ,t.name_HE parent_name
	FROM promotions.dim_product_category r
	left join promotions.dim_product_category t on r.parent_id=t.id_product_category
	where r.product_category_type_id=5
	GROUP BY r.name_HE,t.name_HE
) dimprcat ON dimprcat.name_HE = a.Subgroup_name_HE and dimprcat.parent_name = a.Group_name_HE
--End of fixing department^

LEFT JOIN promotions.dim_promotion_type dimprtyp ON dimprtyp.NAME = a.Promotion_type
LEFT JOIN promotions.dim_place_in_store dimpis ON dimpis.NAME = a.Place_in_store
LEFT JOIN promotions.dim_date pstart ON pstart.[date] = a.PromotionStartDate
LEFT JOIN promotions.dim_date pend ON pend.[date] = a.PromotionEndDate
LEFT JOIN (
	SELECT date_2017 later
		,date_2016 earlier
	FROM [Shufersal].[dbo].[Staging_Hebrew_calendar]
	
	UNION
	
	SELECT date_2016 later
		,date_2015 earlier
	FROM [Shufersal].[dbo].[Staging_Hebrew_calendar]
	
	UNION
	
	SELECT date_2015 later
		,date_2014 earlier
	FROM [Shufersal].[dbo].[Staging_Hebrew_calendar]
	) last_year ON last_year.later = a.TransactionDate
LEFT JOIN promotions.dim_date dim_last_year ON dim_last_year.[date] = last_year.earlier
LEFT JOIN (
	SELECT date_2017 later
		,date_2016 earlier
	FROM [Shufersal].[dbo].[Staging_Hebrew_calendar]
	
	UNION
	
	SELECT date_2016 later
		,date_2015 earlier
	FROM [Shufersal].[dbo].[Staging_Hebrew_calendar]
	
	UNION
	
	SELECT date_2015 later
		,date_2014 earlier
	FROM [Shufersal].[dbo].[Staging_Hebrew_calendar]
	) next_year ON next_year.earlier = a.TransactionDate
LEFT JOIN promotions.dim_date dim_next_year ON dim_next_year.[date] = next_year.later
WHERE TransactionDate <= @maxdate 
AND a.promotion_type IN (SELECT name FROM promotions.dim_promotion_type
    WHERE id_promotion_type <> 0)
GROUP BY dimdate.id_date
	,dimprom.id_promotion
	,dimprod.id_product
	,dimformat.id_format
	,dimcamp.id_campaign -- added release 19
	,ISNULL(pstart.id_date, 0)
	,ISNULL(pend.id_date, 0)
	,dim_last_year.id_date
	,dim_next_year.id_date

print 'promotions.fact_performance'
ALTER TABLE promotions.fact_performance WITH CHECK CHECK CONSTRAINT all

SET		  @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			8,
			@step,
			'End of [update_9_create_fact_performance]',
			SYSDATETIME()
		)

END
