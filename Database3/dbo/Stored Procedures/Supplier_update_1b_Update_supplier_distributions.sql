-- =============================================
-- Author:		Gal Naamani
-- Create date:	2018-12-17
-- Description:	Make SUPPLIER DISTRIBUTION tables with CATALOG REVENUE
-- =============================================
CREATE PROCEDURE [dbo].[Supplier_update_1b_Update_supplier_distributions]
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
			1,
			@step,
			'Start of [Supplier_update_1b_Update_supplier_distributions]',
			SYSDATETIME()
		)

SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			1,
			@step,
			'Part #1 START - Distribtuion of suppliers on Transactions in total and in group level',
			SYSDATETIME()
		)


--****************************************ADDING CATALOG PRICES AND REVENUES****************** 
IF OBJECT_ID('Shufersal.dbo.Wave1_5_PG_sales_per_product_per_day_wo_returns', 'U') IS NOT NULL
    DROP TABLE Shufersal.dbo.Wave1_5_PG_sales_per_product_per_day_wo_returns;
SELECT t.ProductNumber,
	   t.TransactionDate,
	   t.SourceInd,
	   t.Branch_name_EN,
	   CASE WHEN t.Quantity<0 
		    THEN 0 
			ELSE t.Quantity END AS Quantity,
	   CASE WHEN t.Revenue<0 
			THEN 0 
			ELSE t.Revenue END AS Revenue,
		--Adding the catalog price and catalog revenue only when the catalog revenue is less than 5 times bigger than the regular revenue: 
		--Sometimes when the product is prescription medicine, or deliveries and so on then the catalog price is way bigger because there is no revenue considered.
		--Sometimes products are sold with loss to bring costumers to the store
		--Sometimes products are sold with loss because they are about to be out of date  
		--This is only important in terms of the checks we do in the end, but calculations wise these products are never on promotion anyway, so it would still work without it
	   CASE WHEN (CASE WHEN ISNULL(t.Revenue,0)=0 
					   THEN 0 
					   ELSE (t.Quantity*t2.Catalog_price)/t.Revenue END)>5 
			THEN t.Revenue/(CASE WHEN ISNULL(t.Quantity,0)=0 
								 THEN 1 
								 ELSE t.Quantity END) 
			ELSE t2.Catalog_price 
			END AS CatalogPrice,
	   CASE WHEN (CASE WHEN ISNULL(t.Revenue,0)=0 
					   THEN 0 
					   ELSE (t.Quantity*t2.Catalog_price)/t.Revenue END)>5 
			THEN t.Revenue 
			ELSE t2.Catalog_price*(CASE WHEN ISNULL(t.Quantity,-1)<0 
										THEN 0 
										ELSE t.Quantity END) 
			END AS CatalogRevenue,
	   t2.SupplierNumber AS Supplier_ID,
	   COUNT(*) OVER (PARTITION BY t.ProductNumber,t.Branch_name_EN,t.sourceIND,t.TransactionDate) AS cnt_suppliers,
	   t2.StartDate,
	   ROW_NUMBER() OVER (ORDER BY t.TransactionDate) AS rownum
INTO Shufersal.dbo.Wave1_5_PG_sales_per_product_per_day_wo_returns
FROM (SELECT * 
	  FROM [Shufersal].[dbo].[PG_sales_per_product_per_day_wo_returns] 
	  WHERE TransactionDate>=@start_date_1_5 and TransactionDate<=@end_date_1_5) t
LEFT JOIN Shufersal.dbo.PG__Wave1_5_Supplier_CatalogPrices t2
ON t2.ProductNumber=t.ProductNumber
AND t.Branch_name_EN=t2.Branch_name_EN
ORDER BY TransactionDate
--****************************************Supllier Distribtution over all the transactions/ Catalog price level**************************************

