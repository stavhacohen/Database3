-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-18
-- Description:	Script for component 3 of ROI for weekly and monthly promotions
-- =============================================
CREATE PROCEDURE [dbo].[update_7d_ROI_promotions_component_3]
	@run_nr INT = 13,
	@run_date DATE = '2017-11-05',
	@step INT = 101,
	@start_date DATE = '2017-10-01',
	@end_date DATE = '2017-10-14',
	@level_batch INT = 10000,
	@day_batch INT = 30,
	@baseline_days INT = 28
AS
BEGIN

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Start of [update_7d_ROI_promotions_component_3]',
			SYSDATETIME()
		)


-- Selects substitution clusters of promotion products
IF OBJECT_ID('tempdb.dbo.#product_substitute_levels','U') IS NOT NULL
    DROP TABLE #product_substitute_levels;
SELECT	  psl.Level,
		  psl.Level_ID,
		  cp.PromotionNumber,
		  cp.PromotionStartDate,
		  cp.PromotionEndDate,
		  cp.Branch_name_EN,
		  cp.SourceInd,
		  pd.Date AS 'TransactionDate'
INTO		  #product_substitute_levels
FROM		  dbo.PG_product_substitute_levels psl
INNER JOIN  PG_promotions_update cp
ON		  psl.Product_ID = cp.ProductNumber
LEFT JOIN	  PG_ROI_component_2c_continuous_promotions_update co
ON		  co.PromotionNumber = cp.PromotionNumber
	   AND co.PromotionStartDate = cp.PromotionStartDate
	   AND co.PromotionEndDate = cp.PromotionEndDate
	   AND co.ProductNumber = cp.ProductNumber
	   AND co.Branch_name_EN = cp.Branch_name_EN
	   AND co.SourceInd = cp.SourceInd
INNER JOIN  PG_promotions_dates_update pd
ON		  pd.PromotionNumber = cp.PromotionNumber
	   AND pd.ProductNumber = cp.ProductNumber
	   AND pd.Branch_name_EN = cp.Branch_name_EN
	   AND pd.SourceInd = cp.SourceInd
	   AND pd.Valid_ind = 1
WHERE	  psl.Level_ID IS NOT NULL
	   AND (co.Ind_sufficient_discount IS NULL OR co.Ind_sufficient_discount = 1)
GROUP BY	  psl.Level,
		  psl.Level_ID,
		  cp.PromotionNumber,
		  cp.PromotionStartDate,
		  cp.PromotionEndDate,
		  cp.Branch_name_EN,
		  cp.SourceInd,
		  pd.Date

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Substitution clusters of promotion products selected',
			SYSDATETIME()
		)

CREATE CLUSTERED INDEX cl_index_date ON #product_substitute_levels(TransactionDate);

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Clustered index on TransactionDate created for #product_substitute_levels',
			SYSDATETIME()
		)

-- Creates tables for substitute products
IF OBJECT_ID('dbo.PG_ROI_component_3a_substitute_products_daily_update','U') IS NOT NULL
    DROP TABLE dbo.PG_ROI_component_3a_substitute_products_daily_update;
CREATE TABLE dbo.PG_ROI_component_3a_substitute_products_daily_update
(PromotionNumber	    BIGINT,
 PromotionStartDate	    DATE,
 PromotionEndDate	    DATE,
 Branch_name_EN	    VARCHAR(7),
 SourceInd		    TINYINT,
 Level			    VARCHAR(17),
 Level_ID			    INT,
 TransactionDate	    DATE,
 ProductNumber		    BIGINT
)
IF OBJECT_ID('dbo.PG_ROI_component_3b_realization_subs_update','U') IS NOT NULL
    DROP TABLE dbo.PG_ROI_component_3b_realization_subs_update;
CREATE TABLE dbo.PG_ROI_component_3b_realization_subs_update
(ProductNumber		    BIGINT,
 Branch_name_EN	    VARCHAR(7),
 SourceInd		    TINYINT,
 TransactionDate	    DATE,
 Quantity			    DECIMAL(15,2),
 Revenue			    DECIMAL(15,2),
 Margin			    DECIMAL(15,2)
)
IF OBJECT_ID('dbo.PG_ROI_component_3c_substitute_products_update','U') IS NOT NULL
    DROP TABLE dbo.PG_ROI_component_3c_substitute_products_update;
CREATE TABLE dbo.PG_ROI_component_3c_substitute_products_update
(PromotionNumber	    BIGINT,
 PromotionStartDate	    DATE,
 PromotionEndDate	    DATE,
 Branch_name_EN	    VARCHAR(7),
 SourceInd		    TINYINT,
 Level			    VARCHAR(17),
 Level_ID			    INT,
 ProductNumber		    BIGINT
)

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Tables for substitute products created',
			SYSDATETIME()
		)

