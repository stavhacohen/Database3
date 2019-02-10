-- =============================================
-- Author:		Gal Naamani
-- Create date:	2018-12-17
-- Description: Takes the relevant rows from RAS and attaches supplier information
-- =============================================
CREATE PROCEDURE [dbo].[Supplier_update_3_Supplier_RAS]
    @run_nr INT = 1,
    @step INT = 1,
    @run_date DATE = '2017-10-10',
	@start_date_1_5 DATE = '2018-01-01',
	@end_date_1_5 DATE = '2018-01-30'

AS
BEGIN

INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			3,
			@step,
			'Start of [Supplier_update_3_Supplier_RAS]',
			SYSDATETIME()
		)

DECLARE @p0 FLOAT;
DECLARE @p1 FLOAT;
DECLARE @p2 FLOAT;
DECLARE @p3 FLOAT;
DECLARE @p4 FLOAT;
DECLARE @p5 FLOAT;
DECLARE @p6 FLOAT;

/**********************************************Step 1 : Preperations**********************************************/

/*Take only relevant dates that can be found in SO/SI table*/
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat' ,'U') IS NOT NULL
    DROP TABLE [#HW_Input_rasPlusFormat];
SELECT t1.PromotionNumber,
	   t1.PromotionStartDate,
	   t1.PromotionEndDate,
	   t1.ProductNumber,
	   t1.TransactionDate,
	   t1.Branch_name_EN,
   	   t1.SourceInd,
	   t1.Multibuy_quantity,
	   t1.Subgroup_name_EN, --For some reason this is important to be unique in the regular RAS
	   t1.Real_quantity,
	   t1.Baseline_quantity,
	   t1.Uplift,
	   t1.Revenue_3_subs_group,
	   t1.Revenue_4_promobuyer_existing,
	   t1.Revenue_5_promobuyer_new,
	   t1.Revenue_6_new_customer,
	   t1.Revenue_value_effect --For Checks
INTO #HW_Input_rasPlusFormat
FROM Shufersal.dbo.PG_input_RAS t1
where TransactionDate>=@start_date_1_5 AND TransactionDate<=@end_date_1_5
	

SELECT @p0=COUNT(*),
       @p3=SUM(Revenue_value_effect)
FROM [#HW_Input_rasPlusFormat]
	
SELECT @p2=COUNT(*)
FROM (SELECT DISTINCT *
	  FROM [#HW_Input_rasPlusFormat]) m

SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			3,
			@step,
			'Step 1: Row count='  + STR(@p0,10,6) + ', Distinct Row count='  + STR(@p2,10,6) + ', Sum RVE='  + STR(@p3,10,6),
			SYSDATETIME()
		)

/***************Step 2 : ADD Quantities of stuff to RAS_input for later adding the SI/SO table**********************************************/

--Add Quantities for adoption and hording (since it's the same product then we only need the quantities and later we will multiply by catalog price)
--We also number the rows to keep track
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat2' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat2;
SELECT t1.*,
	   t2.Quantity_7_product_adoption,
	   CASE WHEN t3.Quantity_8_hoarding>0 THEN 0 
		    ELSE t3.Quantity_8_hoarding 
			END AS Quantity_8_hoarding,
	   ROW_NUMBER() OVER (ORDER BY t1.TransactionDate) AS rownum
INTO #HW_Input_rasPlusFormat2
FROM #HW_Input_rasPlusFormat t1
LEFT JOIN Shufersal.dbo.PG_ROI_component_7 t2
ON t1.PromotionNumber=t2.PromotionNumber
AND t1.ProductNumber=t2.ProductNumber
AND t1.Branch_name_EN=t2.Branch_name_EN
AND t1.TransactionDate=t2.TransactionDate
AND t1.PromotionStartDate=t2.PromotionStartDate
AND t1.PromotionEndDate=t2.PromotionEndDate
AND t1.SourceInd=t2.SourceInd
LEFT JOIN Shufersal.dbo.PG_ROI_component_8 t3
ON t1.PromotionNumber=t3.PromotionNumber
AND t1.ProductNumber=t3.ProductNumber
AND t1.Branch_name_EN=t3.Branch_name_EN
AND t1.TransactionDate=t3.TransactionDate
AND t1.PromotionStartDate=t3.PromotionStartDate
AND t1.PromotionEndDate=t3.PromotionEndDate
AND t1.SourceInd=t3.SourceInd


SELECT @p4=SUM(Revenue_value_effect),
	   @p2=SUM(CASE WHEN Quantity_7_product_adoption IS NULL THEN 1 ELSE 0 END),
	   @p3=SUM(CASE WHEN Quantity_8_hoarding IS NULL THEN 1 ELSE 0 END),
	   @p1=COUNT(*)
FROM #HW_Input_rasPlusFormat2

SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			3,
			@step,
			'Step 2: Row count='  + STR(@p1,10,6) + ', Sum RVE='  + STR(@p4,10,6),
			SYSDATETIME()
		)

/*****************************Step 3: Change Revenues to Catalog Price Revenues using distribution table ***********/

--Change all revenues to Catalog prices revenues by multiplying with the above result
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat3' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat3;
SELECT t1.rownum,
	   t1.PromotionNumber,
	   t1.PromotionStartDate,
	   t1.PromotionEndDate,
	   t1.ProductNumber,
	   t1.Multibuy_quantity,
	   t1.Subgroup_name_EN,
	   t1.Branch_name_EN,
	   t1.SourceInd,
	   t1.TransactionDate,
	   t1.Real_quantity,
	   t1.Baseline_quantity,
	   t1.Revenue_3_subs_group*t3.catRev2Rev_Ratio AS Cat_Revenue_3_subs_group,
	   t1.Revenue_4_promobuyer_existing*t2.catRev2Rev_Ratio AS Cat_Revenue_4_promobuyer_existing,
	   t1.Revenue_5_promobuyer_new*t2.catRev2Rev_Ratio AS Cat_Revenue_5_promobuyer_new,
	   t1.Revenue_6_new_customer*t2.catRev2Rev_Ratio AS Cat_Revenue_6_new_customer,
	   t1.Quantity_7_product_adoption,
	   t1.Quantity_8_hoarding,
	   t1.Revenue_value_effect
INTO #HW_Input_rasPlusFormat3
FROM #HW_Input_rasPlusFormat2 t1
LEFT JOIN Shufersal.dbo.PG_Wave1_5_Catalog_revenue_ratio_tot t2
ON t2.Branch_name_EN=t1.Branch_name_EN
AND t2.SourceInd=t1.SourceInd
LEFT JOIN Shufersal.dbo.PG_Wave1_5_Catalog_revenue_ratio_subs t3
ON t3.ProductNumber=t1.ProductNumber
AND t3.Branch_name_EN=t1.Branch_name_EN
AND t3.SourceInd=t1.SourceInd


SELECT @p4=SUM(Revenue_value_effect),
	   @p1=COUNT(*)
FROM #HW_Input_rasPlusFormat3

SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			3,
			@step,
			'Step 3: Row count='  + STR(@p1,10,6) + ', Sum RVE='  + STR(@p4,10,6),
			SYSDATETIME()
		)

/***********************************Step 4 : Add supplierID+Catalog Price to promotioncustomer Table**********************************************/

-- Add Supplier_ID
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat4' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat4;
SELECT t1.*,
	t2.supplierNumber AS supplier_ID,
	t2.Catalog_Price AS CatalogPrice,
	COUNT(*) OVER (PARTITION BY t1.rownum) AS cnt_suppliers,
	t2.StartDate
INTO #HW_Input_rasPlusFormat4
FROM #HW_Input_rasPlusFormat3 t1
LEFT JOIN Shufersal.dbo.PG__Wave1_5_Supplier_CatalogPrices t2
ON t1.ProductNumber=t2.ProductNumber
AND t1.Branch_name_EN=t2.branch_name_EN

--Add another rownumbers to keep track
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat4_75' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat4_75;
SELECT *,
	   Real_quantity/ISNULL(cnt_suppliers,1) AS DistributedRealQuantity,
	   Baseline_quantity/ISNULL(cnt_suppliers,1) AS DistributedBaseQuantity,
	   ROW_NUMBER() OVER (ORDER BY TransactionDate) AS rownum_After_suppliers 
INTO #HW_Input_rasPlusFormat4_75
FROM #HW_Input_rasPlusFormat4

SELECT @p4=SUM(Revenue_value_effect),
	   @p2=AVG(cnt_suppliers),
	   @p1=COUNT(*)
FROM [#HW_Input_rasPlusFormat4_75]

SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			3,
			@step,
			'Step 4: Row count='  + STR(@p1,10,6) + ', Sum RVE='  + STR(@p4,10,6) + ', Avg #suppliers='  + STR(@p2,10,6),
			SYSDATETIME()
		)


/********************************Step 5: Add Distribution of Components revenues with specific suppliers**********************************************/

--Add the customerEffects percentages by joining with the supplier distribution table
--Note that for these effects (component 4,5,6) we take the distribution over all transactions
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat5' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat5;
SELECT t1.*,
	   t2.perc_CatRev AS perc_CatRev_customerEffects
INTO #HW_Input_rasPlusFormat5
FROM #HW_Input_rasPlusFormat4_75 t1
LEFT JOIN Shufersal.dbo.PG_Wave1_5_totalTransactions_supplier_dist t2
ON t2.supplier_ID=t1.supplier_ID
AND t2.sourceINd=t1.sourceind
AND t1.branch_name_en=t2.branch_name_en

--Take for each row in the input_RAS the average percentage the specific supplier has out of all the subgroups the product is in
--Note that for these effects (component 3) we take the distribution over the subgroups
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat6' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat6;
SELECT t1.rownum_After_suppliers,
	   AVG(t2.perc_CatRev) AS perc_CatRev_Substitution
INTO #HW_Input_rasPlusFormat6 
FROM (SELECT p1.*,
			 p2.level_ID
	  FROM #HW_Input_rasPlusFormat5 p1
	  LEFT JOIN Shufersal.dbo.PG_product_substitute_levels p2
	  ON p2.product_ID=p1.ProductNumber) t1
LEFT JOIN Shufersal.dbo.PG_Wave1_5_subgroups_supplier_dist t2
ON t2.supplier_ID=t1.supplier_ID
AND t2.sourceINd=t1.sourceind
AND t1.branch_name_en=t2.branch_name_en
AND t2.level_ID=t1.level_ID
GROUP BY rownum_After_suppliers


--Add the substitution percentages
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat7' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat7;
SELECT t1.*,
	   t2.perc_CatRev_Substitution
INTO #HW_Input_rasPlusFormat7 
FROM #HW_Input_rasPlusFormat5 t1
LEFT JOIN #HW_Input_rasPlusFormat6 t2
ON t2.rownum_After_suppliers=t1.rownum_After_suppliers


SELECT @p4=SUM(Revenue_value_effect),
	   @p2=MIN(perc_CatRev_customerEffects),
	   @p3=MAX(perc_CatRev_customerEffects),
	   @p5=MIN(perc_CatRev_Substitution),
	   @p6=MAX(perc_CatRev_Substitution),
	   @p1=COUNT(*)
FROM #HW_Input_rasPlusFormat7

SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			3,
			@step,
			'Step 5: Row count='  + STR(@p1,10,6) + ', Sum RVE='  + STR(@p4,10,6),
			SYSDATETIME()
		)

/**********************************Step 6 : Join SI/SO tables**********************************************/

/*add Sell-Out PRODUCT*/
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat8' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat8;
SELECT	t1.*,
        t2.avg_Partic AS SellOut_Prod
INTO #HW_Input_rasPlusFormat8
FROM #HW_Input_rasPlusFormat7 t1
LEFT JOIN Shufersal.dbo.PG_supplier_billing_in_sales_update t2
ON t1.ProductNumber=t2.Product_ID
AND t1.TransactionDate=t2.date0
AND t1.Branch_name_EN=t2.Branch_name_EN
AND t2.SUPPLIER_ID=t1.Supplier_ID
;

SELECT @p4=SUM(Revenue_value_effect),
       @p1=COUNT(*)
FROM #HW_Input_rasPlusFormat8

SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			3,
			@step,
			'Step 6 SO product: Row count='  + STR(@p1,10,6) + ', Sum RVE='  + STR(@p4,10,6),
			SYSDATETIME()
		)

