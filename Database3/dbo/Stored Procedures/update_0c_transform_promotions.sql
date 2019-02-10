-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-23
-- Description:	Transforms promotions and promotions stores to input files
-- =============================================
CREATE PROCEDURE [dbo].[update_0c_transform_promotions]
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
			'Start of [update_0c_transform_promotions]',
			SYSDATETIME()
		)

/* STEP 1: Promotions */
-- Transforms promotion file
INSERT INTO Staging_promotions_update
SELECT	  CampaignNumberPromo,
		  CampaignDesc,
		  PromotionNumber,
		  PromotionNumberUnv,
		  PromotionCharacteristicsType,
		  PromotionDesc,
		  --PromotionStartDate,
		  --PromotionEndDate,
		  CONVERT(DATE,CONCAT('20',SUBSTRING(PromotionStartDate,1,2),SUBSTRING(PromotionStartDate,4,2),SUBSTRING(PromotionStartDate,7,2)),120),
		  CONVERT(DATE,CONCAT('20',SUBSTRING(PromotionEndDate,1,2),SUBSTRING(PromotionEndDate,4,2),SUBSTRING(PromotionEndDate,7,2)),120),
		  NULL,
		  ProductNumber,
		  NULL,
		  DiscountType,
		  Multibuy,
		  DisplayType,
		  Folder
FROM		  Staging_promotions_import
TRUNCATE TABLE Staging_promotions_import

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'Promotions file transformed',
			SYSDATETIME()
		)

-- Deletes promotions longer than 90 days
DELETE FROM Staging_promotions_update
WHERE	  DATEDIFF(day,PromotionStartDate,PromotionEndDate) >= 90

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'Promotions longer than 90 days deleted from Staging_promotions_update',
			SYSDATETIME()
		)

-- Merges two promotion files
IF OBJECT_ID('tempdb.dbo.#promotions','U') IS NOT NULL
    DROP TABLE #promotions
SELECT	  *
INTO		  #promotions
FROM		  Staging_promotions_update
EXCEPT
SELECT	  *
FROM		  Staging_promotions

INSERT INTO Staging_promotions
SELECT	  *
FROM		  #promotions

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'New promotion data inserted into dbo.Staging_promotions',
			SYSDATETIME()
		)

-- Transform promotion display table to right data types
INSERT INTO Staging_promotions_display_update
SELECT	  [Promotion_ID]
	 ,[Date_from]
      ,[Date_to]
      ,[Display_ID]
      ,[Display_name_HE]
      ,[Display_name_EN]
      ,[Display_number]
      ,[Media_ID]
      ,CAST([Newspaper_chapter] AS INT)
      ,[Newspaper_page]
      ,[Newspaper_unit]
      ,CAST([Newspaper_location] AS INT)
      ,[Newspaper_nr_cubes]
FROM		  Staging_promotions_display_import
TRUNCATE TABLE Staging_promotions_display_import

/* STEP 2: Stores */
-- Only execute when there is an update 
IF (SELECT MAX(#LocationID) FROM Staging_stores_update) IS NOT NULL
BEGIN
    -- Selects stores with their store format
    IF OBJECT_ID('dbo.PG_stores','U') IS NOT NULL
	   DROP TABLE dbo.PG_stores    
    SELECT	 #LocationID,
			 StoreFormatCode
    INTO		 dbo.PG_stores
    FROM		 Staging_stores_update

    -- Move data to history
    INSERT INTO Staging_stores
    SELECT	 *,
			 @run_date
    FROM		 Staging_stores_update
    TRUNCATE TABLE Staging_stores_update
END

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'New file with stores processed',
			SYSDATETIME()
		)

/* STEP 3: Promotions display */
-- Merges two promotion display files
INSERT INTO Staging_promotions_display
SELECT	  *
FROM		  Staging_promotions_display_update
EXCEPT 
SELECT	  *
FROM		  Staging_promotions_display
TRUNCATE TABLE Staging_promotions_display_update

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'New file with promotion displays processed',
			SYSDATETIME()
		)

/* STEP 4: Promotions stores */
-- Creates table with promotions on store and branch level
IF OBJECT_ID('tempdb.dbo.#promotions_stores_branches','U') IS NOT NULL
    DROP TABLE #promotions_stores_branches
SELECT	  ps.#PromotionNumber,
		  ps.PromotionCharacteristicsType,
		  ps.LocationID,
		  br.Branch_name_EN
INTO		  #promotions_stores_branches
FROM		  Staging_promotions_stores_update ps
INNER JOIN  PG_stores st
ON		  ps.LocationID = st.#LocationID
INNER JOIN  Staging_branches br
ON		  br.Branch_ID = st.StoreFormatCode

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'Table created with promotions on store and branch level',
			SYSDATETIME()
		)

-- Counts number of locations for a promotion within a branch
IF OBJECT_ID('tempdb.dbo.#nr_locations_per_promotion','U') IS NOT NULL
    DROP TABLE #nr_locations_per_promotion
SELECT	  #PromotionNumber,
		  PromotionCharacteristicsType,
		  Branch_name_EN,
		  COUNT(DISTINCT LocationID) AS 'nr_locations'