DECLARE @dateX DATE = @start_date;
DECLARE @dateY DATE = DATEADD(day,@day_batch-1,@start_date);
WHILE @dateX <= @end_date
BEGIN
    -- Selects substitute products per day
    IF OBJECT_ID('tempdb.dbo.#ROI_component_3a_substitute_products_daily','U') IS NOT NULL
	   DROP TABLE #ROI_component_3a_substitute_products_daily;
    SELECT	 psl.PromotionNumber,
			 psl.PromotionStartDate,
			 psl.PromotionEndDate,
			 psl.Branch_name_EN,
			 psl.SourceInd,
			 psl.Level,
			 psl.Level_ID,
			 psl.TransactionDate,
			 pa.Product_ID AS 'ProductNumber'
    INTO		 #ROI_component_3a_substitute_products_daily
    FROM		 #product_substitute_levels psl
    INNER JOIN	 PG_product_assortment_leveled pa
    ON		 psl.Level = pa.Level
		  AND psl.Level_ID = pa.Level_ID
    INNER JOIN  (SELECT ProductNumber, Branch_name_EN, SourceInd FROM PG_sales_per_product_per_day_wo_returns GROUP BY ProductNumber, Branch_name_EN, SourceInd) pss
    ON		 pss.ProductNumber = pa.Product_ID
		  AND pss.Branch_name_EN = psl.Branch_name_EN
		  AND pss.SourceInd = psl.SourceInd
    INNER JOIN	 PG_promo_product_ind ppi
    ON		 ppi.ProductNumber = pa.Product_ID
		  AND ppi.TransactionDate = psl.TransactionDate
		  AND ppi.Branch_name_EN = psl.Branch_name_EN
		  AND ppi.SourceInd = psl.SourceInd
		  AND ppi.Promo_ind = 0
    WHERE		 psl.TransactionDate BETWEEN @dateX AND @dateY

    -- Moves data to definitive file
    INSERT INTO PG_ROI_component_3a_substitute_products_daily_update
    SELECT	 *
    FROM		 #ROI_component_3a_substitute_products_daily

    SET @step = @step + 1;
    INSERT INTO PG_update_log
	   VALUES(	@run_nr,
				@run_date,
				7,
				@step,
				CONCAT('Substitution products of promotion selected between ',@dateX,' and ',@dateY),
				SYSDATETIME()
			 )

    -- Calculates daily sales per substitute product
    INSERT INTO PG_ROI_component_3b_realization_subs_update
    SELECT	 sp.ProductNumber,
			 sp.Branch_name_EN,
			 sp.SourceInd,
			 sp.TransactionDate,
			 at.Quantity AS 'Real_quantity',
			 at.Revenue AS 'Real_revenue',
			 at.Margin AS 'Real_margin'
    FROM		 #ROI_component_3a_substitute_products_daily sp
    INNER JOIN	 PG_sales_per_product_per_day_wo_returns at
    ON		 sp.ProductNumber = at.ProductNumber
		  AND sp.Branch_name_EN = at.Branch_name_EN
		  AND sp.SourceInd = at.SourceInd
		  AND sp.TransactionDate = at.TransactionDate

    SET @step = @step + 1;
    INSERT INTO PG_update_log
	   VALUES(	@run_nr,
				@run_date,
				7,
				@step,
				CONCAT('Realization of substitute products calculated between ',@dateX,' and ',@dateY),
				SYSDATETIME()
			 )
    
    -- Distinct substitute products selected
    IF OBJECT_ID('tempdb.dbo.#ROI_component_3c_substitute_products','U') IS NOT NULL
	   DROP TABLE #ROI_component_3c_substitute_products;
    ;WITH CTE AS
    (SELECT	 PromotionNumber,
			 PromotionStartDate,
			 PromotionEndDate,
			 Branch_name_EN,
			 SourceInd,
			 Level,
			 Level_ID,
			 ProductNumber
    FROM		 #ROI_component_3a_substitute_products_daily
    GROUP BY	 PromotionNumber,
			 PromotionStartDate,
			 PromotionEndDate,
			 Branch_name_EN,
			 SourceInd,
			 Level,
			 Level_ID,
			 ProductNumber
    )
    SELECT	 cte.*
    INTO		 #ROI_component_3c_substitute_products
    FROM		 CTE cte
    EXCEPT
    SELECT	 *
    FROM		 PG_ROI_component_3c_substitute_products_update

    -- Moves data to update
    INSERT INTO PG_ROI_component_3c_substitute_products_update
    SELECT	 *
    FROM		 #ROI_component_3c_substitute_products

    SET @step = @step + 1;
    INSERT INTO PG_update_log
	   VALUES(	@run_nr,
				@run_date,
				7,
				@step,
				CONCAT('Distinct substitute products selected between ',@dateX,' and ',@dateY),
				SYSDATETIME()
			 )

    SET @dateX = DATEADD(day,@day_batch,@dateX);
    SET @dateY = DATEADD(day,@day_batch,@dateY);
