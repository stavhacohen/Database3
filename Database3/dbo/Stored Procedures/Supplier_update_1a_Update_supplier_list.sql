-- =============================================
-- Author:		Gal Naamani
-- Create date:	2018-12-13
-- Description:	Updates Supplier list + Catalog prices
-- =============================================
CREATE PROCEDURE [dbo].[Supplier_update_1a_Update_supplier_list]
    @run_nr INT = 1,
    @step INT = 1,
    @run_date DATE = '2017-10-10'
AS
BEGIN

INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			1,
			@step,
			'Start of [Supplier_update_1a_Update_supplier_list]',
			SYSDATETIME()
		)


-- Correction for missing Supplier Data and Multiple Supplier Data of new import file
--Multiple What we do : 
--1) For now we just take the latest starting supplier
IF OBJECT_ID('tempdb..#DealWithMultiSup' ,'U') IS NOT NULL
    DROP TABLE #DealWithMultiSup;
SELECT t.ProductNumber,
		t.Branch_name_EN,
		t.SupplierNumber,
	   t.StartDate,
		t.Catalog_price
INTO #DealWithMultiSup
FROM (	SELECT m2.*,
			   ROW_NUMBER() OVER (PARTITION BY ProductNumber,Branch_name_EN ORDER BY StartDate,Catalog_price DESC) as OrderByRank
		FROM (SELECT p3.ProductNumber,
					 p3.StartDate,
					 p3.SupplierNumber,
					 p3.Branch_name_EN,
					 AVG(p3.Catalog_PRice) AS Catalog_price 
			  FROM  (SELECT p1.ProductNumber,
							p1.StartDate,
							p1.SupplierNumber,
							CAST(p1.Catalog_Price AS DECIMAL(9,2)) AS Catalog_price,
							p2.Branch_name_EN
					 FROM Shufersal.dbo.PG_purchase_discount_update p1
					 LEFT JOIN Staging_branches p2
					 ON p2.Branch_ID=p1.Sub_chain) p3
					 GROUP BY p3.ProductNumber,p3.StartDate,p3.SupplierNumber,p3.Branch_name_EN
			) m2
) t
WHERE OrderByRank=1

--Correction for missing Supplier Data - What we do : 
--1) Take all the rows with missing supplier ID (t1) and add to them the relevant supplier rows (t2) based on product and dates
--2) We also add there for each supplier the number of other branches it was seen in (cnt_supplier_branch)
--3) Then we give each supplier for a specific original row (from t1) a rank based on : a) Illan's Rules b) How frequent it is in other branches c) Hierarchy of the branches
--3_5) Illan's rules are : For all -> first look at Sheli then Deal, For Deal --> first look at Extra then Sheli, For Extra --> first look at Deal then Sheli
--4) In this ranking (OrderByRank) we first look at which supplier is most frequent, and if there are many with the same frequency, we had that which is in the highest hierarchy branch. If there are two of these, we choose randomly one of them 
IF OBJECT_ID('tempdb..#DealWithMissingSup_1' ,'U') IS NOT NULL
    DROP TABLE #DealWithMissingSup_1;
SELECT t1.ProductNumber,
	   t2.Branch_name_EN,
	   t3.StartDate,
	   t3.SupplierNumber,
	   t3.Catalog_Price
