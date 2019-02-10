-- =============================================
-- Author:		Gal Naamani
-- Create date:	2018-12-13
-- Description:	Updates Supplier list + Catalog prices
-- =============================================
CREATE PROCEDURE [dbo].[Supplier_update_2_Update_Retro_effects]
    @run_nr INT = 1,
    @step INT = 1,
    @run_date DATE = '2017-10-10',
	@start_date_1_5 DATE = '2018-06-01',
	@end_date_1_5 DATE = '2018-06-30',
	@after_days INT = 28
AS
BEGIN

INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			2,
			@step,
			'Start of [Supplier_update_2_Update_Retro_effects]',
			SYSDATETIME()
		)

DECLARE @p1 FLOAT;
DECLARE @p2 FLOAT;
DECLARE @p3 FLOAT;
DECLARE @p4 FLOAT;
DECLARE @p5 FLOAT;
DECLARE @p6 FLOAT;
DECLARE @p7 FLOAT;
DECLARE @p8 FLOAT;
DECLARE @p9 FLOAT;
DECLARE @p10 FLOAT;
DECLARE @p11 FLOAT;
DECLARE @p0 FLOAT;
/**********************************************STEP 1 : Preperations**********************************************/

/*Take Promotions that ended within 28 days from our start date (those are the promotions that were updated with retro effects)*/
IF OBJECT_ID('tempdb..#temp_input_RAS_2Months' ,'U') IS NOT NULL
    DROP TABLE #temp_input_RAS_2Months;
SELECT t1.*
INTO #temp_input_RAS_2Months
FROM dbo.PG_input_RAS_Wave1_5 t1
WHERE PromotionEndDate<@start_date_1_5 AND PromotionEndDate>=DATEADD(day,-@after_days,@start_date_1_5)

SELECT @p0=COUNT(*),
	   @p3=SUM(Revenue_value_effect)
FROM #temp_input_RAS_2Months
	
SELECT @p2=count(*)
FROM (SELECT DISTINCT *
	  FROM #temp_input_RAS_2Months) m

SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			2,
			@step,
			'Step 1: Row count='  + STR(@p0,10,6) + ', Distinct Row count='  + STR(@p2,10,6) + ', Sum RVE='  + STR(@p3,10,6),
			SYSDATETIME()
		)
/**********************************************Step 2 : ADD Quantities of stuff to RAS_input for later adding the SI/SO table**********************************************/