--For each product add the total revenue/margin in the Branch+SourceIND it was baught
--We already have supplier so we need to divide by the number of suppliers for each product
IF OBJECT_ID('tempdb..#temp' ,'U') IS NOT NULL
    DROP TABLE [#temp];
SELECT t1.*,
		SUM(t1.Revenue/t1.cnt_suppliers) OVER (PARTITION BY t1.SourceInd,t1.Branch_name_EN) AS tot_rev_BranchSource,
		SUM(ISNULL(t1.CatalogRevenue,0)/t1.cnt_suppliers) OVER (PARTITION BY t1.SourceInd,t1.Branch_name_EN) AS tot_CatRev_BranchSource /*Assumption : quantity of a product is divided equally between all suplliers*/
INTO #temp
FROM Shufersal.dbo.Wave1_5_PG_sales_per_product_per_day_wo_returns t1

--Calculate for each Branch+SourceInd the relative revenue a product had over all dates
IF OBJECT_ID('tempdb..#temp2' ,'U') IS NOT NULL
    DROP TABLE [#temp2];
SELECT t1.ProductNumber,
		t1.SUPPLIER_ID,
		t1.Branch_name_EN,
		t1.SourceInd,
		CASE WHEN SUM(t1.CatalogPrice) IS NULL THEN NULL 
			 ELSE AVG(t1.CatalogPrice) 
			 END AS CatalogPrice,
		AVG(t1.tot_rev_BranchSource) AS tot_rev_BranchSource,
		CASE WHEN SUM(t1.CatalogRevenue) IS NULL THEN NULL 
		     ELSE AVG(t1.tot_CatRev_BranchSource) 
			 END AS tot_CatRev_BranchSource,
		CASE WHEN AVG(t1.tot_rev_BranchSource)=0 THEN 0 
			 ELSE SUM(t1.Revenue/t1.cnt_suppliers)/AVG(t1.tot_rev_BranchSource) 
			 END AS perc_rev,
		CASE WHEN AVG(t1.tot_CatRev_BranchSource)=0 THEN 0 
			 ELSE SUM(t1.CatalogRevenue/t1.cnt_suppliers)/AVG(t1.tot_CatRev_BranchSource) 
			 END AS perc_CatRev
INTO #temp2
FROM #temp t1
GROUP BY t1.ProductNumber,
		 t1.SUPPLIER_ID,
		 t1.Branch_name_EN,
		 t1.SourceInd

--Calculate for each Branch+SourceInd the relative revenue a SUPPLIER had over all dates (aggregating it's products)
IF OBJECT_ID('tempdb..#temp3' ,'U') IS NOT NULL
    DROP TABLE [#temp3];
SELECT t1.SUPPLIER_ID,
	   t1.SourceInd,
	   t1.Branch_name_EN,
	   COUNT(DISTINCT t1.ProductNumber) AS cnt_products,
	   AVG(t1.tot_rev_BranchSource) AS tot_rev_BranchSource,
	   AVG(t1.tot_CatRev_BranchSource) AS tot_CatRev_BranchSource,
	   SUM(t1.perc_rev) AS perc_rev,
	   SUM(ISNULL(t1.perc_CatRev,0)) AS perc_CatRev
INTO #temp3
FROM #temp2 t1
GROUP BY t1.SUPPLIER_ID,
		 t1.SourceInd,
		 t1.Branch_name_EN
		
--save
IF OBJECT_ID('Shufersal.dbo.PG_Wave1_5_totalTransactions_supplier_dist', 'U') IS NOT NULL
    DROP TABLE Shufersal.dbo.PG_Wave1_5_totalTransactions_supplier_dist;
SELECT *
INTO Shufersal.dbo.PG_Wave1_5_totalTransactions_supplier_dist
FROM #temp3

--***********************************************FOR SUBSTITUTION********************************

--for each Product+SourceInd+Branch_name add a subgroup level_ID and the total revenue for that subgroup in the sepcific sourceIND+Branch
IF OBJECT_ID('tempdb..#subtemp1' ,'U') IS NOT NULL
    DROP TABLE #subtemp1;
SELECT  t1.ProductNumber,
		t1.TransactionDate,
		t1.SourceInd,
		t1.Branch_name_EN,
		t1.supplier_ID,
		t1.Revenue, t1.CatalogRevenue,
		t1.cnt_suppliers,
		COUNT(*) OVER (PARTITION BY t1.ProductNumber,t1.Branch_name_EN,t1.sourceIND,t1.TransactionDate,t1.supplier_ID) AS cnt_levels_per_product,
		SUM(t1.Revenue/t1.cnt_suppliers) OVER (PARTITION BY t1.SourceInd,t1.Branch_name_EN,t2.level_id) AS tot_rev_BranchSourceLevel,
		CASE WHEN t1.CatalogRevenue IS NULL THEN NULL 
			 ELSE (SUM(t1.CatalogRevenue/t1.cnt_suppliers) OVER (PARTITION BY t1.SourceInd,t1.Branch_name_EN,t2.level_id)) 
			 END AS tot_CatRev_BranchSourceLevel,
		t2.tot_cnt_level_products AS cnt_products_in_level,
		t2.level_ID
INTO #subtemp1
FROM #temp t1
LEFT JOIN (SELECT *,
				  COUNT(*) OVER (PARTITION BY level_ID) AS tot_cnt_level_products,
				  COUNT(*) OVER (PARTITION BY Product_ID) AS cnt_levels_per_product	
		   FROM Shufersal.dbo.PG_product_substitute_levels 

) t2
ON t2.product_ID=t1.ProductNumber

--Calculate for each Branch+SourceInd+level_ID the relative revenue a SUPPLIER had over all dates (aggregating it's products)
IF OBJECT_ID('tempdb..#subtemp3' ,'U') IS NOT NULL
    DROP TABLE [#subtemp3];
SELECT t1.SUPPLIER_ID,
	   t1.SourceInd,
	   t1.Branch_name_EN,
	   t1.level_ID,
	   COUNT(DISTINCT t1.ProductNumber) AS cnt_products_supplier_in_level,
	   AVG(ISNULL(t1.cnt_products_in_level,0)) AS cnt_products_tot_in_level, /*only works well if level_ID is not NULL*/
	   AVG(t1.tot_rev_BranchSourceLevel) AS tot_rev_BranchSourceLevel,
	   CASE WHEN SUM(t1.tot_CatRev_BranchSourceLevel) IS NULL THEN NULL 
		    ELSE AVG(t1.tot_CatRev_BranchSourceLevel) 
			END AS tot_CatRev_BranchSourceLevel,
	   CASE WHEN SUM(t1.tot_rev_BranchSourceLevel) IS NULL THEN NULL
			ELSE (CASE WHEN AVG(t1.tot_rev_BranchSourceLevel)=0 THEN 0 
					   ELSE SUM(t1.Revenue/cnt_suppliers)/AVG(t1.tot_rev_BranchSourceLevel)  
					   END) 
			END AS perc_rev,
	   CASE WHEN SUM(t1.tot_CatRev_BranchSourceLevel) IS NULL THEN NULL 
			ELSE (CASE WHEN AVG(t1.tot_CatRev_BranchSourceLevel)=0 THEN 0 
					   ELSE SUM(t1.CatalogRevenue/cnt_suppliers)/AVG(t1.tot_CatRev_BranchSourceLevel)  
					   END) 
			END AS perc_CatRev
INTO #subtemp3
FROM #subtemp1 t1
GROUP BY t1.SUPPLIER_ID,
		 t1.SourceInd,
		 t1.level_ID,
		 t1.Branch_name_EN

--save
IF OBJECT_ID('Shufersal.dbo.PG_Wave1_5_subgroups_supplier_dist', 'U') IS NOT NULL
    DROP TABLE Shufersal.dbo.PG_Wave1_5_subgroups_supplier_dist;
SELECT *
INTO Shufersal.dbo.PG_Wave1_5_subgroups_supplier_dist
FROM #subtemp3

--Quality Checks

--1)

DECLARE @p1 FLOAT;
DECLARE @p2 FLOAT;
DECLARE @p3 FLOAT;
DECLARE @p4 FLOAT;
DECLARE @p5 FLOAT;
DECLARE @p6 FLOAT;

SELECT @p1=MIN(perc_CatRev),
	   @p2=AVG(perc_CatRev),
	   @p3=MAX(perc_CatRev),
	   @p4=MIN(perc_rev),
	   @p5=AVG(perc_rev),
	   @p6=MAX(perc_rev) 
FROM Shufersal.dbo.PG_Wave1_5_totalTransactions_supplier_dist 

SET @step = @step + 1;
IF (@p1>=0 AND @p1<=1 AND @p2>=0 AND @p2<=1 AND @p3>=0 AND @p3<=1 AND @p4>=0 AND @p4<=1 AND @p5>=0 AND @p5<=1 AND @p6>=0 AND @p6<=1 AND @p2<=0.5 AND @p5<=0.5)
	BEGIN
		INSERT INTO PG_update_log_Supplier
			VALUES(	@run_nr,
					@run_date,
					1,
					@step,
					'Succeded QC #1, totalTransactions_supplier_dist: all percentages are in [0,1], avg is close to 0',
					SYSDATETIME()
				)
	END
ELSE
	BEGIN
		INSERT INTO PG_update_log_Supplier
			VALUES(	@run_nr,
					@run_date,
					1,
					@step,
					'Failed QC #1, totalTransactions_supplier_dist: wierd percentages values',
					SYSDATETIME()
				)
	END

--2) 
SELECT @p1=MIN(a),
	   @p2=MAX(a),
	   @p3=MIN(b),
	   @p4=MAX(b) 
FROM (SELECT SUM(perc_CatRev) AS a,
			 SUM(perc_rev) AS b,
			 Branch_name_EN,
			 SourceInd
	  FROM Shufersal.dbo.PG_Wave1_5_totalTransactions_supplier_dist
	  GROUP BY Branch_name_EN,SourceInd) p

SET @step = @step + 1;
IF (@p1>=0.9 AND @p1<=1.1 AND @p2>=0.9 AND @p2<=1.1 AND @p3>=0.9 AND @p3<=1.11 AND @p4>=0.9 AND @p4<=1.1)
	BEGIN
		INSERT INTO PG_update_log_Supplier
			VALUES(	@run_nr,
					@run_date,
					1,
					@step,
					'Succeded QC #2 totalTransactions_supplier_dist: percentages sum up to ~1',
					SYSDATETIME()
				)
	END
ELSE
	BEGIN
		INSERT INTO PG_update_log_Supplier
			VALUES(	@run_nr,
					@run_date,
					1,
					@step,
					'Failed QC #2 totalTransactions_supplier_dist: percentages dont sum up to ~1',
					SYSDATETIME()
				)
	END

--3)
SELECT @p1=MIN(perc_CatRev),
	   @p2=AVG(perc_CatRev),
	   @p3=MAX(perc_CatRev),
	   @p4=MIN(perc_rev),
	   @p5=AVG(perc_rev),
	   @p6=MAX(perc_rev)
FROM Shufersal.dbo.PG_Wave1_5_subgroups_supplier_dist

SET @step = @step + 1;
IF (@p1>=0 AND @p1<=1 AND @p2>=0 AND @p2<=1 AND @p3>=0 AND @p3<=1 AND @p4>=0 AND @p4<=1 AND @p5>=0 AND @p5<=1 AND @p6>=0 AND @p6<=1 AND @p2<=0.5 AND @p5<=0.5)
	BEGIN
		INSERT INTO PG_update_log_Supplier
			VALUES(	@run_nr,
					@run_date,
					1,
					@step,
					'Succeded QC #3 subgroups_supplier_dist: all percentages are in [0,1], avg is close to 0',
					SYSDATETIME()
				)
	END
ELSE
	BEGIN
		INSERT INTO PG_update_log_Supplier
			VALUES(	@run_nr,
					@run_date,
					1,
					@step,
					'Failed QC #3 subgroups_supplier_dist: wierd percentages values',
					SYSDATETIME()
				)
	END

--4) 
SELECT @p1=MIN(a),
	   @p2=AVG(a),
	   @p3=MAX(a),
	   @p4=MIN(b),
	   @p5=AVG(b),
	   @p6=MAX(b) 
FROM (SELECT SUM(perc_CatRev) AS a,
			 SUM(perc_rev) AS b,
			 Branch_name_EN,
			 SourceInd,level_ID
	  FROM Shufersal.dbo.PG_Wave1_5_subgroups_supplier_dist
	  GROUP BY Branch_name_EN,SourceInd,level_ID) p

SET @step = @step + 1;
IF (@p3>=0.9 AND @p3<=1.1 AND @p2>=0.9 AND @p2<=1.1 AND @p5>=0.9 AND @p5<=1.11 AND @p6>=0.9 AND @p6<=1.1)
	BEGIN
		INSERT INTO PG_update_log_Supplier
			VALUES(	@run_nr,
					@run_date,
					1,
					@step,
					'Succeded QC #4 subgroups_supplier_dist: percentages sum up to ~1',
					SYSDATETIME()
				)
	END
ELSE
	BEGIN
		INSERT INTO PG_update_log_Supplier
			VALUES(	@run_nr,
					@run_date,
					1,
					@step,
					'Failed QC #4 subgroups_supplier_dist: percentages dont sum up to ~1',
					SYSDATETIME()
				)
	END


SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			1,
			@step,
			'Part #1 END - Distribtuion of suppliers on Transactions in total and in group level',
			SYSDATETIME()
		)

--**********************************************************************************************************
--**********************************************************************************************************
--*********************************CATALOG REVENUE to REGULAR REVENUE ratio**********************************
--**********************************************************************************************************
--**********************************************************************************************************

SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			1,
			@step,
			'Part #2 START - Ratios between catalog revenue and regular revenue',
			SYSDATETIME()
		)