END

-- Selects substitute products and index them
IF OBJECT_ID('tempdb.dbo.#products_indexed', 'U') IS NOT NULL
    DROP TABLE #products_indexed;
SELECT	  ProductNumber,
		  ROW_NUMBER() OVER(ORDER BY ProductNumber) AS 'Ind'
INTO		  #products_indexed
FROM		  PG_ROI_component_3c_substitute_products_update
GROUP BY	  ProductNumber

CREATE CLUSTERED INDEX cl_index_product ON #products_indexed(ProductNumber)
CREATE CLUSTERED INDEX cl_index_product ON PG_ROI_component_3c_substitute_products_update(ProductNumber)

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Substitute products selected and indexed',
			SYSDATETIME()
		)

-- Creates tables for baseline days and standard day of substitute products
IF OBJECT_ID('dbo.PG_ROI_component_3d_baseline_days_subs_update', 'U') IS NOT NULL
    DROP TABLE dbo.PG_ROI_component_3d_baseline_days_subs_update;
CREATE TABLE dbo.PG_ROI_component_3d_baseline_days_subs_update
(PromotionNumber	    BIGINT,
 PromotionStartDate	    DATE,
 PromotionEndDate	    DATE,
 ProductNumber		    BIGINT,
 Branch_name_EN	    VARCHAR(7),
 SourceInd		    SMALLINT,
 TransactionDate	    DATE,
 Level			    VARCHAR(10),
 Level_ID			    INT,
 Quantity			    DECIMAL(15,2),
 Revenue			    DECIMAL(15,2),
 Margin			    DECIMAL(15,2),
 correction_factor	    DECIMAL(15,2),
 Day_index		    SMALLINT,
 avg_quantity		    DECIMAL(15,2),
 avg_revenue		    DECIMAL(15,2),
 avg_margin		    DECIMAL(15,2),
 stdevp_quantity	    DECIMAL(15,2),
 valid_ind		    SMALLINT
)
IF OBJECT_ID('dbo.PG_ROI_component_3e_standard_day_subs_update', 'U') IS NOT NULL
    DROP TABLE dbo.PG_ROI_component_3e_standard_day_subs_update;
CREATE TABLE dbo.PG_ROI_component_3e_standard_day_subs_update
(PromotionNumber	    BIGINT,
 PromotionStartDate	    DATE,
 PromotionEndDate	    DATE,
 ProductNumber		    BIGINT,
 Branch_name_EN	    VARCHAR(7),
 SourceInd		    TINYINT,
 Level			    VARCHAR(17),
 Level_ID			    INT,
 Baseline_days		    INT,
 Valid_baseline_days    INT,
 Baseline_quantity	    DECIMAL(15,2),
 Baseline_revenue	    DECIMAL(15,2),
 Baseline_margin	    DECIMAL(15,2)
)

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Tables created for baseline days and standard day of substitute products',
			SYSDATETIME()
		)