--Add Quantities for adoption and hording (since it's the same product then we only need the quantities and later we will multiply by catalog price)
--Add new revenue of component 6 (new customers) as it was updated
IF OBJECT_ID('tempdb..#temp_input_RAS_2Months_2' ,'U') IS NOT NULL
    DROP TABLE #temp_input_RAS_2Months_2;
SELECT t1.*,
	   t4.Revenue_6_new_customer AS R6_2,
	   t4.Revenue_7_product_adoption AS R7_2,
	   t4.Revenue_8_hoarding AS R8_2,
	   t4.Revenue_Value_effect AS RVE_2,
	   t2.Quantity_7_product_adoption AS Q7_2,
	   t4.Margin_6_new_customer AS M6_2,
	   t4.Margin_7_product_adoption AS M7_2,
	   t4.Margin_8_hoarding AS M8_2,
	   t4.Margin_value_effect AS MVE_2,
	   SUM(t4.Margin_value_effect) OVER (PARTITION BY t4.promotionNumber) AS MVE_Pro_2,
	   t4.Promotion_segment AS Seg_2,
	   CASE WHEN t3.Quantity_8_hoarding>0 THEN 0 ELSE t3.Quantity_8_hoarding END AS Q8_2
INTO #temp_input_RAS_2Months_2
FROM #temp_input_RAS_2Months t1
LEFT JOIN dbo.PG_ROI_component_7 t2
ON t1.PromotionNumber=t2.PromotionNumber
AND t1.ProductNumber=t2.ProductNumber
AND t1.Branch_name_EN=t2.Branch_name_EN
AND t1.TransactionDate=t2.TransactionDate
AND t1.PromotionStartDate=t2.PromotionStartDate
AND t1.PromotionEndDate=t2.PromotionEndDate
AND t1.SourceInd=t2.SourceInd
LEFT JOIN dbo.PG_ROI_component_8 t3
ON t1.PromotionNumber=t3.PromotionNumber
AND t1.ProductNumber=t3.ProductNumber
AND t1.Branch_name_EN=t3.Branch_name_EN
AND t1.TransactionDate=t3.TransactionDate
AND t1.PromotionStartDate=t3.PromotionStartDate
AND t1.PromotionEndDate=t3.PromotionEndDate
AND t1.SourceInd=t3.SourceInd
LEFT JOIN dbo.PG_input_RAS t4
ON t1.PromotionNumber=t4.PromotionNumber --Just added the last one to make sure it's unique
AND t1.ProductNumber=t4.ProductNumber
AND t1.Branch_name_EN=t4.Branch_name_EN
AND t1.TransactionDate=t4.TransactionDate
AND t1.PromotionStartDate=t4.PromotionStartDate
AND t1.PromotionEndDate=t4.PromotionEndDate
AND t1.SourceInd=t4.SourceInd
AND ISNULL(t1.Subgroup_name_EN,'noName')=ISNULL(t4.Subgroup_name_EN,'noName')
		;

SELECT @p1=COUNT(*),
	   @p3=SUM(Revenue_value_effect)
FROM #temp_input_RAS_2Months_2
	
SELECT @p2=COUNT(*)
FROM (SELECT DISTINCT *
	  FROM #temp_input_RAS_2Months_2) m

SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			2,
			@step,
			'Step 2: Row count='  + STR(@p1,10,6) + ', Distinct Row count='  + STR(@p2,10,6) + ', Sum RVE='  + STR(@p3,10,6),
			SYSDATETIME()
		)

--*************************Step 3 : Change all revenues to Catalog prices revenues by multiplying with distributions*******************
IF OBJECT_ID('tempdb..#temp_input_RAS_2Months_3' ,'U') IS NOT NULL
    DROP TABLE #temp_input_RAS_2Months_3;
SELECT t1.*,
	   t1.R6_2*t2.catRev2Rev_Ratio*t3.perc_CatRev AS CatRev6_new,
	   t1.Q7_2*t1.CatalogPrice AS CatRev7_new,
	   CASE WHEN t1.Q8_2*t1.CatalogPrice<-t1.DistributedRealQuantity*t1.CatalogPrice THEN -t1.DistributedRealQuantity*t1.CatalogPrice 
			ELSE t1.Q8_2*t1.CatalogPrice 
			END AS CatRev8_new
INTO #temp_input_RAS_2Months_3
FROM #temp_input_RAS_2Months_2 t1
LEFT JOIN PG_Wave1_5_Catalog_revenue_ratio_tot t2
ON t2.Branch_name_EN=t1.Branch_name_EN
AND t2.SourceInd=t1.SourceInd
LEFT JOIN PG_Wave1_5_totalTransactions_supplier_dist t3
ON t3.supplier_ID=t1.supplier_ID
AND t3.sourceINd=t1.sourceind
AND t3.branch_name_en=t1.branch_name_en


SELECT @p1=COUNT(*),
	   @p3=SUM(Revenue_value_effect),
	   @p2=MIN(CatRev6_new-Revenue_6_new_customer_Cat),
	   @p4=AVG(CatRev6_new-Revenue_6_new_customer_Cat),
	   @p5=MAX(CatRev6_new-Revenue_6_new_customer_Cat),
	   @p6=MIN(CatRev7_new-Revenue_7_Product_adoption_Cat),
	   @p7=AVG(CatRev7_new-Revenue_7_Product_adoption_Cat),
	   @p8=MAX(CatRev7_new-Revenue_7_Product_adoption_Cat),
	   @p9=MIN(CatRev8_new-Revenue_8_hording_Cat),
	   @p10=AVG(CatRev8_new-Revenue_8_hording_Cat),
	   @p11=MAX(CatRev8_new-Revenue_8_hording_Cat)
FROM #temp_input_RAS_2Months_3

SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			2,
			@step,
			'Step 3: Row count='  + STR(@p1,10,6) + ', Sum RVE='  + STR(@p3,10,6) + ', min(CatRev6 diff)='  + STR(@p2,10,6),
			SYSDATETIME()
		)
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			2,
			@step,
			'Step 3: avg(CatRev6 diff)='  + STR(@p4,10,6) + ', max(CatRev6 diff)='  + STR(@p5,10,6) + ', min(CatRev7 diff)='  + STR(@p6,10,6),
			SYSDATETIME()
		)
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			2,
			@step,
			'Step 3: avg(CatRev7 diff)='  + STR(@p7,10,6) + ', max(CatRev7 diff)='  + STR(@p8,10,6) + ', min(CatRev8 diff)='  + STR(@p9,10,6),
			SYSDATETIME()
		)
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			2,
			@step,
			'Step 3: avg(CatRev8 diff)='  + STR(@p10,10,6) + ', max(CatRev8 diff)='  + STR(@p11,10,6),
			SYSDATETIME()
		)

