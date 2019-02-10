
-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-18
-- Description:	Prepares promotion tables
-- Run time:		13m05s (2017-10-11)
-- =============================================
Create PROCEDURE [dbo].[MM_update_7a_ROI_promotions_prepare]
	@run_nr INT = 1,
	@run_date DATE = '2018-12-06',
	@step INT = 1,
	@start_date DATE = '2018-10-01',
	@end_date DATE = '2018-10-07',
	@after_days INT = 28
AS
BEGIN

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Start of [update_7a_ROI_promotions_prepare]',
			SYSDATETIME()
		)

-- Move promotion indicator data to history (if there is new data)
IF (SELECT MAX(TransactionDate) FROM PG_promo_product_ind_update) IS NOT NULL
BEGIN
    DECLARE @date DATE = @start_date;

    WHILE @date <= @end_date
    BEGIN							 
	   DELETE FROM PG_promo_product_ind
	   WHERE		TransactionDate = @date;

	   INSERT INTO PG_promo_product_ind
	   SELECT		*
	   FROM		PG_promo_product_ind_update
	   WHERE		TransactionDate = @date

	   SET @step = @step + 1;
	   INSERT INTO PG_update_log
	   VALUES(	@run_nr,
				@run_date,
				7,
				@step,
				CONCAT('Data deleted from PG_promo_product_ind on ',@date),
				SYSDATETIME()
			 );
	   
	   SET		@date = DATEADD(day,1,@date);
    END
    
    TRUNCATE TABLE PG_promo_product_ind_update
END

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Data inserted into PG_promo_product_ind',
			SYSDATETIME()
		)

---- Move transactions data to history (if there is new data)
--IF (SELECT MAX(TransactionDate) FROM Staging_transactions_total_update) IS NOT NULL
--BEGIN

--    SET @date = @start_date
--    WHILE @date <= @end_date
--    BEGIN
--	   INSERT INTO Staging_transactions_total
--	   SELECT		*
--	   FROM		Staging_transactions_total_update
--	   WHERE		TransactionDate = @date

--	   SET @step = @step + 1;
--	   INSERT INTO PG_update_log
--	   VALUES(	@run_nr,
--				@run_date,
--				7,
--				@step,
--				CONCAT('Data inserted into Staging_transactions_total for ',@date),
--				SYSDATETIME()
--			 );
	   
--	   SET		@date = DATEADD(day,1,@date)
--    END

--    TRUNCATE TABLE Staging_transactions_total_update
--END

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Transactions data moved to history',
			SYSDATETIME()
		)

-- Combines different data sources on promotions
IF OBJECT_ID('tempdb.dbo.#promotions_start_table','U') IS NOT NULL
    DROP TABLE #promotions_start_table
SELECT	  pr.CampaignNumberPromo,
		  pr.CampaignDesc,
		  pr.PromotionNumber,
		  pr.PromotionCharacteristicsType,
		  pr.PromotionNumberUnv,
		  pr.PromotionDesc,
		  pr.PromotionStartDate,
		  pr.PromotionEndDate,
		  pr.SourceInd,
		  pr.ProductNumber,
		  pr.DiscountType,
		  CASE WHEN pd.Display_name_EN LIKE '%STAGE%' OR pd.Display_name_EN LIKE '%Mitcham%' OR pd.Display_name_EN LIKE '%GONDOLA%'
				THEN CONCAT(pd.Display_name_EN,' ',pd.Display_number)
			 ELSE ISNULL(pd.Display_name_EN,'Other') END AS 'Place_in_store',
		  CASE WHEN pr.Folder = 'NO' THEN 0 ELSE 1 END AS 'Folder',
		  COALESCE(pr.Multibuy,CASE WHEN pm.[multibuy (divide by 10 for weight promo)] > 1 THEN pm.[multibuy (divide by 10 for weight promo)] ELSE 1 END,1)
			 AS 'Multibuy_quantity'
INTO		  #promotions_start_table
FROM		  Staging_promotions_old pr
LEFT JOIN	  Staging_promotions_display pd
ON		  pd.Promotion_ID = pr.PromotionNumberUnv
LEFT JOIN	  Staging_promotions_multibuy pm
ON		  pm.promotion# = pr.PromotionNumber
WHERE	  pr.PromotionStartDate IS NOT NULL --Promotions without promotion start date are deleted
	   AND DATEDIFF(day,pr.PromotionStartDate,pr.PromotionEndDate) <= 90
	   AND pr.PromotionEndDate >= DATEADD(day,-@after_days,@start_date)
	   AND pr.PromotionStartDate <= @end_date

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Different data sources on promotions combined',
			SYSDATETIME()
		)