--Make Multibuy calculations to fit financial reports
IF OBJECT_ID('tempdb..#temp' ,'U') IS NOT NULL
    DROP TABLE #temp;
SELECT	t1.rownum_After_suppliers,
		t1.PromotionNumber,
		t1.ProductNumber,
		t1.SourceInd,
		t1.Supplier_ID,
		t1.Branch_name_EN,
		t1.TransactionDate,
		t2.MONTH,
		t2.avg_Partic,
		t2.Tot_Partic,
		t2.Tot_sales,
		--If we want to distinguish between SourceINd we should add it to the partition by
		SUM(t1.DistributedRealQuantity) OVER (PARTITION BY t1.PromotionNumber,t1.Supplier_ID,t1.Branch_name_EN,t2.MONTH) AS TotalSalesInput_RAS
INTO #temp
FROM #HW_Input_rasPlusFormat8 t1
LEFT JOIN ( --ADd total participation over entire promotion
			SELECT p2.*,
				   SUM(p2.Supplier_participation/p2.numDays) OVER (PARTITION BY p2.Branch_name_EN,p2.Supplier_ID,p2.DISCOUNT_ID,p2.MONTH) AS Tot_Partic,
				   SUM(p2.TOTAL_SALES/p2.numDays) OVER (PARTITION BY p2.Branch_name_EN,p2.Supplier_ID,p2.DISCOUNT_ID,p2.MONTH) AS Tot_sales
			FROM (--Add number of promotion Days in the relevant month in each row
				  SELECT p.*,
				 	     COUNT(*) OVER (PARTITION BY p.Branch_name_EN,p.Supplier_ID,p.DISCOUNT_ID,p.MONTH) AS numDays
				  FROM Shufersal.dbo.PG_supplier_billing_update p) p2
			) t2