--***************************Step 4 : Recalculate supplier segments**********************************************
IF OBJECT_ID('tempdb..#temp_input_RAS_2Months_4' ,'U') IS NOT NULL
    DROP TABLE #temp_input_RAS_2Months_4;
SELECT	t.PromotionNumber, t.Supplier_ID,
		SUM(ISNULL(t.Revenue_1_promotion_Cat,0)+ISNULL(t.Revenue_2_subs_promo_Cat,0)+ISNULL(t.Revenue_3_subs_group_Cat,0)+ISNULL(t.Revenue_4_promobuyer_existing_Cat,0)+ISNULL(t.Revenue_5_promobuyer_new,0)+ISNULL(ISNULL(t.CatRev6_new,t.Revenue_6_new_customer_Cat),0)+ISNULL(ISNULL(t.CatRev7_new,t.Revenue_7_Product_adoption_Cat),0)+ISNULL(ISNULL(t.CatRev8_new,t.Revenue_8_hording_Cat),0)) AS RevenueValueEffect,
		SUM(ISNULL(t.Tot_Participation,0)) as Tot_Participation,
		CASE WHEN SUM(ISNULL(t.Revenue_1_promotion_Cat,0)+ISNULL(t.Revenue_2_subs_promo_Cat,0)+ISNULL(t.Revenue_3_subs_group_Cat,0)+ISNULL(t.Revenue_4_promobuyer_existing_Cat,0)+ISNULL(t.Revenue_5_promobuyer_new,0)+ISNULL(ISNULL(t.CatRev6_new,t.Revenue_6_new_customer_Cat),0)+ISNULL(ISNULL(t.CatRev7_new,t.Revenue_7_Product_adoption_Cat),0)+ISNULL(ISNULL(t.CatRev8_new,t.Revenue_8_hording_Cat),0))=0 THEN '2. Lose'
			 WHEN SUM(ISNULL(t.Tot_Participation,0))=0 THEN '1. Win'
			 WHEN (SUM(ISNULL(t.Revenue_1_promotion_Cat,0)+ISNULL(t.Revenue_2_subs_promo_Cat,0)+ISNULL(t.Revenue_3_subs_group_Cat,0)+ISNULL(t.Revenue_4_promobuyer_existing_Cat,0)+ISNULL(t.Revenue_5_promobuyer_new,0)+ISNULL(ISNULL(t.CatRev6_new,t.Revenue_6_new_customer_Cat),0)+ISNULL(ISNULL(t.CatRev7_new,t.Revenue_7_Product_adoption_Cat),0)+ISNULL(ISNULL(t.CatRev8_new,t.Revenue_8_hording_Cat),0))/ABS(SUM(ISNULL(t.Tot_Participation,0))))>2 THEN '1. Win' 
			 ELSE '2. Lose' 
			 END AS Supplier_Segment