-- Creates artificial sub numbers for promotions with different types
IF OBJECT_ID('tempdb.dbo.#promotions_sub_numbers','U') IS NOT NULL
    DROP TABLE #promotions_sub_numbers
SELECT	  PromotionNumber,
		  PromotionDesc,
		  DiscountType,
		  Place_in_store,
		  Folder,
		  Multibuy_quantity,
		  ROW_NUMBER() OVER(PARTITION BY PromotionNumber ORDER BY PromotionDesc, DiscountType
													   , Place_in_store, Folder, Multibuy_quantity
													   ) AS 'PromotionSubNumber'
INTO		  #promotions_sub_numbers
FROM		  #promotions_start_table
GROUP BY	  PromotionNumber,
		  PromotionDesc,
		  DiscountType,
		  Place_in_store,
		  Folder,
		  Multibuy_quantity

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Artificial sub numbers for promotions with different types created',
			SYSDATETIME()
		)

-- Creates definitive input file for promotions with single campaign numbers
IF OBJECT_ID('tempdb.dbo.#promotions_with_doubles','U') IS NOT NULL
    DROP TABLE #promotions_with_doubles
;WITH CTE AS
(SELECT	  PromotionNumber
 FROM	  #promotions_sub_numbers  
 GROUP BY	  PromotionNumber
 HAVING	  COUNT(*) > 1
),
CTE2 AS
(SELECT	  pr.PromotionNumber,
		  pr.PromotionDesc,
		  pr.DiscountType,
		  pr.Place_in_store,
		  pr.Folder,
		  pr.Multibuy_quantity,
		  MAX(PromotionNumberUnv) AS 'PromotionNumberUnv',
		  MAX(CampaignNumberPromo) AS 'CampaignNumberPromo'
 FROM	  #promotions_start_table pr
 GROUP BY	  pr.PromotionNumber,
		  pr.PromotionDesc,
		  pr.DiscountType,
		  pr.Place_in_store,
		  pr.Folder,
		  pr.Multibuy_quantity
),
CTE3 AS
(SELECT	  pr.PromotionNumber,
		  pr.PromotionDesc,
		  pr.DiscountType,
		  pr.Place_in_store,
		  pr.Folder,
		  pr.Multibuy_quantity,
		  CASE WHEN SUM(CASE WHEN ISNULL(pt.Branch_name_EN,pt2.Branch_name_EN) = 'Deal' THEN 1 ELSE 0 END) > 0 THEN 'Deal'
			  WHEN SUM(CASE WHEN ISNULL(pt.Branch_name_EN,pt2.Branch_name_EN) = 'Sheli' THEN 1 ELSE 0 END) > 0 THEN 'Sheli'
		  END AS 'Main_format'
 FROM	  #promotions_start_table pr
 LEFT JOIN  PG_promotions_stores pt
 ON		  pt.PromotionNumber = pr.PromotionNumber
	   AND pt.PromotionNumberUnv = pr.PromotionNumberUnv
	   AND pt.PromotionStartDate = pr.PromotionStartDate
	   AND pt.PromotionEndDate = pr.PromotionEndDate
	   AND pt.SourceInd = pr.SourceInd
	   AND pt.ProductNumber = pr.ProductNumber
	   AND pt.PromotionNumber IN (SELECT DISTINCT PromotionNumber FROM #promotions_start_table WHERE SourceInd IS NOT NULL)
LEFT JOIN	  PG_promotions_stores pt2
ON		  pt2.CampaignNumberPromo = pr.CampaignNumberPromo
	   AND pt2.PromotionNumber = pr.PromotionNumber
	   AND pt2.PromotionNumberUnv = pr.PromotionNumberUnv
	   AND pt2.PromotionStartDate = pr.PromotionStartDate
	   AND pt2.PromotionEndDate = pr.PromotionEndDate
	   AND pt2.ProductNumber = pr.ProductNumber
	   AND pt2.PromotionNumber IN (SELECT DISTINCT PromotionNumber FROM #promotions_start_table WHERE SourceInd IS NULL)
 GROUP BY	  pr.PromotionNumber,
		  pr.PromotionDesc,
		  pr.DiscountType,
		  pr.Place_in_store,
		  pr.Folder,
		  pr.Multibuy_quantity
)
SELECT	  cte2.CampaignNumberPromo,
		  CASE WHEN cte.PromotionNumber IS NULL THEN pr.PromotionNumber
			  --ELSE ps.PromotionNumber*1000+ps.PromotionSubNumber END AS 'PromotionNumber',
			  	ELSE cast(cast(ps.PromotionNumber as bigint)*1000+ cast (ps.PromotionSubNumber as bigint)as bigint) END AS 'PromotionNumber',--ADDED
		  pr.PromotionCharacteristicsType,
		  cte2.PromotionNumberUnv,
		  pr.PromotionDesc,
		  pr.PromotionStartDate,
		  pr.PromotionEndDate,
		  ISNULL(pt.SourceInd,pt2.SourceInd) AS 'SourceInd',
		  ISNULL(pt.Branch_name_EN,pt2.Branch_name_EN) AS 'Branch_name_EN',
		  pr.ProductNumber,
		  pr.DiscountType,
		  CASE WHEN pr.DiscountType = 4 AND cte3.Main_format = 'Deal' AND pa.Department_ID IN (2,3,6,7)
				 THEN 'Mitcham 1'
			  ELSE pr.Place_in_store END AS 'Place_in_store',
		  pr.Folder,
		  pr.Multibuy_quantity,
		  SUM(ppi.Promo_ind)*1.0/COUNT(ppi.TransactionDate) AS 'Promotion_perc_running_year'
INTO		  #promotions_with_doubles
FROM		  #promotions_start_table pr
LEFT JOIN	  (SELECT Department_ID, Product_ID FROM PG_product_assortment GROUP BY Department_ID, Product_ID) pa
ON		  pa.Product_ID = pr.ProductNumber
LEFT JOIN	  CTE cte
ON		  pr.PromotionNumber = cte.PromotionNumber
LEFT JOIN	  CTE2 cte2
ON		  pr.PromotionNumber = cte2.PromotionNumber
	   AND pr.PromotionDesc = cte2.PromotionDesc
	   AND pr.DiscountType = cte2.DiscountType
	   AND pr.Place_in_store = cte2.Place_in_store
	   AND pr.Folder = cte2.Folder
	   AND pr.Multibuy_quantity = cte2.Multibuy_quantity
LEFT JOIN	  CTE3 cte3
ON		  pr.PromotionNumber = cte3.PromotionNumber
	   AND pr.PromotionDesc = cte3.PromotionDesc
	   AND pr.DiscountType = cte3.DiscountType
	   AND pr.Place_in_store = cte3.Place_in_store
	   AND pr.Folder = cte3.Folder
	   AND pr.Multibuy_quantity = cte3.Multibuy_quantity
LEFT JOIN	  #promotions_sub_numbers ps
ON		  pr.PromotionNumber = ps.PromotionNumber
	   AND pr.PromotionDesc = ps.PromotionDesc
	   AND pr.DiscountType = ps.DiscountType
	   AND pr.Place_in_store = ps.Place_in_store
	   AND pr.Folder = ps.Folder
	   AND pr.Multibuy_quantity = ps.Multibuy_quantity
LEFT JOIN	  PG_promotions_stores pt
ON		  pt.CampaignNumberPromo = pr.CampaignNumberPromo
	   AND pt.PromotionNumber = pr.PromotionNumber
	   AND pt.PromotionNumberUnv = pr.PromotionNumberUnv
	   AND pt.PromotionStartDate = pr.PromotionStartDate
	   AND pt.PromotionEndDate = pr.PromotionEndDate
	   AND pt.SourceInd = pr.SourceInd
	   AND pt.ProductNumber = pr.ProductNumber
	   AND pt.PromotionNumber IN (SELECT PromotionNumber FROM #promotions_start_table WHERE SourceInd IS NOT NULL)
LEFT JOIN	  PG_promotions_stores pt2
ON		  pt2.CampaignNumberPromo = pr.CampaignNumberPromo
	   AND pt2.PromotionNumber = pr.PromotionNumber
	   AND pt2.PromotionNumberUnv = pr.PromotionNumberUnv
	   AND pt2.PromotionStartDate = pr.PromotionStartDate
	   AND pt2.PromotionEndDate = pr.PromotionEndDate
	   AND pt2.ProductNumber = pr.ProductNumber
	   AND pt2.PromotionNumber IN (SELECT PromotionNumber FROM #promotions_start_table WHERE SourceInd IS NULL)
LEFT JOIN	  PG_promo_product_ind ppi
ON		  ppi.ProductNumber = pr.ProductNumber
	   AND ppi.SourceInd = ISNULL(pr.SourceInd, pt2.SourceInd)
	   AND ppi.Branch_name_EN = ISNULL(pt.Branch_name_EN,pt2.Branch_name_EN)
	   AND ppi.TransactionDate BETWEEN DATEADD(year,-1,pr.PromotionStartDate) AND DATEADD(day,-1,pr.PromotionStartDate)
	  
GROUP BY	  cte2.CampaignNumberPromo,
		  CASE WHEN cte.PromotionNumber IS NULL THEN pr.PromotionNumber
			  --ELSE ps.PromotionNumber*1000+ps.PromotionSubNumber END,
			  ELSE cast(cast(ps.PromotionNumber as bigint)*1000+cast(ps.PromotionSubNumber as bigint)as bigint) END,--ADDED
		  pr.PromotionCharacteristicsType,
		  cte2.PromotionNumberUnv,
		  cte3.Main_format,
		  pr.PromotionDesc,
		  pr.PromotionStartDate,
		  pr.PromotionEndDate,
		  ISNULL(pt.SourceInd,pt2.SourceInd),
		  ISNULL(pt.Branch_name_EN,pt2.Branch_name_EN),
		  pr.ProductNumber,
		  pr.DiscountType,
		  CASE WHEN pr.DiscountType = 4 AND cte3.Main_format = 'Deal' AND pa.Department_ID IN (2,3,6,7)
				 THEN 'Mitcham 1'
			  ELSE pr.Place_in_store END,
		  pr.Folder,
		  pr.Multibuy_quantity

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Definitive input file for promotions with single campaign numbers created',
			SYSDATETIME()
		)

-- Creates definitive input file for promotions with single campaign numbers and campaign descriptions
IF OBJECT_ID('dbo.PG_promotions_with_doubles_update','U') IS NOT NULL
    DROP TABLE PG_promotions_with_doubles_update
;WITH CTE AS
(SELECT	  CampaignNumberPromo,
		  CampaignDesc
 FROM	  #promotions_start_table 
 GROUP BY	  CampaignNumberPromo,
		  CampaignDesc
)
SELECT	  pd.CampaignNumberPromo,
		  cte.CampaignDesc,
		  pd.PromotionNumber,
		  pd.PromotionCharacteristicsType,
		  pd.PromotionNumberUnv,
		  pd.PromotionDesc,
		  pd.PromotionStartDate,
		  pd.PromotionEndDate,
		  CAST(pd.SourceInd AS INT) 'SourceInd',
		  pd.Branch_name_EN,
		  pd.ProductNumber,
		  pd.DiscountType,
		  pd.Place_in_store,
		  pd.Folder,
		  CAST(pd.Multibuy_quantity AS INT) 'Multibuy_quantity',
		  pd.Promotion_perc_running_year
INTO		  dbo.PG_promotions_with_doubles_update
FROM		  #promotions_with_doubles pd
INNER JOIN  CTE cte
ON		  pd.CampaignNumberPromo = cte.CampaignNumberPromo
INNER JOIN  PG_branches_sources br
ON		  br.Branch_name_EN = pd.Branch_name_EN
	   AND br.SourceInd = pd.SourceInd

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Definitive input file for promotions with single campaign numbers and campaign descriptions',
			SYSDATETIME()
		)


-- Selects the most prominent promotion on a product per day
IF OBJECT_ID('tempdb.dbo.#promotions_dates','U') IS NOT NULL
    DROP TABLE #promotions_dates
SELECT	  pr.*,
		  dt.date,
		  CASE WHEN pr.CampaignNumberPromo > 80000000 THEN 1 ELSE 0 END AS 'Regular_campaign',
		  CASE WHEN pr.DiscountType IN (10,14,17,24) THEN '1. Special'
			  WHEN pr.DiscountType = 4 THEN '2. Weekly'
			  WHEN pr.DiscountType = 8 THEn '3. Cashier'
			  WHEN pr.DiscountType IN (5,20,21) THEN '4. Monthly' END AS 'Discount_type_grouped'
			  ,
		  CASE WHEN pr.Place_in_store NOT IN ('Shelf','Other','Freezer shelf','Fridge shelf') THEN 1
									    ELSE 0 END AS 'Not_on_shelf',
		  ROW_NUMBER() OVER(PARTITION BY  pr.ProductNumber,
								    pr.Branch_name_EN,
								    pr.SourceInd,
								    dt.date
					     ORDER BY	    CASE WHEN pr.CampaignNumberPromo > 80000000 THEN 1
									    ELSE 0 END DESC,
								    CASE WHEN pr.DiscountType IN (10,14,17,24) THEN '1. Special'
									    WHEN pr.DiscountType = 4 THEN '2. Weekly'
									    WHEN pr.DiscountType = 8 THEn '3. Cashier'
									    WHEN pr.DiscountType IN (5,20,21) THEN '4. Monthly' END ASC,
								    CASE WHEN pr.Place_in_store NOT IN ('Shelf','Other','Freezer shelf','Fridge shelf') THEN 1
									    ELSE 0 END DESC,
								    Multibuy_quantity DESC,
								    PromotionNumber ASC) AS 'Ind'
INTO		  #promotions_dates
FROM		  PG_promotions_with_doubles_update pr
INNER JOIN  PG_product_assortment pa
ON		  pa.Product_ID = pr.ProductNumber --Only detect products which are in the assortment
INNER JOIN  PG_dim_date dt
ON		  dt.date BETWEEN pr.PromotionStartDate AND pr.PromotionEndDate
	   AND pr.Branch_name_EN IN ('Deal','Sheli','Extra','Organic','Express')
	   AND pr.DiscountType IN (4,5,8,10,14,17,20,21,24)
	   AND pr.PromotionStartDate >= '2015-03-05' --No promotions before Pesach 2015

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Most prominent promotion on a product per day selected',
			SYSDATETIME()
		)

-- Selects the days on which a promotion is calculated
IF OBJECT_ID('dbo.PG_promotions_dates_update','U') IS NOT NULL
    DROP TABLE PG_promotions_dates_update
SELECT	  CAST(PromotionNumber AS BIGINT) 'PromotionNumber',
		  CAST(ProductNumber AS BIGINT) 'ProductNumber',
		  Branch_name_EN,
		  CAST(SourceInd AS INT) 'SourceInd',
		  Date,
		  CASE WHEN MIN(Ind) > 1 THEN 0 ELSE 1 END AS 'Valid_ind'
INTO		  dbo.PG_promotions_dates_update
FROM		  #promotions_dates
WHERE	  Date <= @end_date
GROUP BY	  PromotionNumber,
		  ProductNumber,
		  Branch_name_EN,
		  SourceInd,
		  Date

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Table dbo.PG_promotions_dates calculated',
			SYSDATETIME()
		)

