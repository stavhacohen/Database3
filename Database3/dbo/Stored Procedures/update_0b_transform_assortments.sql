-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-10
-- Description:	Transforms product and supplier assortments into readible files
-- =============================================
CREATE PROCEDURE [dbo].[update_0b_transform_assortments]
    @run_nr INT = 1,
    @step INT = 1,
    @run_date DATE = '2017-10-10'
AS
BEGIN

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'Start of [update_0b_transform_assortments]',
			SYSDATETIME()
		)

/* STEP 1: Update product assortment */
-- Only execute when there is an update 
IF (SELECT MAX(Product_ID) FROM Staging_assortment_product_update) IS NOT NULL
BEGIN

--!!! Fix
DELETE FROM Staging_assortment_product_update
WHERE	  TRY_CONVERT(INT,Brand) IS NULL

-- Selects new products
IF OBJECT_ID('tempdb.dbo.#product_assortment_new','U') IS NOT NULL
    DROP TABLE #product_assortment_new
SELECT	  pau.*
INTO		  #product_assortment_new
FROM		  Staging_assortment_product_update pau
LEFT JOIN	  PG_product_assortment pa
ON		  pa.Product_ID = pau.Product_ID
WHERE	  pa.Product_ID IS NULL

-- Update product assortment
INSERT INTO PG_product_assortment
SELECT	  ISNULL(sd.Department,0),
		  Subdepartment,
		  Category,
		  [Group],
		  Subgroup,
		  ISNULL(Grouping,0),
		  Product_ID,
		  Product_name_HE,
		  Brand,
		  Brand_HE,
		  Category_manager,
		  Category_manager_name_HE,
		  CASE WHEN bp.Brand_ID IS NOT NULL THEN 1 ELSE 0 END AS 'Private_label'
FROM		  #product_assortment_new pa
LEFT JOIN   (SELECT Subdepartment_ID, MIN(Department_ID) AS 'Department' FROM PG_product_assortment GROUP BY Subdepartment_ID) sd
ON		  pa.Subdepartment = sd.Subdepartment_ID
LEFT JOIN	  Staging_brands_private_label bp
ON		  bp.Brand_ID = pa.Brand

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'Product assortment updated',
			SYSDATETIME()
		)

-- Update hierarchy names
IF OBJECT_ID('tempdb.dbo.#hierarchy_names_HE_update','U') IS NOT NULL
    DROP TABLE #hierarchy_names_HE_update
SELECT	  'Department' AS 'Level',
		  Department AS 'Level_ID',
		  Department_name_HE AS 'Level_name_HE'
INTO		  #hierarchy_names_HE_update
FROM		  Staging_assortment_product_update
GROUP BY	  Department,
		  Department_name_HE
UNION
SELECT	  'Subdepartment',
		  Subdepartment,
		  Subdepartment_name_HE
FROM		  Staging_assortment_product_update
GROUP BY	  Subdepartment,
		  Subdepartment_name_HE
UNION
SELECT	  'Category',
		  Category,
		  Category_name_HE
FROM		  Staging_assortment_product_update
GROUP BY	  Category,
		  Category_name_HE
UNION
SELECT	  'Group',
		  [Group],
		  Group_name_HE
FROM		  Staging_assortment_product_update
GROUP BY	  [Group],
		  Group_name_HE
UNION
SELECT	  'Subgroup',
		  [Group]*10+Subgroup,
		  Subgroup_name_HE
FROM		  Staging_assortment_product_update
GROUP BY	  [Group]*10+Subgroup,
		  Subgroup_name_HE

INSERT INTO PG_hierarchy_names
SELECT	  hnu.Level,
		  hnu.Level_ID,
		  hnu.Level_name_HE,
		  NULL
FROM		  #hierarchy_names_HE_update hnu
LEFT JOIN	  PG_hierarchy_names hn
ON		  hnu.Level = hn.Level
	   AND hnu.Level_ID = hn.Level_ID
WHERE	  hn.Level_ID IS NULL AND hnu.Level_ID IS NOT NULL

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'Hierarchy levels and names selected',
			SYSDATETIME()
		)

-- Update leveled product assortment
INSERT INTO PG_product_assortment_leveled
SELECT	  'Department' AS 'Level',
		  Department AS 'Level_ID',
		  Product_ID
FROM		  #product_assortment_new
UNION
SELECT	  'Subdepartment',
		  Subdepartment,
		  Product_ID
FROM		  #product_assortment_new
UNION
SELECT	  'Category',
		  Category,
		  Product_ID
FROM		  #product_assortment_new
UNION
SELECT	  'Group',
		  [Group],
		  Product_ID