DECLARE @CountX INT = 1;
DECLARE @CountY INT = @level_batch;
WHILE @CountX <= (SELECT MAX(Ind) FROM #products_indexed)
BEGIN

-- Select substitute products
IF OBJECT_ID('tempdb.dbo.#component_3c_substitute_products', 'U') IS NOT NULL
    DROP TABLE #component_3c_substitute_products;
SELECT	  *
INTO		  #component_3c_substitute_products
FROM		  PG_ROI_component_3c_substitute_products_update
WHERE	  ProductNumber IN (SELECT ProductNumber FROM #products_indexed WHERE Ind BETWEEN @CountX AND @CountY)

-- Calculates baseline days for substitute products of promotions
IF OBJECT_ID('tempdb.dbo.#ROI_component_3d_baseline_days_subs', 'U') IS NOT NULL
    DROP TABLE #ROI_component_3d_baseline_days_subs
;WITH CTE AS
(SELECT	  cp.PromotionNumber,
		  cp.PromotionStartDate,
		  cp.PromotionEndDate,
		  cp.ProductNumber,
		  cp.Branch_name_EN,
		  cp.SourceInd,
		  cp.Level,
		  cp.Level_ID,
		  ppi.TransactionDate,
		  ISNULL(at.Quantity,0) AS Quantity,
		  ISNULL(at.Revenue,0) AS Revenue,
		  ISNULL(at.Margin,0) AS Margin,
		  wd.correction_weekday*cf.correction_holiday*cf.correction_season AS 'correction_factor',
		  ROW_NUMBER()
			 OVER(PARTITION BY	 cp.PromotionNumber,
							 cp.PromotionStartDate,
							 cp.PromotionEndDate,
							 cp.ProductNumber,
							 cp.Branch_name_EN,
							 cp.SourceInd
			      ORDER BY		 ppi.TransactionDate DESC)
		  AS 'Day_index'
 FROM	  #component_3c_substitute_products cp
 INNER JOIN PG_promo_product_ind ppi
 ON		  ppi.TransactionDate BETWEEN DATEADD(day,-180,cp.PromotionStartDate) AND DATEADD(day,-1,cp.PromotionStartDate)
        AND ppi.ProductNumber = cp.ProductNumber
	   AND ppi.SourceInd = cp.SourceInd
	   AND ppi.Branch_name_EN = cp.Branch_name_EN
	   AND ppi.Promo_ind = 0
 LEFT JOIN  PG_sales_per_product_per_day_wo_returns at
 ON		  at.TransactionDate = ppi.TransactionDate
        AND at.ProductNumber = cp.ProductNumber
	   AND at.SourceInd = cp.SourceInd
	   AND at.Branch_name_EN = cp.Branch_name_EN
 INNER JOIN PG_correction_factors cf
 ON		  cf.ProductNumber = cp.ProductNumber
	   AND cf.TransactionDate = ppi.TransactionDate
 INNER JOIN PG_correction_weekday wd
 ON		wd.date = ppi.TransactionDate
	 AND wd.Branch_name_EN = ppi.Branch_name_EN
	 AND wd.correction_weekday <> 0
)
SELECT	  cte.PromotionNumber,
		  cte.PromotionStartDate,
		  cte.PromotionEndDate,
		  cte.ProductNumber,
		  cte.Branch_name_EN,
		  cte.SourceInd,
		  cte.TransactionDate,
		  cte.Level,
		  cte.Level_ID,
		  cte.Quantity,
		  cte.Revenue,
		  cte.Margin,
		  cte.correction_factor,
		  cte.Day_index,
		  AVG(cte.Quantity*cte.correction_factor) OVER (PARTITION BY cte.PromotionNumber,
																	  cte.PromotionStartDate,
																	  cte.PromotionEndDate,
																	  cte.ProductNumber,
																	  cte.Branch_name_EN,
																	  cte.SourceInd) AS 'avg_quantity',
		  AVG(cte.Revenue*cte.correction_factor) OVER (PARTITION BY cte.PromotionNumber,
																	  cte.PromotionStartDate,
																	  cte.PromotionEndDate,
																	  cte.ProductNumber,
																	  cte.Branch_name_EN,
																	  cte.SourceInd) AS 'avg_revenue',
		  AVG(cte.Margin*cte.correction_factor) OVER (PARTITION BY cte.PromotionNumber,
																	  cte.PromotionStartDate,
																	  cte.PromotionEndDate,
																	  cte.ProductNumber,
																	  cte.Branch_name_EN,
																	  cte.SourceInd) AS 'avg_margin',
		  STDEVP(cte.Quantity*cte.correction_factor) OVER (PARTITION BY cte.PromotionNumber,
																	  cte.PromotionStartDate,
																	  cte.PromotionEndDate,
																	  cte.ProductNumber,
																	  cte.Branch_name_EN,
																	  cte.SourceInd) AS 'stdevp_quantity',
		  CASE WHEN (cte.Quantity*cte.correction_factor - AVG(cte.Quantity*cte.correction_factor) OVER (PARTITION BY cte.PromotionNumber, cte.PromotionStartDate, cte.PromotionEndDate, cte.ProductNumber, cte.Branch_name_EN, cte.SourceInd))
					> 2*STDEVP(cte.Quantity*cte.correction_factor) OVER (PARTITION BY cte.PromotionNumber, cte.PromotionStartDate, cte.PromotionEndDate, cte.ProductNumber, cte.Branch_name_EN, cte.SourceInd)
			   THEN 0 ELSE 1 END AS 'valid_ind'
INTO	   #ROI_component_3d_baseline_days_subs
FROM	   CTE cte
WHERE   cte.Day_index <= @baseline_days

-- Move data to update
INSERT INTO PG_ROI_component_3d_baseline_days_subs_update
SELECT	  *
FROM		  #ROI_component_3d_baseline_days_subs

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			CONCAT('Baseline days per substitute product of promotion calculated for products ',@CountX,' until ',@CountY),
			SYSDATETIME()
		)

-- Calculates standard day per substitute product
IF OBJECT_ID('tempdb.dbo.#ROI_component_3e_standard_day_subs', 'U') IS NOT NULL
    DROP TABLE #ROI_component_3e_standard_day_subs;
SELECT	  cte.PromotionNumber,
		  cte.PromotionStartDate,
		  cte.PromotionEndDate,
		  cte.ProductNumber,
		  cte.Branch_name_EN,
		  cte.SourceInd,
		  cte.Level,
		  cte.Level_ID,
		  COUNT(valid_ind) AS 'Baseline_days',
		  SUM(valid_ind) AS 'Valid_baseline_days',
		  CASE WHEN SUM(valid_ind) = 0 THEN avg_quantity*COUNT(cte.TransactionDate)
			  ELSE SUM(cte.Quantity * cte.correction_factor * cte.valid_ind)/SUM(valid_ind) END AS 'Baseline_quantity',
		  CASE WHEN SUM(valid_ind) = 0 THEN avg_revenue*COUNT(cte.TransactionDate)
			  ELSE SUM(cte.Revenue * cte.correction_factor * cte.valid_ind)/SUM(valid_ind) END AS 'Baseline_revenue',
		  CASE WHEN SUM(valid_ind) = 0 THEN avg_margin*COUNT(cte.TransactionDate)
			  ELSE SUM(cte.Margin * cte.correction_factor * cte.valid_ind)/SUM(valid_ind) END AS 'Baseline_margin'
INTO		  #ROI_component_3e_standard_day_subs
FROM		  #ROI_component_3d_baseline_days_subs CTE
GROUP BY	  cte.PromotionNumber,
		  cte.PromotionStartDate,
		  cte.PromotionEndDate,
		  cte.ProductNumber,
		  cte.Branch_name_EN,
		  cte.SourceInd,
		  cte.avg_margin,
		  cte.avg_quantity,
		  cte.avg_revenue,
		  cte.Level,
		  cte.Level_ID
HAVING	  COUNT(valid_ind) = 28;

-- Move data to update
INSERT INTO PG_ROI_component_3e_standard_day_subs_update
SELECT	  *
FROM		  #ROI_component_3e_standard_day_subs

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			CONCAT('Standard day per substitute product calculated for products ',@CountX,' until ',@CountY),
			SYSDATETIME()
		)