--Calculate the general Ratio bewteen catalog revenue and store price revenue
--This is a simplification. If we had time we would have added a supplier_ID and catalog price to the transaction table and did the same calculation Jesper did for the new table.
--Since we didn't have time we used this simplification
IF OBJECT_ID('Shufersal.dbo.PG_Wave1_5_Catalog_revenue_ratio_tot', 'U') IS NOT NULL
    DROP TABLE Shufersal.dbo.PG_Wave1_5_Catalog_revenue_ratio_tot;
SELECT t1.Branch_name_EN,
       t1.SourceInd,
	   CASE WHEN SUM(CASE WHEN t1.CatalogRevenue IS NULL THEN 0 
						  ELSE t1.Revenue 
						  END)=0 THEN 0 
			ELSE SUM(ISNULL(t1.CatalogRevenue/t1.cnt_suppliers,0))/SUM(CASE WHEN t1.CatalogRevenue IS NULL THEN 0 
																			ELSE t1.Revenue/t1.cnt_suppliers 
																			END) 
			END AS catRev2Rev_Ratio
INTO Shufersal.dbo.PG_Wave1_5_Catalog_revenue_ratio_tot
FROM Shufersal.dbo.Wave1_5_PG_sales_per_product_per_day_wo_returns t1
GROUP BY t1.Branch_name_EN,t1.SourceInd