INTO #DealWithMissingSup_1
FROM (SELECT DISTINCT productnumber 
	  FROM #DealWithMultiSup) t1
CROSS JOIN (SELECT DISTINCT Branch_name_EN 
		    FROM #DealWithMultiSup) t2
LEFT JOIN #DealWithMultiSup t3
ON t1.ProductNumber=t3.ProductNumber
AND ISNULL(t2.Branch_name_EN,'Other')=ISNULL(t3.Branch_name_EN,'Other')

IF OBJECT_ID('tempdb..#DealWithMissingSup_2' ,'U') IS NOT NULL
    DROP TABLE #DealWithMissingSup_2;
SELECT m2.*,
	   ROW_NUMBER() OVER (PARTITION BY ProductNumber,Branch_name_EN ORDER BY SupplierRanking_internal,startdate DESC) AS OrderByRank
INTO #DealWithMissingSup_2
FROM (SELECT m.*,
	         CASE WHEN m.Branch_name_EN='Other' THEN 0
				  WHEN m.Branch_name_EN='Deal' and m.Branch_2='Extra' THEN 1000+m.cnt_supp_branches*10
				  WHEN m.Branch_name_EN='Extra' and m.Branch_2='Deal' THEN 1000+m.cnt_supp_branches*10
				  WHEN m.Branch_2='Sheli' THEN 110+m.cnt_supp_branches*10
				  WHEN m.Branch_2='Deal' THEN 100+m.cnt_supp_branches*10
				  WHEN m.Branch_2='Extra' THEN 7+m.cnt_supp_branches*10
				  WHEN m.Branch_2='Organic' THEN 6+m.cnt_supp_branches*10
				  WHEN m.Branch_2='Online' THEN 5+m.cnt_supp_branches*10
				  WHEN m.Branch_2='Express' THEN 4+m.cnt_supp_branches*10
				  ELSE m.cnt_supp_branches*10 END AS SupplierRanking_internal
	  FROM (SELECT t1.ProductNumber,
					t1.Branch_name_EN,
					t2.Branch_2,
					t2.SupplierNumber,
					t2.StartDate,
					t2.Catalog_price,
					t2.cnt_supp_branches
			FROM (SELECT * 
			      FROM #DealWithMissingSup_1 
				  WHERE SupplierNumber IS NULL AND ProductNumber IS NOT NULL) t1
		    LEFT JOIN (SELECT t.ProductNumber,
								t.StartDate,
								t.SupplierNumber,
								t.Branch_name_EN AS Branch_2,
								t.Catalog_price,
							  COUNT(*) OVER (PARTITION BY t.ProductNumber,t.SupplierNumber) AS cnt_supp_branches
						FROM #DealWithMissingSup_1 t
						WHERE t.SupplierNumber is not null) t2
			ON t1.ProductNumber=t2.ProductNumber) m
	) m2

IF OBJECT_ID('tempdb..#DealWithMissingSup' ,'U') IS NOT NULL
    DROP TABLE #DealWithMissingSup;
SELECT t.ProductNumber,t.Branch_name_EN,t.SupplierNumber,t.StartDate,t.Catalog_price
INTO #DealWithMissingSup
FROM #DealWithMissingSup_2 t
WHERE OrderByRank=1
AND SupplierNumber IS NOT NULL

--************************** END OF CORRECTION FOR MISSING SUPPLIER DATA **********************


--connect both
IF OBJECT_ID('tempdb..#Connect' ,'U') IS NOT NULL
    DROP TABLE #Connect;
SELECT t.ProductNumber AS ProductNumber,
	   t.Branch_name_EN AS Branch_name_EN,
	   t.SupplierNumber AS SupplierNumber,
	   CONVERT(DATE,CONVERT(VARCHAR(10),StartDate,101)) AS StartDate,
	   t.Catalog_price as Catalog_price
INTO #Connect 
FROM (SELECT * 
	  FROM #DealWithMissingSup
	  UNION 
	  SELECT * FROM #DealWithMultiSup) t
WHERE Branch_name_EN is not null

--create a temporary table with the old supplier list
IF OBJECT_ID('tempdb..#OldSupp' ,'U') IS NOT NULL
    DROP TABLE #OldSupp;
SELECT *
INTO #OldSupp
FROM Shufersal.dbo.PG__Wave1_5_Supplier_CatalogPrices

--Update the supplier list
IF OBJECT_ID('Shufersal.dbo.PG__Wave1_5_Supplier_CatalogPrices', 'U') IS NOT NULL
    DROP TABLE Shufersal.dbo.PG__Wave1_5_Supplier_CatalogPrices;
SELECT *
INTO Shufersal.dbo.PG__Wave1_5_Supplier_CatalogPrices
FROM (SELECT * 
	  FROM #Connect
	  UNION 
	  SELECT * 
	  FROM #OldSupp
	  WHERE ProductNumber in (SELECT pn2
							  FROM (SELECT t1.ProductNumber AS pn1,
										   t2.ProductNumber AS pn2
									FROM (SELECT DISTINCT productNumber 
									      FROM #Connect) t1
									FULL OUTER JOIN (SELECT DISTINCT productNumber 
											         FROM #OldSupp) t2
									ON t1.ProductNumber=t2.ProductNumber) p
									WHERE pn1 is null
								)
	) p


SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			1,
			@step,
			'Finished updating PG__Wave1_5_Supplier_CatalogPrices [Supplier_update_1a_Update_supplier_list]',
			SYSDATETIME()
		)

SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			1,
			@step,
			'Start Quality checks [Supplier_update_1a_Update_supplier_list]',
			SYSDATETIME()
		)


DECLARE @p1 float;
DECLARE @p2 float;

--Data Quality Checks
--1)
SELECT @p1=COUNT(*) 
FROM #OldSupp
Select @p2=COUNT(*) 
FROM Shufersal.dbo.PG__Wave1_5_Supplier_CatalogPrices

IF (@p1 - @p2)>0 
	BEGIN 
		SET @step = @step + 1;
		INSERT INTO PG_update_log_Supplier
			VALUES(	@run_nr,
					@run_date,
					1,
					@step,
					'FAILED: Quality check #1 [Supplier_update_1a_Update_supplier_list]: #Products/Branches got smaller',
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
					'Succeded: Quality check #1 [Supplier_update_1a_Update_supplier_list]: #Products/Branches Okay',
					SYSDATETIME()
				)
	END

--2)
SELECT @p1=COUNT(*) 
FROM Shufersal.dbo.PG__Wave1_5_Supplier_CatalogPrices
SELECT @p2=COUNT(*) FROM (SELECT DISTINCT ProductNumber,Branch_name_EN 
						  FROM Shufersal.dbo.PG__Wave1_5_Supplier_CatalogPrices) t

IF (@p1 <> @p2) 
	BEGIN 
		SET @step = @step + 1;
		INSERT INTO PG_update_log_Supplier
			VALUES(	@run_nr,
					@run_date,
					1,
					@step,
					'FAILED: Quality check #2 [Supplier_update_1a_Update_supplier_list]: List not unique on Product and Branch',
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
					'Succeded: Quality check #2 [Supplier_update_1a_Update_supplier_list]: unique on Product and Branch',
					SYSDATETIME()
				)
	END


--3) 
SELECT @p1=MIN(cnt) 
FROM (SELECT productNumber,COUNT(*) AS cnt 
      FROM Shufersal.dbo.PG__Wave1_5_Supplier_CatalogPrices 
	  GROUP BY productNumber) t