SET	   @CountX = @CountX + @level_batch;
SET	   @CountY = @CountY + @level_batch;

END

-- Creates index on PG_ROI_component_3a_substitute_products_daily
CREATE CLUSTERED INDEX cl_index_date ON PG_ROI_component_3a_substitute_products_daily_update(TransactionDate)

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Clustered index on TransactionDate for PG_ROI_component_3a_substitute_products_daily created',
			SYSDATETIME()
		)

-- Creates tables for substitution results
IF OBJECT_ID('dbo.PG_ROI_component_3f_baseline_subs_daily_update','U') IS NOT NULL
    DROP TABLE dbo.PG_ROI_component_3f_baseline_subs_daily_update;
CREATE TABLE dbo.PG_ROI_component_3f_baseline_subs_daily_update
(ProductNumber		BIGINT,
 Branch_name_EN	VARCHAR(7),
 SourceInd		SMALLINT,
 TransactionDate	DATE,
 Level			VARCHAR(17),
 Level_ID			INT,
 Avg_baseline_days	    DECIMAL(15,2),
 Avg_valid_baseline_days DECIMAL(15,2),
 Baseline_quantity DECIMAL(15,2),
 Baseline_revenue	DECIMAL(15,2),
 Baseline_margin	DECIMAL(15,2),
 Delta_quantity	DECIMAL(15,2),
 Delta_revenue		DECIMAL(15,2),
 Delta_margin		DECIMAL(15,2)
)
IF OBJECT_ID('dbo.PG_ROI_component_3_update','U') IS NOT NULL
    DROP TABLE dbo.PG_ROI_component_3_update;
CREATE TABLE dbo.PG_ROI_component_3_update
(PromotionNumber	    BIGINT,
 PromotionStartDate	    DATE,
 PromotionEndDate	    DATE,
 ProductNumber		    BIGINT,
 Branch_name_EN	    VARCHAR(7),
 SourceInd		    SMALLINT,
 TransactionDate	    DATE,
 Quantity_3_subs_group  DECIMAL(15,2),
 Revenue_3_subs_group   DECIMAL(15,2),
 Margin_3_subs_group    DECIMAL(15,2),
 Ind_positive_subs	    TINYINT,
 Ind_high_subs		    TINYINT
)
IF OBJECT_ID('dbo.PG_ROI_component_3g_substitution_suppliers_update','U') IS NOT NULL
    DROP TABLE PG_ROI_component_3g_substitution_suppliers_update;
CREATE TABLE dbo.PG_ROI_component_3g_substitution_suppliers_update
(PromotionNumber	    BIGINT,
 PromotionStartDate	    DATE,
 PromotionEndDate	    DATE,
 ProductNumber		    BIGINT,
 Supplier_ID		    INT,
 Branch_name_EN	    VARCHAR(7),
 SourceInd		    SMALLINT,
 TransactionDate	    DATE,
 Quantity_3_subs_group  DECIMAL(15,2),
 Revenue_3_subs_group   DECIMAL(15,2),
 Margin_3_subs_group    DECIMAL(15,2),
 Ind_positive_subs	    TINYINT,
 Ind_high_subs		    TINYINT
)

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Tables created for substitution results',
			SYSDATETIME()
		)