IF OBJECT_ID('tempdb..#cat2rev_ratio_subgroup_level_ID' ,'U') IS NOT NULL
    DROP TABLE #cat2rev_ratio_subgroup_level_ID;
SELECT t1.level_ID,
	   t2.SourceInd,
	   t2.Branch_name_EN,
	   SUM(t2.sum_rev) AS sum_rev,
	   SUM(t2.sum_cat_rev) AS sum_cat_rev,
	   COUNT(t1.product_ID) AS Num_products
INTO #cat2rev_ratio_subgroup_level_ID
FROM Shufersal.dbo.PG_product_substitute_levels t1
LEFT JOIN (SELECT p1.ProductNumber,
				  p1.SourceInd,
				  p1.Branch_name_EN,
				  SUM(CASE WHEN p1.CatalogRevenue IS NULL THEN 0 
						   ELSE p1.Revenue 
						   END) AS sum_rev,
				  SUM(CASE WHEN p1.Revenue=0 THEN 0 
						   ELSE ISNULL(p1.CatalogRevenue,0) 
						   END) AS sum_cat_rev
		   FROM Shufersal.dbo.Wave1_5_PG_sales_per_product_per_day_wo_returns p1
		   GROUP BY p1.ProductNumber,p1.SourceInd,p1.Branch_name_EN) t2