ON t2.DISCOUNT_ID= (CASE WHEN LEN(t1.PromotionNumber) >8 THEN LEFT(t1.PromotionNumber,LEN(t1.PromotionNumber)-3) 
						 ELSE t1.PromotionNumber 
						 END)
AND t1.TransactionDate=t2.date0
AND t1.Branch_name_EN=t2.Branch_name_EN
AND t2.SUPPLIER_ID=t1.Supplier_ID

--add Sell-Out PROMOTION
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat9' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat9;
SELECT	t1.*,
		CASE WHEN t1.Multibuy_quantity<=1 THEN t2.avg_Partic 
			 ELSE (CASE WHEN t2.Tot_sales<=(t2.TotalSalesInput_RAS/t1.Multibuy_quantity) THEN t2.Tot_Partic/t2.TotalSalesInput_RAS 
						ELSE t2.avg_Partic/t1.Multibuy_quantity 
						END)
			 END AS SellOut_Prom
INTO #HW_Input_rasPlusFormat9
FROM #HW_Input_rasPlusFormat8 t1
LEFT JOIN #temp t2
ON t2.PromotionNumber=t1.PromotionNumber
AND t1.TransactionDate=t2.TransactionDate
AND t1.Branch_name_EN=t2.Branch_name_EN
AND t2.SUPPLIER_ID=t1.Supplier_ID
AND t1.SourceInd=t2.SourceInd
AND t1.ProductNumber=t2.ProductNumber
AND t1.rownum_After_suppliers=t2.rownum_After_suppliers
;