SET @dateX = @start_date;
SET @dateY = DATEADD(day,@day_batch-1,@start_date);
WHILE @dateX <= @end_date
BEGIN

-- Selects substitute products per day
IF OBJECT_ID('tempdb.dbo.#component_3a_substitute_products_daily','U') IS NOT NULL
    DROP TABLE #component_3a_substitute_products_daily
SELECT	  *
INTO		  #component_3a_substitute_products_daily
FROM		  PG_ROI_component_3a_substitute_products_daily_update
WHERE	  TransactionDate BETWEEN @dateX AND @dateY

-- Selects correction factors per day
IF OBJECT_ID('tempdb.dbo.#correction_factors','U') IS NOT NULL
    DROP TABLE #correction_factors
SELECT	  *
INTO		  #correction_factors
FROM		  PG_correction_factors
WHERE	  TransactionDate BETWEEN @dateX AND @dateY

IF OBJECT_ID('tempdb.dbo.#promotion_days','U') IS NOT NULL
    DROP TABLE #promotion_days
SELECT	  cp.PromotionNumber,
		  cp.PromotionStartDate,
		  cp.PromotionEndDate,
		  cp.ProductNumber,
		  cp.Branch_name_EN,
		  cp.SourceInd,
		  cp.TransactionDate,
		  wd.correction_weekday*cf.correction_holiday*cf.correction_season AS 'correction_factor'
 INTO	  #promotion_days
 FROM	  #component_3a_substitute_products_daily cp
 INNER JOIN #correction_factors cf
 ON		  cf.ProductNumber = cp.ProductNumber
	   AND cf.TransactionDate = cp.TransactionDate
 INNER JOIN dbo.PG_correction_weekday wd
 ON		  wd.date = cf.TransactionDate
	   AND wd.Branch_name_EN = cp.Branch_name_EN

-- Calculates baseline per day for substitute products and compares it with the realization
IF OBJECT_ID('tempdb.dbo.#ROI_component_3f_baseline_subs_daily','U') IS NOT NULL
    DROP TABLE #ROI_component_3f_baseline_subs_daily
SELECT	  cte.ProductNumber,
		  cte.Branch_name_EN,
		  cte.SourceInd,
		  cte.TransactionDate,
		  sd.Level,
		  sd.Level_ID,
		  AVG(sd.Baseline_days) AS 'Avg_baseline_days',
		  AVG(sd.Valid_baseline_days) AS 'Avg_valid_baseline_days',
-- As more promotions (with different start dates) can have the same substitutes we take the average baseline over these promotions
		  CASE WHEN cte.correction_factor = 0 THEN 0 ELSE AVG(sd.Baseline_quantity) / cte.correction_factor END AS 'Baseline_quantity',
		  CASE WHEN cte.correction_factor = 0 THEN 0 ELSE AVG(sd.Baseline_revenue) / cte.correction_factor END AS 'Baseline_revenue',
		  CASE WHEN cte.correction_factor = 0 THEN 0 ELSE AVG(sd.Baseline_margin) / cte.correction_factor END AS 'Baseline_margin',
		  CASE WHEN cte.correction_factor = 0 THEN 0 ELSE ISNULL(re.Quantity,0) - AVG(sd.Baseline_quantity) / cte.correction_factor END AS 'Delta_quantity',
		  CASE WHEN cte.correction_factor = 0 THEN 0 ELSE ISNULL(re.Revenue,0) - AVG(sd.Baseline_revenue) / cte.correction_factor END AS 'Delta_revenue',
		  CASE WHEN cte.correction_factor = 0 THEN 0 ELSE ISNULL(re.Margin,0) - AVG(sd.Baseline_margin) / cte.correction_factor END AS 'Delta_margin'
INTO		  #ROI_component_3f_baseline_subs_daily
FROM		  #promotion_days cte
INNER JOIN  PG_ROI_component_3e_standard_day_subs_update sd
ON		  sd.PromotionNumber = cte.PromotionNumber
	   AND sd.ProductNumber = cte.ProductNumber
	   AND sd.PromotionStartDate = cte.PromotionStartDate
	   AND sd.PromotionEndDate = cte.PromotionEndDate
	   AND sd.SourceInd = cte.SourceInd
	   AND sd.Branch_name_EN = cte.Branch_name_EN
LEFT JOIN   PG_ROI_component_3b_realization_subs_update re
ON		  re.ProductNumber = cte.ProductNumber
	   AND re.SourceInd = cte.SourceInd
	   AND re.TransactionDate = cte.TransactionDate
	   AND re.Branch_name_EN = cte.Branch_name_EN