ON t2.ProductNumber=t1.product_ID
GROUP BY t1.level_ID,t2.SourceInd,t2.Branch_name_EN


--Calculate the Ratio bewteen catalog revenue and store price revenue inside the substitution groups of each product
--Since a product can be in multiple subgroups then we do have doubles, but the assumption is that overall it will tone down
--One should also note that we make the distribution for all subgroups that are in transactions during this time, and it can be the case that some poructs were not sold but are in a subgroups with some that were, in which case they will be on the list but won't be used at the update
--This is why alot of products can have big catRev2Rev_Ratio, but practicaly it's just one product that makes the problem and the ratio therefor will be used only once as well
IF OBJECT_ID('Shufersal.dbo.PG_Wave1_5_Catalog_revenue_ratio_subs', 'U') IS NOT NULL
    DROP TABLE Shufersal.dbo.PG_Wave1_5_Catalog_revenue_ratio_subs;
SELECT m.product_ID AS ProductNumber,
	   m.Branch_name_EN,
	   m.SourceInd,
	   AVG(m.Num_products) AS Num_Products,
	   CASE WHEN SUM(ISNULL(m.sum_rev,0))=0 THEN 0 
		    ELSE SUM(ISNULL(m.sum_cat_rev,0))/SUM(ISNULL(m.sum_rev,0)) 
			END AS catRev2Rev_Ratio