SELECT @p4=SUM(Revenue_value_effect),
       @p1=COUNT(*)
FROM #HW_Input_rasPlusFormat9

SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			3,
			@step,
			'Step 6 SO Promotion: Row count='  + STR(@p1,10,6) + ', Sum RVE='  + STR(@p4,10,6),
			SYSDATETIME()
		)

--Add Sell-in
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat10' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat10;
SELECT	t1.*,
		ISNULL(t1.SellOut_Prod,0)+ISNULL(t1.SellOut_Prom,0) AS SellOut_TOT,
		t1.CatalogPrice-t2.PriceA AS SellIn
INTO #HW_Input_rasPlusFormat10
FROM #HW_Input_rasPlusFormat9 t1
LEFT JOIN (SELECT p1.SupplierNumber,
                  p1.ProductNumber,
				  p1.MonthNumber,
				  AVG(p1.PriceA) AS PriceA,
				  p2.Branch_name_EN
		   FROM (SELECT * 
				 FROM Shufersal.dbo.PG_Participation_suppliers_update 
				 WHERE StoreFormatCode<8) p1 
		   LEFT JOIN Staging_branches p2
		   ON p2.Branch_ID=p1.StoreFormatCode
		   GROUP BY p1.SupplierNumber,p1.ProductNumber,p1.MonthNumber,p2.Branch_name_EN 
			) t2
