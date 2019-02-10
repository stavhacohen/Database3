
-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-23
-- Description:	Indicates if there has been a promotion or not
-- =============================================
CREATE PROCEDURE [dbo].[update_1_promo_product_ind]
    @run_nr INT = 1,
    @run_date DATE = '2017-10-03',
    @start_date DATE = '2017-07-01',
    @end_date DATE = '2017-09-30'
AS
BEGIN

DECLARE @step INT = 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,1,@step,'Start of [update_1_promo_product_ind]',SYSDATETIME())

-- Creates table that indicates if there has been an promotion of a product or not
IF OBJECT_ID('tempdb.dbo.#promo_product_ind','U') IS NOT NULL
    DROP TABLE #promo_product_ind;
CREATE TABLE #promo_product_ind
(   ProductNumber BIGINT,
    TransactionDate DATE,
    Branch_name_EN VARCHAR(7),
    SourceInd SMALLINT,
    Promo_ind SMALLINT,
);

SET @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,1,@step,'Table created that indicates if there has been an promotion of a product or not',SYSDATETIME())

-- Indicates per day if there has been an promotion of a product or not
DECLARE   @date DATE = @start_date;
WHILE	@date <= @end_date
BEGIN
    INSERT INTO #promo_product_ind
    SELECT	 pa.Product_ID AS 'ProductNumber',
			 @date AS 'TransactionDate',
			 CONVERT(VARCHAR(7),br.Branch_name_EN) AS 'Branch_name_EN',
			 br.SourceInd,
			 CASE WHEN SUM(CASE WHEN pr.ProductNumber IS NOT NULL THEN 1 ELSE 0 END) > 0 THEN 1 ELSE 0 END AS 'Promo_ind'
    FROM		 dbo.PG_product_assortment pa
    CROSS JOIN  dbo.PG_branches_sources br
    LEFT JOIN   PG_promotions_stores_update pr
    ON		 pr.ProductNumber = pa.Product_ID
		  AND @date BETWEEN pr.PromotionStartDate AND pr.PromotionEndDate
		  AND br.SourceInd = pr.SourceInd
		  AND br.Branch_name_EN = pr.Branch_name_EN
    GROUP BY	 pa.Product_ID,
			 br.Branch_name_EN,
			 br.SourceInd
    
    SET @step = @step + 1;
    INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,1,@step,CONCAT('Promotion indicators of ',@date,' calculated'),SYSDATETIME())

    SET @date = DATEADD(day,1,@date);
END

-- Drops and creates table with promotion product indicators for update period
IF OBJECT_ID('dbo.PG_promo_product_ind_update','U') IS NOT NULL
    DROP TABLE dbo.PG_promo_product_ind_update;
CREATE TABLE dbo.PG_promo_product_ind_update
(   ProductNumber BIGINT,
    TransactionDate DATE,
    Branch_name_EN VARCHAR(7),
    SourceInd SMALLINT,
    Promo_ind SMALLINT,
    Promotion_days INT
);
SET		  @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,1,@step,'Table created with promotion product indicators for update period',SYSDATETIME())

-- Script to indicate promotions and how long there are already in promotion
SET @date = @start_date;
IF OBJECT_ID('tempdb.dbo.#PG_promo_product_ind_last_date','U') IS NOT NULL
    DROP TABLE #PG_promo_product_ind_last_date;
SELECT	  *
INTO		  #PG_promo_product_ind_last_date
FROM		  dbo.PG_promo_product_ind
WHERE	  TransactionDate = DATEADD(day,-1,@start_date)

INSERT INTO dbo.PG_promo_product_ind_update
SELECT	  pr1.ProductNumber,
		  pr1.TransactionDate,
		  pr1.Branch_name_EN,
		  pr1.SourceInd,
		  pr1.Promo_ind,
		  CASE WHEN pr2.TransactionDate IS NULL AND pr1.Promo_ind = 1 THEN 1
			  WHEN pr2.TransactionDate IS NULL AND pr1.Promo_ind = 0 THEN 0
			  WHEN pr2.TransactionDate IS NOT NULL AND pr1.Promo_ind = 1 THEN pr2.Promotion_days + 1
			  ELSE 0 END
FROM		 #promo_product_ind pr1
LEFT JOIN	 #PG_promo_product_ind_last_date pr2
ON		 pr1.TransactionDate = DATEADD(day,1,pr2.TransactionDate)
	  AND pr1.ProductNumber = pr2.ProductNumber
	  AND pr1.Branch_name_EN = pr2.Branch_name_EN
	  AND pr1.SourceInd = pr2.SourceInd
WHERE      pr1.TransactionDate = @date;

SET @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,1,@step,CONCAT('Accumulated promotion indicators of ',@date,' calculated'),SYSDATETIME())
SET @date = DATEADD(day,1,@date);
WHILE   @date <= @end_date
BEGIN
    INSERT INTO dbo.PG_promo_product_ind_update
    SELECT	 pr1.ProductNumber,
			 pr1.TransactionDate,
			 pr1.Branch_name_EN,
			 pr1.SourceInd,
			 pr1.Promo_ind,
			 CASE WHEN pr2.TransactionDate IS NULL AND pr1.Promo_ind = 1 THEN 1
				 WHEN pr2.TransactionDate IS NULL AND pr1.Promo_ind = 0 THEN 0
				 WHEN pr2.TransactionDate IS NOT NULL AND pr1.Promo_ind = 1 THEN pr2.Promotion_days + 1
				 ELSE 0 END
    FROM		 #promo_product_ind pr1
    LEFT JOIN	 dbo.PG_promo_product_ind_update pr2
    ON		 pr1.TransactionDate = DATEADD(day,1,pr2.TransactionDate)
		  AND pr1.ProductNumber = pr2.ProductNumber
		  AND pr1.Branch_name_EN = pr2.Branch_name_EN
		  AND pr1.SourceInd = pr2.SourceInd
    WHERE		 pr1.TransactionDate = @date;

    SET @step = @step + 1;
    INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,1,@step,CONCAT('Acculated promotion indicators of ',@date,' calculated'),SYSDATETIME())
    SET @date = DATEADD(day,1,@date);
END

--Creates indexes
CREATE CLUSTERED INDEX cl_index_product ON PG_promo_product_ind_update(ProductNumber)
SET @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,1,@step,'Clustered index on product number created',SYSDATETIME())
CREATE NONCLUSTERED INDEX index_date ON PG_promo_product_ind_update(TransactionDate)
SET @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,1,@step,'Nonclustered index on transaction date created',SYSDATETIME())
CREATE NONCLUSTERED INDEX index_branch ON PG_promo_product_ind_update(Branch_name_EN)
SET @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,1,@step,'Nonclustered index on format created',SYSDATETIME())
CREATE NONCLUSTERED INDEX index_source ON PG_promo_product_ind_update(SourceInd)
SET @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,1,@step,'Nonclustered index on source indicator created',SYSDATETIME())

SET @step = @step + 1;
INSERT INTO dbo.PG_update_log VALUES(@run_nr,@run_date,1,@step,'End of [update_1_promo_product_ind]',SYSDATETIME())

END