INTO #temp_input_RAS_2Months_4
FROM #temp_input_RAS_2Months_3 t
GROUP BY t.PromotionNumber, t.Supplier_ID

--format table to fit Input_Ras_WAVE1_5
IF OBJECT_ID('tempdb..#temp_input_RAS_2Months_5' ,'U') IS NOT NULL
    DROP TABLE #temp_input_RAS_2Months_5;
SELECT t.PromotionNumber,
	   t.PromotionCharacteristicsType,
       t.PromotionNumberUnv,
	   t.PromotionDesc,
	   t.CampaignNumberPromo,
	   t.CampaignDesc,
	   t.PromotionStartDate,
	   t.PromotionEndDate,
	   t.[Length],
	   t.ProductNumber,
	   t.Product_name_HE,
	   t.TransactionDate,
	   t.Branch_name_EN,
	   t.SourceInd,
	   t.Promotion_type,
	   t.Department_name_EN,
	   t.Department_name_HE,
	   t.Subdepartment_name_EN,
	   t.Subdepartment_name_HE,
	   t.Category_name_EN,
	   t.Category_name_HE,
	   t.Group_name_EN,
	   t.Group_name_HE,
	   t.Subgroup_name_EN,
	   t.Subgroup_name_HE,
	   t.Multibuy_quantity,
	   t.Place_in_store,
	   t.Folder,
	   t.Real_quantity,
	   t.Baseline_quantity,
	   t.Uplift,
	   t.Revenue_1_promotion,
	   t.Revenue_2_subs_promo,
	   t.Revenue_3_subs_group,
	   t.Revenue_4_promobuyer_existing,
	   t.Revenue_5_promobuyer_new,
	   t.R6_2 AS Revenue_6_new_customer,
	   t.R7_2 AS Revenue_7_product_adoption,
	   t.R8_2 AS Revenue_8_hoarding,
	   t.RVE_2 AS Revenue_value_effect,
	   t.Margin_1_promotion,
	   t.Margin_2_subs_promo,
	   t.Margin_3_subs_group,
	   t.Margin_4_promobuyer_existing,
	   t.Margin_5_promobuyer_new,
	   t.M6_2 AS Margin_6_new_customer,
	   t.M7_2 AS Margin_7_product_adoption,
	   t.M8_2 AS Margin_8_hoarding,
	   t.MVE_2 AS Margin_value_effect,
	   t.Seg_2 AS Promotion_segment,
	   t.Number_customers,
	   t.Promotion_customers,
	   t.New_customers,
	   t.Adopting_customers,
	   t.Total_supplier_participation,
	   t.Promotion_price_per_product,
	   t.Regular_price_per_product,
	   t.Discount,
	   t.Promotion_margin_per_product,
	   t.Regular_margin_per_product,
	   t.Selling_price,
	   t.Supplier_participation_per_product,
	   t.cnt_suppliers,
	   t.Supplier_ID,
	   t.Supplier_name_HE,
	   t.DistributedRealQuantity,
	   t.DistributedBaseQuantity,
	   t.CatalogPrice,
	   t.SellOut_Prod,
	   t.SellOut_Prom,
	   t.SellIn,
	   t.Revenue_1_promotion_Cat,
	   t.Revenue_2_subs_promo_Cat,
	   t.Revenue_3_subs_group_Cat,
	   t.Revenue_4_promobuyer_existing_Cat,
	   t.Revenue_5_promobuyer_new_Cat,
	   ISNULL(t.CatRev6_new,t.Revenue_6_new_customer_Cat) AS Revenue_6_new_customer_Cat,
	   ISNULL(t.CatRev7_new,t.Revenue_7_Product_adoption_Cat) AS Revenue_7_Product_adoption_Cat,
	   ISNULL(t.CatRev8_new,t.Revenue_8_hording_Cat) AS Revenue_8_hording_Cat,
	   ISNULL(t.Revenue_1_promotion_Cat,0)+ISNULL(t.Revenue_2_subs_promo_Cat,0)+ISNULL(t.Revenue_3_subs_group_Cat,0)+ISNULL(t.Revenue_4_promobuyer_existing_Cat,0)+ISNULL(t.Revenue_5_promobuyer_new,0)+ISNULL(ISNULL(t.CatRev6_new,t.Revenue_6_new_customer_Cat),0)+ISNULL(ISNULL(t.CatRev7_new,t.Revenue_7_Product_adoption_Cat),0)+ISNULL(ISNULL(t.CatRev8_new,t.Revenue_8_hording_Cat),0) AS Revenue_Value_Effect_Cat,
	   t.Tot_Participation,
	   t4.Supplier_Segment,
	   t.MVE_Pro_2 AS MVE,
	   t.rownum_After_suppliers,
	   CASE WHEN t4.Supplier_Segment='1. Win' AND ((t.Promotion_segment IN ('3. Potential winner','2. Diamond','1. Winner')) OR ((t.Promotion_segment='4. Grey herd' OR t.Promotion_segment='9.Zero revenue') and t.MVE>=5000))  THEN '1. Win-Win'
			WHEN t4.Supplier_Segment='1. Win' AND ((t.Promotion_segment IN ('6. Margin killer','5. Bleeder')) OR ((t.Promotion_segment='4. Grey herd' OR t.Promotion_segment='9.Zero revenue') and t.MVE<5000)) THEN '3. Lose-Win'
			WHEN t4.Supplier_Segment='2. Lose' AND ((t.Promotion_segment IN ('3. Potential winner','2. Diamond','1. Winner')) OR ((t.Promotion_segment='4. Grey herd' OR t.Promotion_segment='9.Zero revenue') and t.MVE>=5000)) THEN '2. Win-Lose'
			WHEN t4.Supplier_Segment='2. Lose' AND ((t.Promotion_segment IN ('6. Margin killer','5. Bleeder')) OR ((t.Promotion_segment='4. Grey herd' OR t.Promotion_segment='9.Zero revenue') and t.MVE<5000)) THEN '4. Lose-Lose'
			END AS Supplier_Matrix_segment