INTO Shufersal.dbo.PG_Wave1_5_Catalog_revenue_ratio_subs
FROM (SELECT t1.product_ID, t1.level_ID,
			 t2.SourceInd,
			 t2.Branch_name_EN,
			 t2.sum_rev,
			 t2.sum_cat_rev,
			 t2.Num_products
	FROM Shufersal.dbo.PG_product_substitute_levels t1
	LEFT JOIN #cat2rev_ratio_subgroup_level_ID t2
	ON t2.level_ID=t1.level_ID) m
GROUP BY m.product_ID,
		 m.Branch_name_EN,
		 m.SourceInd


--5) 
SELECT @p1=MIN(catRev2Rev_Ratio),
	   @p2=AVG(catRev2Rev_Ratio),
	   @p3=MAX(catRev2Rev_Ratio)
FROM Shufersal.dbo.PG_Wave1_5_Catalog_revenue_ratio_tot

SET @step = @step + 1;
IF (@p2<=1 AND @p3<=2)
	BEGIN
		INSERT INTO PG_update_log_Supplier
			VALUES(	@run_nr,
					@run_date,
					1,
					@step,
					'Succeded QC #5 Catalog_revenue_ratio_tot: ratios make sense',
					SYSDATETIME()
				)
	END
ELSE
	BEGIN
		INSERT INTO PG_update_log_Supplier
			VALUES(	@run_nr,
					@run_date,
					1,
					@step,
					'Failed QC #5 Catalog_revenue_ratio_tot: ratios dont make sense',
					SYSDATETIME()
				)
	END