ON t1.supplier_ID=t2.SupplierNumber
AND t1.ProductNumber=t2.ProductNumber
AND DATEPART(YEAR,t1.TransactionDate)=ROUND(t2.MonthNumber/100,0)
AND DATEPART(MONTH,t1.TransactionDate)=t2.MonthNumber-100*ROUND(t2.MonthNumber/100,0)
AND t1.Branch_name_EN=t2.Branch_name_EN
;

SELECT @p4=SUM(Revenue_value_effect),
       @p1=COUNT(*)
FROM #HW_Input_rasPlusFormat10

SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			3,
			@step,
			'Step 6 Sell In: Row count='  + STR(@p1,10,6) + ', Sum RVE='  + STR(@p4,10,6),
			SYSDATETIME()
		)


--****************************Step 7 : Adding Supplier Segmentation and Matrix Segmentation*****************************

--Delete negative participation (doesn't make sense buisness wise)
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat10_25' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat10_25;
SELECT	t1.*,
		CASE WHEN t1.SellOut_Prod<0 THEN 0 ELSE t1.SellOut_Prod END AS SellOut_Prod_c,
		CASE WHEN t1.SellOut_Prom<0 THEN 0 ELSE t1.SellOut_Prom END AS SellOut_Prom_c,
		CASE WHEN t1.SellIn<0 THEN 0 ELSE t1.SellIn END AS SellIn_c
INTO #HW_Input_rasPlusFormat10_25
FROM #HW_Input_rasPlusFormat10 t1

--Add Revenue and Participation
SELECT @p1=AVG(perc_catrev)
FROM Shufersal.dbo.PG_Wave1_5_totalTransactions_supplier_dist
SELECT @p2=AVG(perc_catrev)
FROM Shufersal.dbo.PG_Wave1_5_subgroups_supplier_dist

IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat10_5' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat10_5;
SELECT	t1.*,
		(ISNULL(t1.DistributedRealQuantity,0)-ISNULL(t1.DistributedBaseQuantity,0)+ISNULL(t1.Quantity_7_product_adoption,0)/t1.cnt_suppliers+ISNULL((CASE WHEN t1.Quantity_8_hoarding/t1.cnt_suppliers<-t1.DistributedRealQuantity THEN -t1.DistributedRealQuantity ELSE t1.Quantity_8_hoarding/t1.cnt_suppliers END),0))*t1.CatalogPrice+
		ISNULL(t1.Cat_Revenue_3_subs_group,0)*ISNULL(t1.perc_CatRev_Substitution,@p2)+(ISNULL(t1.Cat_Revenue_4_promobuyer_existing,0)+ISNULL(t1.Cat_Revenue_5_promobuyer_new,0)+ISNULL(t1.Cat_Revenue_6_new_customer,0))*ISNULL(t1.perc_CatRev_customerEffects,@p1) AS Revenue_Value_Effect_Cat
		,-ISNULL(t1.DistributedRealQuantity,0)*(ISNULL(t1.SellIn_c,0)+ISNULL(t1.SellOut_Prod_c,0)+ISNULL(t1.SellOut_Prom_c,0)) AS Tot_Participation
INTO #HW_Input_rasPlusFormat10_5
FROM #HW_Input_rasPlusFormat10_25 t1

SELECT @p4=SUM(Revenue_value_effect),
       @p1=COUNT(*)
FROM #HW_Input_rasPlusFormat10_5

SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			3,
			@step,
			'Step 7: Row count='  + STR(@p1,10,6) + ', Sum RVE='  + STR(@p4,10,6),
			SYSDATETIME()
		)