FROM		  #product_assortment_new
UNION
SELECT	  'Subgroup',
		  [Group]*10+Subgroup,
		  Product_ID
FROM		  #product_assortment_new

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'Leveled product assortment created',
			SYSDATETIME()
		)

-- Moves updated product assortment information to history
INSERT INTO Staging_assortment_product
SELECT	  *,
		  @run_date
FROM		  Staging_assortment_product_update
TRUNCATE TABLE Staging_assortment_product_update

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'Moves updated product assortment information to history',
			SYSDATETIME()
		)

END

/* STEP 2: Update supplier assortment */
-- Only execute when there is an update 
IF (SELECT MAX(Product_ID) FROM Staging_assortment_supplier_update) IS NOT NULL
BEGIN

-- Selects supplier with minimum id
IF OBJECT_ID('tempdb.dbo.#suppliers','U') IS NOT NULL
    DROP TABLE #suppliers
SELECT	  sa.Product_ID,
		  br.Branch_name_EN,
		  COALESCE(MIN(CASE WHEN Date_deleted = 0 OR Date_reactivation > Date_deleted THEN Supplier_ID ELSE NULL END),
				 MIN(Supplier_ID))
				AS 'supplier',
		  COUNT(DISTINCT Supplier_ID) AS 'nr_suppliers'
INTO		  #suppliers
FROM		  Staging_assortment_supplier_update sa
LEFT JOIN	  Staging_branches br
ON		  sa.Branch_ID = br.Branch_ID
GROUP BY	  sa.Product_ID,
		  br.Branch_name_EN

-- Selects supplier with product number and branch
IF OBJECT_ID('tempdb.dbo.#product_supplier_branch','U') IS NOT NULL
    DROP TABLE #product_supplier_branch
SELECT	  spp.ProductNumber,
		  spp.Branch_name_EN,
		  sa.supplier,
		  SUM(ISNULL(spp.Revenue,0)) AS 'Total_revenue'
INTO		  #product_supplier_branch
FROM		  PG_sales_per_product_per_day_wo_returns spp
LEFT JOIN	  #suppliers sa
ON		  spp.ProductNumber = sa.Product_ID
	   AND spp.Branch_name_EN = sa.Branch_name_EN
GROUP BY	  spp.ProductNumber,
		  spp.Branch_name_EN,
		  sa.supplier

-- Selects minimum supplier id per product number from generated file
IF OBJECT_ID('tempdb.dbo.#suppliers_per_product','U') IS NOT NULL
    DROP TABLE #suppliers_per_product
SELECT	  ProductNumber,
		  MIN(supplier) AS 'supplier'
INTO		  #suppliers_per_product
FROM		  #product_supplier_branch
GROUP BY	  ProductNumber

-- Selects minimum supplier id per product number from supplier file
IF OBJECT_ID('tempdb.dbo.#product_assortment','U') IS NOT NULL
    DROP TABLE #product_assortment
SELECT	  Product_ID,
		  MIN(Supplier_ID) AS 'supplier'
INTO		  #product_assortment		  
FROM		  Staging_product_assortment
GROUP BY	  Product_ID

-- Selects supplier per product and branch into update file
IF OBJECT_ID('dbo.PG_supplier_assortment_update','U') IS NOT NULL
    DROP TABLE PG_supplier_assortment_update
SELECT	  psb.ProductNumber,
		  psb.Branch_name_EN,
		  psb.Total_revenue,
		  COALESCE(psb.supplier,spp.supplier,pa.supplier) AS 'supplier'
INTO		  PG_supplier_assortment_update
FROM		  #product_supplier_branch psb
LEFT JOIN	  #suppliers_per_product spp
ON		  psb.ProductNumber = spp.ProductNumber
LEFT JOIN	  #product_assortment pa
ON		  psb.ProductNumber = pa.Product_ID

-- Inserts data into supplier assortment table
INSERT INTO PG_supplier_assortment
SELECT	  su.*
FROM		  PG_supplier_assortment_update su
LEFT JOIN	  PG_supplier_assortment s
ON		  su.Branch_name_EN = s.Branch_name_EN
	   AND su.ProductNumber = s.ProductNumber
WHERE	  su.ProductNumber IS NULL

-- Moves updated supplier assortment information to history
INSERT INTO Staging_assortment_supplier
SELECT	  su.*, @run_date
FROM		  Staging_assortment_supplier_update su
TRUNCATE TABLE Staging_assortment_supplier_update

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'Created new supplier assortment table',
			SYSDATETIME()
		)

END

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'End of [update_0b_transform_assortments]',
			SYSDATETIME()
		)
END