--6)
IF EXISTS (SELECT t1.Branch_name_EN,t1.SourceInd
		   FROM (SELECT Branch_name_EN,SourceInd
				 FROM Shufersal.dbo.PG_input_RAS
				 WHERE TransactionDate>=@start_date_1_5 AND TransactionDate<=@end_date_1_5
				 GROUP BY Branch_name_EN,SourceInd) t1
		   LEFT JOIN (SELECT Branch_name_EN,SourceInd
					  FROM Shufersal.dbo.PG_Wave1_5_Catalog_revenue_ratio_tot
					  GROUP BY Branch_name_EN,SourceInd) t2
		   ON t1.Branch_name_EN=t2.Branch_name_EN
		   AND t1.SourceInd=t2.SourceInd
		   WHERE t2.Branch_name_EN IS NULL)
	BEGIN 
		SET @step = @step + 1;
		INSERT INTO PG_update_log_Supplier
			VALUES(	@run_nr,
					@run_date,
					1,
					@step,
					'FAILED QC #6 Catalog_revenue_ratio_tot: missing branches/source_ind from RAS',
					SYSDATETIME()
				)
	END
ELSE
	BEGIN 
		SET @step = @step + 1;
		INSERT INTO PG_update_log_Supplier
			VALUES(	@run_nr,
					@run_date,
					1,
					@step,
					'Succeded QC #6 Catalog_revenue_ratio_tot: All branches/source_ind from RAS exist in dist tables',
					SYSDATETIME()
				)
	END

--7) 
SELECT @p1=MIN(catRev2Rev_Ratio),
	   @p2=AVG(catRev2Rev_Ratio),
	   @p3=MAX(catRev2Rev_Ratio)
FROM Shufersal.dbo.PG_Wave1_5_Catalog_revenue_ratio_subs

SET @step = @step + 1;
IF (@p2<=3 AND @p3<=10)
	BEGIN
		INSERT INTO PG_update_log_Supplier
			VALUES(	@run_nr,
					@run_date,
					1,
					@step,
					'Succeded QC #5 Catalog_revenue_ratio_subs: ratios make sense',
					SYSDATETIME()
				)
	END
ELSE
	BEGIN
		INSERT INTO PG_update_log_Supplier
			VALUES(	@run_nr,
					@run_date,
					1,
					@step,
					'Failed QC #5 Catalog_revenue_ratio_subs: ratios dont make sense',
					SYSDATETIME()
				)
	END

--8)
IF EXISTS (SELECT t1.Branch_name_EN,t1.SourceInd,t1.ProductNumber
		   FROM (SELECT Branch_name_EN,SourceInd,ProductNumber
				 FROM Shufersal.dbo.PG_input_RAS
				 WHERE TransactionDate>=@start_date_1_5 AND TransactionDate<=@end_date_1_5
				 GROUP BY Branch_name_EN,SourceInd,ProductNumber) t1
		   LEFT JOIN (SELECT Branch_name_EN,SourceInd,ProductNumber
				 	  FROM Shufersal.dbo.PG_Wave1_5_Catalog_revenue_ratio_subs
					  GROUP BY Branch_name_EN,SourceInd,ProductNumber) t2
		   ON t1.Branch_name_EN=t2.Branch_name_EN
		   AND t1.SourceInd=t2.SourceInd
		   AND t1.ProductNumber=t2.ProductNumber
		   WHERE t2.ProductNumber IS NULL)
	BEGIN 
		SET @step = @step + 1;
		INSERT INTO PG_update_log_Supplier
			VALUES(	@run_nr,
					@run_date,
					1,
					@step,
					'FAILED QC #8 Catalog_revenue_ratio_subs: missing products from RAS',
					SYSDATETIME()
				)
	END
ELSE
	BEGIN 
		SET @step = @step + 1;
		INSERT INTO PG_update_log_Supplier
			VALUES(	@run_nr,
					@run_date,
					1,
					@step,
					'Succeded QC #8 Catalog_revenue_ratio_subs: All products from RAS exist in dist tables',
					SYSDATETIME()
				)
	END


SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			1,
			@step,
			'Part #2 END - Ratios between catalog revenue and regular revenue',
			SYSDATETIME()
		)

SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			1,
			@step,
			'End of [Supplier_update_1b_Update_supplier_distributions] table',
			SYSDATETIME()
		)

END