GROUP BY	  cte.ProductNumber,
		  cte.Branch_name_EN,
		  cte.SourceInd,
		  cte.TransactionDate,
		  cte.correction_factor,
		  sd.Level,
		  sd.Level_ID,
		  re.Quantity,
		  re.Revenue,
		  re.Margin

-- Move data to update
INSERT INTO PG_ROI_component_3f_baseline_subs_daily_update
SELECT	  *
FROM		  #ROI_component_3f_baseline_subs_daily

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			CONCAT('Daily baseline for substitute products calculated between ',@dateX,' and ',@dateY),
			SYSDATETIME()
		)

-- Selects promotions and their revenue per product substitute level
IF OBJECT_ID('tempdb.dbo.#product_substitute_levels_revenue','U') IS NOT NULL
    DROP TABLE #product_substitute_levels_revenue
SELECT	  psl.PromotionNumber,
		  psl.PromotionStartDate,
		  psl.PromotionEndDate,
		  psl.Branch_name_EN,
		  co.ProductNumber,
		  psl.SourceInd,
		  psl.TransactionDate,
		  psl.Level,
		  psl.Level_ID,
		  co.Revenue_1_promotion AS 'Total_revenue',
		  CASE WHEN SUM(co.Revenue_1_promotion) OVER (PARTITION BY psl.TransactionDate, psl.Branch_name_EN, psl.SourceInd, Level, Level_ID) = 0 THEN 0
			   ELSE co.Revenue_1_promotion / (SUM(co.Revenue_1_promotion) OVER (PARTITION BY psl.TransactionDate, psl.Branch_name_EN, psl.SourceInd, Level, Level_ID)) END AS 'Perc_revenue'
 INTO	  #product_substitute_levels_revenue
 FROM	  #product_substitute_levels psl
 INNER JOIN dbo.PG_ROI_component_1_update co
 ON		  co.PromotionNumber = psl.PromotionNumber
	   AND co.Branch_name_EN = psl.Branch_name_EN
	   AND co.PromotionEndDate = psl.PromotionEndDate
	   AND co.PromotionStartDate = psl.PromotionStartDate
	   AND co.SourceInd = psl.SourceInd
	   AND co.TransactionDate = psl.TransactionDate
 WHERE	  co.TransactionDate BETWEEN @dateX AND @dateY

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			CONCAT('Revenue per product substitute level calculated between ',@dateX,' and ',@dateY),
			SYSDATETIME()
		)

-- Calculates group substitution on daily basis based on percentage sales of promotion product in all promotions of that group
INSERT INTO PG_ROI_component_3_update
SELECT	  cte.PromotionNumber,
		  cte.PromotionStartDate,
		  cte.PromotionEndDate,
		  cte.ProductNumber,
		  cte.Branch_name_EN,
		  cte.SourceInd,
		  cte.TransactionDate,
		  SUM(2.5*cte.Perc_revenue*bsd.Delta_quantity) AS 'Quantity_3_subs_group',
		  CASE WHEN SUM(2.5*cte.Perc_revenue*bsd.Delta_revenue) > 0 THEN 0
			  WHEN SUM(2.5*cte.Perc_revenue*bsd.Delta_revenue) <-ro.Revenue_1_promotion THEN -ro.Revenue_1_promotion
			  ELSE SUM(2.5*cte.Perc_revenue*bsd.Delta_revenue) END AS 'Revenue_3_subs_group',
		  CASE WHEN SUM(2.5*cte.Perc_revenue*bsd.Delta_revenue) > 0 THEN 0
			  WHEN SUM(2.5*cte.Perc_revenue*bsd.Delta_revenue) <-ro.Revenue_1_promotion THEN -ro.Margin_1_promotion
			  ELSE SUM(2.5*cte.Perc_revenue*bsd.Delta_margin) END AS 'Margin_3_subs_group',
		  CASE WHEN SUM(2.5*cte.Perc_revenue*bsd.Delta_revenue) > 0 THEN 1 ELSE 0 END,
		  CASE WHEN SUM(2.5*cte.Perc_revenue*bsd.Delta_revenue) < -ro.Revenue_1_promotion THEN 1 ELSE 0 END
FROM		  #product_substitute_levels_revenue cte
INNER JOIN  PG_ROI_component_3f_baseline_subs_daily_update bsd
ON		  bsd.Level = cte.Level
	   AND bsd.Level_ID = cte.Level_ID
	   AND bsd.SourceInd = cte.SourceInd
	   AND bsd.Branch_name_EN = cte.Branch_name_EN
	   AND bsd.TransactionDate = cte.TransactionDate