-- Create promotions table
IF OBJECT_ID('dbo.PG_promotions_update','U') IS NOT NULL
    DROP TABLE PG_promotions_update
SELECT	  CampaignNumberPromo,
		  CampaignDesc,
		  PromotionNumber,
		  PromotionCharacteristicsType,
		  PromotionNumberUnv,
		  PromotionDesc,
		  PromotionStartDate,
		  PromotionEndDate,
		  CAST(SourceInd AS INT) 'SourceInd',
		  Branch_name_EN,
		  ProductNumber,
		  DiscountType,
		  Place_in_store,
		  Folder,
		  CAST(Multibuy_quantity AS INT) 'Multibuy_quantity',
		  Promotion_perc_running_year
INTO		  dbo.PG_promotions_update
FROM		  PG_promotions_with_doubles_update
WHERE	  Branch_name_EN IN ('Deal','Sheli','Extra','Organic','Express')
	   AND DiscountType IN (4,5,8,10,14,17,20,21,24)
	   AND PromotionStartDate >= '2015-03-05' --No promotions before Pesach 2015
GROUP BY	  CampaignNumberPromo,
		  CampaignDesc,
		  PromotionNumber,
		  PromotionCharacteristicsType,
		  PromotionNumberUnv,
		  PromotionDesc,
		  PromotionStartDate,
		  PromotionEndDate,
		  SourceInd,
		  Branch_name_EN,
		  ProductNumber,
		  DiscountType,
		  Place_in_store,
		  Folder,
		  Multibuy_quantity,
		  Promotion_perc_running_year

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Promotions table created',
			SYSDATETIME()
		)

/* Moves basic files to history */
DELETE FROM PG_promotions
WHERE	  PromotionEndDate >= DATEADD(day,-@after_days,@start_date)
INSERT INTO PG_promotions
SELECT	  *
FROM		  PG_promotions_update
SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Data of file PG_promotions_update moved to history',
			SYSDATETIME()
		)

DELETE FROM PG_promotions_dates
WHERE	  Date BETWEEN @start_date AND @end_date
INSERT INTO PG_promotions_dates
SELECT	  *
FROM		  PG_promotions_dates_update
WHERE	  Date BETWEEN @start_date AND @end_date
SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Data of file PG_promotions_stores_update moved to history',
			SYSDATETIME()
		)

DELETE FROM PG_promotions_with_doubles
WHERE	  PromotionEndDate >= DATEADD(day,-@after_days,@start_date)
INSERT INTO PG_promotions_with_doubles
SELECT	  *
FROM		  PG_promotions_with_doubles_update
SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Data of file PG_promotions_with_doubles_update moved to history',
			SYSDATETIME()
		)

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'End of [update_7a_ROI_promotions_prepare]',
			SYSDATETIME()
		)



END