--Create Segmentation based on NetValue Effect on promotion level
-->0 => win for supplier
--<=0 => lose for supplier
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat10_75' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat10_75;
SELECT	t1.PromotionNumber, t1.Supplier_ID,
		SUM(ISNULL(Revenue_Value_Effect_Cat,0)) AS RevenueValueEffect,
		SUM(ISNULL(Tot_Participation,0)) AS Tot_Participation,
		CASE WHEN SUM(ISNULL(Revenue_Value_Effect_Cat,0))=0 THEN '2. Lose'
			 WHEN SUM(ISNULL(Tot_Participation,0))=0 THEN '1. Win'
			 WHEN (SUM(ISNULL(Revenue_Value_Effect_Cat,0))/ABS(SUM(ISNULL(Tot_Participation,0))))>2 THEN '1. Win' 
			 ELSE '2. Lose' END AS Supplier_Segment
INTO #HW_Input_rasPlusFormat10_75
FROM #HW_Input_rasPlusFormat10_5 t1
GROUP BY t1.PromotionNumber, t1.Supplier_ID


/**********************************************Step 8 : Finalize table **********************************************/
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat11' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat11;
SELECT *
INTO #HW_Input_rasPlusFormat11
FROM (SELECT	t2.*,
				t1.cnt_suppliers,
				t1.Supplier_ID,
				t3.Supplier_name_HE,
				t1.DistributedRealQuantity,
				t1.DistributedBaseQuantity,
				t1.CatalogPrice,
				t1.SellOut_Prod_c AS SellOut_Prod,
				t1.SellOut_Prom_c AS SellOut_Prom,
				t1.SellIn_c AS SellIn,
				t1.DistributedRealQuantity*t1.CatalogPrice AS Revenue_1_promotion_Cat,
				-t1.DistributedBaseQuantity*t1.CatalogPrice AS Revenue_2_subs_promo_Cat,
				t1.Cat_Revenue_3_subs_group*ISNULL(t1.perc_CatRev_Substitution,@p2) AS Revenue_3_subs_group_Cat,
				t1.Cat_Revenue_4_promobuyer_existing*ISNULL(t1.perc_CatRev_customerEffects,@p1) AS Revenue_4_promobuyer_existing_Cat,
				t1.Cat_Revenue_5_promobuyer_new*ISNULL(t1.perc_CatRev_customerEffects,@p1) AS Revenue_5_promobuyer_new_Cat,
				t1.Cat_Revenue_6_new_customer*ISNULL(t1.perc_CatRev_customerEffects,@p1) AS Revenue_6_new_customer_Cat,
				t1.Quantity_7_product_adoption*t1.CatalogPrice/t1.cnt_suppliers AS Revenue_7_Product_adoption_Cat,
				CASE WHEN t1.Quantity_8_hoarding*t1.CatalogPrice/t1.cnt_suppliers<-t1.DistributedRealQuantity*t1.CatalogPrice THEN -t1.DistributedRealQuantity*t1.CatalogPrice 
					 ELSE t1.Quantity_8_hoarding*t1.CatalogPrice/t1.cnt_suppliers END AS Revenue_8_hording_Cat,
				t1.Revenue_Value_Effect_Cat
				,t1.Tot_Participation
				,t4.Supplier_Segment
				,SUM(t2.Margin_value_effect) OVER (PARTITION BY t2.promotionNumber) AS MVE
				,t1.rownum_After_suppliers
FROM #HW_Input_rasPlusFormat10_5 t1
INNER JOIN Shufersal.dbo.PG_input_RAS t2
ON t2.PromotionNumber=t1.PromotionNumber
AND t1.TransactionDate=t2.TransactionDate
AND t1.ProductNumber=t2.ProductNumber
AND t1.Branch_name_EN=t2.Branch_name_EN
AND t1.SourceInd=t2.SourceInd
AND t1.Real_quantity=t2.Real_quantity 
AND t1.Baseline_quantity=t2.Baseline_quantity
AND t1.PromotionStartDate=t2.PromotionStartDate
AND t1.PromotionEndDate=t2.PromotionEndDate
AND ISNULL(t1.Subgroup_name_EN,'noName')=ISNULL(t2.Subgroup_name_EN,'noName')
LEFT JOIN (SELECT p1.Supplier_ID,
                  MAX(p1.Supplier_name_HE) AS Supplier_name_HE
		   FROM Shufersal.dbo.Staging_assortment_supplier p1
		   GROUP BY p1.Supplier_ID ) t3
ON t3.Supplier_ID=t1.supplier_ID
LEFT JOIN #HW_Input_rasPlusFormat10_75 t4
ON t4.supplier_ID=t1.Supplier_ID
AND t1.PromotionNumber=t4.PromotionNumber) m