INNER JOIN  PG_ROI_component_1_update ro
ON		  ro.ProductNumber = cte.ProductNumber
	   AND ro.PromotionNumber = cte.PromotionNumber
	   AND ro.PromotionStartDate = cte.PromotionStartDate
	   AND ro.PromotionEndDate = cte.PromotionEndDate
	   AND ro.Branch_name_EN = cte.Branch_name_EN
	   AND ro.SourceInd = cte.SourceInd
	   AND ro.TransactionDate = cte.TransactionDate
GROUP BY	  cte.PromotionNumber,
		  cte.PromotionStartDate,
		  cte.PromotionEndDate,
		  cte.ProductNumber,
		  cte.Branch_name_EN,
		  cte.SourceInd,
		  cte.TransactionDate,
		  ro.Revenue_1_promotion,
		  ro.Margin_1_promotion;

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			CONCAT('ROI component 3 calculated between ',@dateX,' and ',@dateY),
			SYSDATETIME()
		)

-- Calculates group substitution on daily basis based on percentage sales of promotion product in all promotions of that group (on a supplier basis)
INSERT INTO PG_ROI_component_3g_substitution_suppliers_update
SELECT	  cte.PromotionNumber,
		  cte.PromotionStartDate,
		  cte.PromotionEndDate,
		  cte.ProductNumber,
		  pa1.Supplier_ID,
		  cte.Branch_name_EN,
		  cte.SourceInd,
		  cte.TransactionDate,
		  SUM(2.5*cte.Perc_revenue*bsd.Delta_quantity) AS 'Quantity_3_subs_group',
		  CASE WHEN SUM(2.5*cte.Perc_revenue*bsd.Delta_revenue) > 0 THEN 0
			  WHEN SUM(2.5*cte.Perc_revenue*bsd.Delta_revenue) <-ro.Revenue_1_promotion THEN -ro.Revenue_1_promotion
			  ELSE SUM(2.5*cte.Perc_revenue*bsd.Delta_revenue) END AS 'Revenue_3_subs_group',
		  CASE WHEN SUM(2.5*cte.Perc_revenue*bsd.Delta_revenue) > 0 THEN 0
			  WHEN SUM(2.5*cte.Perc_revenue*bsd.Delta_revenue) <-ro.Revenue_1_promotion THEN -ro.Margin_1_promotion
			  ELSE SUM(2.5*cte.Perc_revenue*bsd.Delta_margin) END AS 'Margin_3_subs_group',
		  CASE WHEN SUM(2.5*cte.Perc_revenue*bsd.Delta_revenue) > 0 THEN 1 ELSE 0 END,
		  CASE WHEN SUM(2.5*cte.Perc_revenue*bsd.Delta_revenue) < -ro.Revenue_1_promotion THEN 1 ELSE 0 END
FROM		  #product_substitute_levels_revenue cte
INNER JOIN  PG_ROI_component_3f_baseline_subs_daily_update bsd
ON		  bsd.Level = cte.Level
	   AND bsd.Level_ID = cte.Level_ID
	   AND bsd.SourceInd = cte.SourceInd
	   AND bsd.Branch_name_EN = cte.Branch_name_EN
	   AND bsd.TransactionDate = cte.TransactionDate
INNER JOIN  PG_ROI_component_1_update ro
ON		  ro.ProductNumber = cte.ProductNumber
	   AND ro.PromotionNumber = cte.PromotionNumber
	   AND ro.PromotionStartDate = cte.PromotionStartDate
	   AND ro.PromotionEndDate = cte.PromotionEndDate
	   AND ro.Branch_name_EN = cte.Branch_name_EN
	   AND ro.SourceInd = cte.SourceInd
	   AND ro.TransactionDate = cte.TransactionDate
INNER JOIN  Staging_product_assortment pa1
ON		  pa1.Product_ID = cte.ProductNumber
INNER JOIN  Staging_product_assortment pa2
ON		  pa2.Product_ID = bsd.ProductNumber
	   AND pa2.Supplier_ID = pa1.Supplier_ID
GROUP BY	  cte.PromotionNumber,
		  cte.PromotionStartDate,
		  cte.PromotionEndDate,
		  cte.ProductNumber,
		  pa1.Supplier_ID,
		  cte.Branch_name_EN,
		  cte.SourceInd,
		  cte.TransactionDate,
		  ro.Revenue_1_promotion,
		  ro.Margin_1_promotion;

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			CONCAT('ROI component 3 calculated for suppliers between ',@dateX,' and ',@dateY),
			SYSDATETIME()
		)

SET @dateX = DATEADD(day,@day_batch,@dateX)
SET @dateY = DATEADD(day,@day_batch,@dateY)

END

-- Move ROI component 3 data to history
DELETE FROM PG_ROI_component_3
WHERE	  TransactionDate BETWEEN @start_date AND @end_date
INSERT INTO PG_ROI_component_3
SELECT	  *
FROM		  PG_ROI_component_3_update

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'End of [update_7d_ROI_promotions_component_3]',
			SYSDATETIME()
		)

END