INTO		  #nr_locations_per_promotion
FROM		  #promotions_stores_branches
GROUP BY	  #PromotionNumber,
		  PromotionCharacteristicsType,
		  Branch_name_EN

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'Number of locations for a promotion within a branch counted',
			SYSDATETIME()
		)

-- Calculates total amount of locations per branch
IF OBJECT_ID('tempdb.dbo.#total_locations','U') IS NOT NULL
    DROP TABLE #total_locations
SELECT	  br.Branch_name_EN,
		  COUNT(st.#LocationID) AS 'nr_locations'
INTO		  #total_locations
FROM		  PG_stores st
INNER JOIN  Staging_branches br
ON		  br.Branch_ID = st.StoreFormatCode
GROUP BY	  br.Branch_name_EN

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'Total amount of locations per branch calculated',
			SYSDATETIME()
		)

-- Calculates percentage of locations for a promotion within a branch
IF OBJECT_ID('tempdb.dbo.#perc_locations_per_promotion','U') IS NOT NULL
    DROP TABLE #perc_locations_per_promotion
SELECT	  t2.#PromotionNumber,
		  t2.PromotionCharacteristicsType,
		  t2.Branch_name_EN,
		  t2.nr_locations,
		  t2.nr_locations / (1.0*t1.nr_locations) AS 'perc_locations'
INTO		  #perc_locations_per_promotion
FROM		  #nr_locations_per_promotion t2
INNER JOIN  #total_locations t1
ON		  t2.Branch_name_EN = t1.Branch_name_EN

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'Percentage of locations for a promotion within a branch calculated',
			SYSDATETIME()
		)

-- Selects branches in which a promotion is valid
IF OBJECT_ID('tempdb.dbo.#promotion_store_ind','U') IS NOT NULL
    DROP TABLE #promotion_store_ind
SELECT	  #PromotionNumber,
		  PromotionCharacteristicsType,
		  Branch_name_EN,
		  CASE WHEN perc_locations > 0.25 THEN 1 ELSE 0 END AS 'store_ind'
INTO		  #promotion_store_ind
FROM		  #perc_locations_per_promotion

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'Branches selected in which a promotion is valid',
			SYSDATETIME()
		)

-- Selects promotions with their branches
IF OBJECT_ID('tempdb.dbo.#promotions_stores','U') IS NOT NULL
    DROP TABLE #promotions_stores
SELECT	  pr.CampaignNumberPromo,
		  pr.PromotionNumber,
		  pr.PromotionNumberUnv,
		  ps.PromotionCharacteristicsType,
		  pr.PromotionStartDate,
		  pr.PromotionEndDate,
		  CASE WHEN pr.SourceInd IS NOT NULL
				THEN pr.SourceInd
			  WHEN ps.Branch_name_EN NOT IN ('Deal','Extra','Sheli') AND pr.SourceInd IS NULL
				THEN 1
			  ELSE bs.SourceInd END AS 'SourceInd',
		  pr.ProductNumber,
		  ps.Branch_name_EN
INTO		  #promotions_stores
FROM		  Staging_promotions_update pr
INNER JOIN  #promotion_store_ind ps
ON		  pr.PromotionNumber = ps.#PromotionNumber
	   AND CASE WHEN pr.PromotionCharacteristicsType IS NULL
				THEN ps.PromotionCharacteristicsType
			  ELSE pr.PromotionCharacteristicsType END = ps.PromotionCharacteristicsType
	   AND ps.store_ind = 1
LEFT JOIN   PG_branches_sources bs
ON		  bs.Branch_name_EN = ps.Branch_name_EN
	   AND ps.Branch_name_EN IN ('Deal','Extra','Sheli')
	   AND pr.SourceInd IS NULL

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'Promotions with their branches selected',
			SYSDATETIME()
		)

-- Selects promotion numbers with their branches into general promotions stores file
;WITH CTE AS
(SELECT	  PromotionNumber,
		  PromotionCharacteristicsType
 FROM	  #promotions_stores
 GROUP BY PromotionNumber,
		  PromotionCharacteristicsType
 EXCEPT	  
 SELECT	  PromotionNumber,
		  PromotionCharacteristicsType
 FROM	  PG_promotions_stores
 GROUP BY PromotionNumber,
		  PromotionCharacteristicsType
)
INSERT INTO PG_promotions_stores
SELECT	  ps.*
FROM		  #promotions_stores ps
INNER JOIN  CTE cte
ON		  ps.PromotionNumber = cte.PromotionNumber
		AND ps.PromotionCharacteristicsType = cte.PromotionCharacteristicsType

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'Promotion numbers with their branches into general promotions stores file selected',
			SYSDATETIME()
		)

-- Insert data from promotions stores to history
INSERT INTO Staging_promotions_stores
SELECT	  *
FROM		  Staging_promotions_stores_update
EXCEPT
SELECT	  *
FROm		  Staging_promotions_stores
TRUNCATE TABLE Staging_promotions_stores_update

TRUNCATE TABLE Staging_promotions_update

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'End of [update_0c_transform_promotions]',
			SYSDATETIME()
		)

END