IF OBJECT_ID('Shufersal.dbo.PG_input_RAS_Wave1_5_update', 'U') IS NOT NULL
    DROP TABLE Shufersal.dbo.PG_input_RAS_Wave1_5_update;
SELECT t1.*,
	   CASE WHEN t1.Supplier_Segment='1. Win' AND ((t1.Promotion_segment IN ('3. Potential winner','2. Diamond','1. Winner')) OR ((t1.Promotion_segment='4. Grey herd' OR t1.Promotion_segment='9.Zero revenue') and t1.MVE>=5000))  THEN '1. Win-Win'
			WHEN t1.Supplier_Segment='1. Win' AND ((t1.Promotion_segment IN ('6. Margin killer','5. Bleeder')) OR ((t1.Promotion_segment='4. Grey herd' OR t1.Promotion_segment='9.Zero revenue') and t1.MVE<5000)) THEN '3. Lose-Win'
			WHEN t1.Supplier_Segment='2. Lose' AND ((t1.Promotion_segment IN ('3. Potential winner','2. Diamond','1. Winner')) OR ((t1.Promotion_segment='4. Grey herd' OR t1.Promotion_segment='9.Zero revenue') and t1.MVE>=5000)) THEN '2. Win-Lose'
			WHEN t1.Supplier_Segment='2. Lose' AND ((t1.Promotion_segment IN ('6. Margin killer','5. Bleeder')) OR ((t1.Promotion_segment='4. Grey herd' OR t1.Promotion_segment='9.Zero revenue') and t1.MVE<5000)) THEN '4. Lose-Lose'
		    END AS Supplier_Matrix_segment
INTO Shufersal.dbo.PG_input_RAS_Wave1_5_update
FROM #HW_Input_rasPlusFormat11 t1

--***************************CHECKS****************************

SELECT @p1=COUNT(*),
	   @p3=SUM(Revenue_value_effect)
FROM Shufersal.dbo.PG_input_RAS_Wave1_5_update
	
SELECT @p2=COUNT(*)
FROM (SELECT DISTINCT *
	  FROM Shufersal.dbo.PG_input_RAS_Wave1_5_update) m

SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			3,
			@step,
			'Step 8: Row count='  + STR(@p1,10,6) + ', Distinct Row count='  + STR(@p2,10,6) + ', Sum RVE='  + STR(@p3,10,6),
			SYSDATETIME()
		)

IF (@p0=@p1) 
	BEGIN 
		DELETE FROM PG_input_RAS_Wave1_5
		WHERE  TransactionDate>=@start_date_1_5 AND TransactionDate<=@end_date_1_5
		INSERT INTO PG_input_RAS_Wave1_5
		SELECT	  *
		FROM	PG_input_RAS_Wave1_5_update

		SET @step = @step + 1;
		INSERT INTO PG_update_log_Supplier
			VALUES(	@run_nr,
					@run_date,
					3,
					@step,
					'Success: [Supplier_update_3_Supplier_RAS]: Updated RAS_Wave1_5',
					SYSDATETIME()
				)
	END
ELSE
	BEGIN 
		SET @step = @step + 1;
		INSERT INTO PG_update_log_Supplier
			VALUES(	@run_nr,
					@run_date,
					3,
					@step,
					'Failed: [Supplier_update_3_Supplier_RAS]: Encountered difference in number of rows',
					SYSDATETIME()
				)
	END

SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			3,
			@step,
			'End of [Supplier_update_3_Supplier_RAS]',
			SYSDATETIME()
		)


END