INTO #temp_input_RAS_2Months_5
FROM #temp_input_RAS_2Months_3 t
LEFT JOIN #temp_input_RAS_2Months_4 t4
ON t4.supplier_ID=t.Supplier_ID
AND t.PromotionNumber=t4.PromotionNumber

SELECT @p1=COUNT(*),
	   @p3=SUM(Revenue_value_effect)
FROM #temp_input_RAS_2Months_5
	
SELECT @p2=COUNT(*)
FROM (SELECT DISTINCT *
	  FROM #temp_input_RAS_2Months_5) m

SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			2,
			@step,
			'Step 4: Row count='  + STR(@p1,10,6) + ', Distinct Row count='  + STR(@p2,10,6) + ', Sum RVE='  + STR(@p3,10,6),
			SYSDATETIME()
		)

--***************************Step 5 : Update table**********************************************


IF (@p0=@p1) 
	BEGIN 
		DELETE FROM PG_input_RAS_Wave1_5
		WHERE  PromotionEndDate<@start_date_1_5 and PromotionEndDate>=DATEADD(day,-@after_days,@start_date_1_5)
		INSERT INTO PG_input_RAS_Wave1_5
		SELECT	  *
		FROM	#temp_input_RAS_2Months_5

		SET @step = @step + 1;
		INSERT INTO PG_update_log_Supplier
			VALUES(	@run_nr,
					@run_date,
					0,
					@step,
					'Success: [Supplier_update_2_Update_Retro_effects]: Updated RAS_Wave1_5',
					SYSDATETIME()
				)
	END
ELSE
	BEGIN 
		SET @step = @step + 1;
		INSERT INTO PG_update_log_Supplier
			VALUES(	@run_nr,
					@run_date,
					0,
					@step,
					'Failed: [Supplier_update_2_Update_Retro_effects]: Encountered difference in number of rows',
					SYSDATETIME()
				)
	END

END