SELECT @p2=MAX(cnt) 
FROM (SELECT productNumber,COUNT(*) AS cnt 
	  FROM Shufersal.dbo.PG__Wave1_5_Supplier_CatalogPrices 
	  GROUP BY productNumber) t

IF (@p1 <> @p2) 
	BEGIN 
		SET @step = @step + 1;
		INSERT INTO PG_update_log_Supplier
			VALUES(	@run_nr,
					@run_date,
					1,
					@step,
					'FAILED: Quality check #3: Not all products have all possible branches',
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
					'Succeded: Quality check #3: all products have all possible branches',
					SYSDATETIME()
				)
	END

--4)
IF EXISTS (SELECT * 
		   FROM Shufersal.dbo.PG__Wave1_5_Supplier_CatalogPrices 
		   WHERE ProductNumber IS NULL 
		   OR SupplierNumber IS NULL 
		   OR Branch_name_EN IS NULL)
	BEGIN 
		SET @step = @step + 1;
		INSERT INTO PG_update_log_Supplier
			VALUES(	@run_nr,
					@run_date,
					1,
					@step,
					'FAILED: Quality check #4 [Supplier_update_1a_Update_supplier_list]: Nulls Exists',
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
					'Succeded: Quality check #4 [Supplier_update_1a_Update_supplier_list]: No Nulls',
					SYSDATETIME()
				)
	END


SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			1,
			@step,
			'End Quality checks [Supplier_update_1a_Update_supplier_list]',
			SYSDATETIME()
		)


SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			1,
			@step,
			'End of [PG_supplier_billing_in_sales_update] table',
			SYSDATETIME()
		)

TRUNCATE TABLE Shufersal.dbo.Staging_purchase_discount_import;

END