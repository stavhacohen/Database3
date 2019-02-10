
-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-18
-- Description:	Script for component 7 of ROI for weekly and monthly promotions
-- =============================================
CREATE PROCEDURE [dbo].[update_7g_ROI_promotions_component_7]
	@run_nr INT = 25,
	@run_date DATE = '2017-11-16',
	@step INT = 1,
	@start_date DATE = '2017-10-01',
	@end_date DATE = '2017-10-30',
	@after_days INT = 28,
	@customer_days INT = 42,
	@customer_batch INT = 500000
AS
BEGIN

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Start of [update_7g_ROI_promotions_component_7]',
			SYSDATETIME()
		)

    DECLARE @date DATE = @start_date;

-- Move transactions data to history (if there is new data)
IF (SELECT MAX(TransactionDate) FROM Staging_transactions_total_update) IS NOT NULL
BEGIN

    SET @date = @start_date
    WHILE @date <= @end_date
    BEGIN
	   DELETE FROM Staging_transactions_total
	   WHERE		TransactionDate = @date
	   
	   INSERT INTO Staging_transactions_total
	   SELECT		*
	   FROM		Staging_transactions_total_update
	   WHERE		TransactionDate = @date

	   SET @step = @step + 1;
	   INSERT INTO PG_update_log
	   VALUES(	@run_nr,
				@run_date,
				7,
				@step,
				CONCAT('Data inserted into Staging_transactions_total for ',@date),
				SYSDATETIME()
			 );
	   
	   SET		@date = DATEADD(day,1,@date)
    END

    TRUNCATE TABLE Staging_transactions_total_update
END

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Transactions data moved to history',
			SYSDATETIME()
		)

-- Indicates when there has been a promotion between the current date and the end date of the promotion that is considered
IF OBJECT_ID('dbo.PG_ROI_component_7a_promo_product_ind_accum_update', 'U') IS NOT NULL
    DROP TABLE dbo.PG_ROI_component_7a_promo_product_ind_accum_update;
SELECT	  cp.PromotionNumber,
		  cp.PromotionStartDate,
		  cp.PromotionEndDate,
		  ppi1.ProductNumber,
		  ppi1.Branch_name_EN,
		  ppi1.SourceInd,
		  ppi1.TransactionDate,
		  1 AS 'Days_after_promotion',
		  CASE WHEN ro.Ind_sufficient_discount = 1 THEN 0
			  WHEN ppi1.Promo_ind >= 1 THEN 1
			  ELSE 0 END AS 'Promo_accum_ind'
INTO		  dbo.PG_ROI_component_7a_promo_product_ind_accum_update
FROM		  PG_promo_product_ind ppi1
INNER JOIN  PG_promotions_update cp
ON		  cp.ProductNumber = ppi1.ProductNumber
	   AND cp.Branch_name_EN = ppi1.Branch_name_EN
	   AND cp.SourceInd = ppi1.SourceInd
	   AND ppi1.TransactionDate = DATEADD(day,1,cp.PromotionEndDate)
LEFT JOIN	  dbo.PG_ROI_component_2c_continuous_promotions_update ro
ON		  ro.PromotionNumber = cp.PromotionNumber
	   AND ro.PromotionStartDate = cp.PromotionStartDate
	   AND ro.PromotionEndDate = cp.PromotionEndDate
	   AND ro.ProductNumber = cp.ProductNumber
	   AND ro.Branch_name_EN = cp.Branch_name_EN
	   AND ro.SourceInd = cp.SourceInd

DECLARE @day INT = 2;
WHILE @day <= @after_days
BEGIN
    INSERT INTO PG_ROI_component_7a_promo_product_ind_accum_update
    SELECT	 ppi1.PromotionNumber,
			 ppi1.PromotionStartDate,
			 ppi1.PromotionEndDate,
			 ppi1.ProductNumber,
			 ppi1.Branch_name_EN,
			 ppi1.SourceInd,
			 DATEADD(day,1,ppi1.TransactionDate) AS 'TransactionDate',
			 @day,
			 CASE WHEN ro.Ind_sufficient_discount = 1 THEN 0
				 WHEN ppi2.Promo_ind >= 1 OR ppi1.Promo_accum_ind >= 1 THEN 1 ELSE 0 END
    FROM		 PG_ROI_component_7a_promo_product_ind_accum_update ppi1
    INNER JOIN	 PG_promo_product_ind ppi2
    ON		 ppi1.ProductNumber = ppi2.ProductNumber
		  AND ppi1.Branch_name_EN = ppi2.Branch_name_EN
		  AND ppi1.SourceInd = ppi2.SourceInd
		  AND ppi2.TransactionDate = DATEADD(day,1,ppi1.TransactionDate)
    LEFT JOIN	 dbo.PG_ROI_component_2c_continuous_promotions_update ro
    ON		 ro.PromotionNumber = ppi1.PromotionNumber
		  AND ro.PromotionStartDate = ppi1.PromotionStartDate
		  AND ro.PromotionEndDate = ppi1.PromotionEndDate
		  AND ro.ProductNumber = ppi1.ProductNumber
		  AND ro.Branch_name_EN = ppi1.Branch_name_EN
		  AND ro.SourceInd = ppi1.SourceInd        
    WHERE		 ppi1.Days_after_promotion = @day-1;

    SET @step = @step + 1;
    INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			CONCAT('Promotion after days calculated for ',@day,' days'),
			SYSDATETIME()
		)

    SET @day = @day + 1;
END

-- Selects only relevant customers of promotion
IF OBJECT_ID('tempdb.dbo.#customers_of_promotion', 'U') IS NOT NULL
    DROP TABLE #customers_of_promotion;
SELECT	  *
INTO		  #customers_of_promotion
FROM		  PG_ROI_component_4b_customers_of_promotion
WHERE	  PromotionStartDate >= (SELECT MIN(Date) FROM PG_promotions_dates_update)

-- Creates table with product sales per customer before and after promotion
IF OBJECT_ID('dbo.PG_ROI_component_7b_product_sales_per_customer_update', 'U') IS NOT NULL
    DROP TABLE PG_ROI_component_7b_product_sales_per_customer_update;
CREATE TABLE dbo.PG_ROI_component_7b_product_sales_per_customer_update
(HouseholdID		INT,
 PromotionNumber	BIGINT,
 PromotionStartDate DATE,
 PromotionEndDate	DATE,
 ProductNumber		BIGINT,
 Total_product_revenue DECIMAL(10,2),
 Quantity_before_promotion DECIMAL(10,2),
 Quantity_after_promotion DECIMAL(10,2),
 Revenue_after_promotion DECIMAL(10,2),
 Margin_after_promotion DECIMAL(10,2)
)

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Table created with product sales per customer before and after promotion',
			SYSDATETIME()
		)

-- Calculates total sales of the product before and after the promotion of the customer 
DECLARE @countX INT = 1;
DECLARE @countY INT = @customer_batch;

WHILE @countX <= (SELECT MAX(Ind) FROM PG_customers)
BEGIN

IF OBJECT_ID('tempdb.dbo.#customers_of_promotion_batch', 'U') IS NOT NULL
    DROP TABLE #customers_of_promotion_batch;
SELECT	  cu.HouseholdID,
		  cu.PromotionNumber,
		  cu.PromotionStartDate,
		  cu.PromotionEndDate,
		  cu.ProductNumber,
		  SUM(cu.Revenue) AS 'Total_product_revenue'
 INTO	  #customers_of_promotion_batch
 FROM	  #customers_of_promotion cu
 INNER JOIN PG_promotions_update pu
 ON		  pu.PromotionNumber = cu.PromotionNumber
	   AND pu.Branch_name_EN = cu.Branch_name_EN
	   AND pu.SourceInd = cu.SourceInd
	   AND pu.PromotionStartDate = cu.PromotionStartDate
	   AND pu.PromotionEndDate = cu.PromotionEndDate
	   AND pu.ProductNumber = cu.ProductNumber
 WHERE	  cu.new_customer_ind = 0 --only look at existing customers adopting the product
	   AND cu.HouseholdID IN (SELECT HouseholdID FROM dbo.PG_customers WHERE Ind BETWEEN @countX AND @countY)
 GROUP BY	  cu.HouseholdID,
		  cu.PromotionNumber,
		  cu.PromotionStartDate,
		  cu.PromotionEndDate,
		  cu.ProductNumber

INSERT INTO PG_ROI_component_7b_product_sales_per_customer_update
SELECT	  cte.HouseholdID,
		  cte.PromotionNumber,
		  cte.PromotionStartDate,
		  cte.PromotionEndDate,
		  cte.ProductNumber,
		  cte.Total_product_revenue,
		  SUM(CASE WHEN tt.Quantity > 0 AND tt.TransactionDate < cte.PromotionStartDate THEN tt.Quantity ELSE 0 END)
			 AS 'Quantity_before_promotion',
		  SUM(CASE WHEN tt.Quantity > 0 AND tt.TransactionDate > cte.PromotionEndDate AND ppi.Promo_accum_ind = 0 THEN tt.Quantity ELSE 0 END)
			 AS 'Quantity_after_promotion',
		  SUM(CASE WHEN tt.Quantity > 0 AND tt.TransactionDate > cte.PromotionEndDate AND ppi.Promo_accum_ind = 0 THEN tt.NetSaleNoVAT ELSE 0 END)
			 AS 'Revenue_after_promotion',
		  SUM(CASE WHEN tt.Quantity > 0 AND tt.TransactionDate > cte.PromotionEndDate AND ppi.Promo_accum_ind = 0 THEN tt.Range_Amtttt ELSE 0 END)
			 AS 'Margin_after_promotion'
FROM		  #customers_of_promotion_batch cte
INNER JOIN  Staging_transactions_total tt
ON		  tt.HouseholdID = cte.HouseholdID
	   AND tt.ProductNumber = cte.ProductNumber
-- To avoid double counting we only look at the period before and after the promotion
	   AND (tt.TransactionDate BETWEEN DATEADD(day,-@customer_days+1,cte.PromotionStartDate) AND DATEADD(day,-1,cte.PromotionStartDate)
	        OR tt.TransactionDate BETWEEN DATEADD(day,1,cte.PromotionEndDate) AND DATEADD(day,@after_days,cte.PromotionEndDate))
INNER JOIN  dbo.Staging_branches br
ON		  br.Branch_ID = tt.StoreFormatCode
	   AND br.Branch_name_EN IN ('Deal','Extra','Sheli','Express','Extra')
LEFT JOIN	  PG_ROI_component_7a_promo_product_ind_accum_update ppi
ON		  cte.ProductNumber = ppi.ProductNumber
	   AND ppi.Branch_name_EN = br.Branch_name_EN
	   AND ppi.SourceInd = tt.SourceInd
	   AND ppi.TransactionDate = tt.TransactionDate
	   AND ppi.PromotionNumber = cte.PromotionNumber
	   AND ppi.PromotionStartDate = cte.PromotionStartDate
	   AND ppi.PromotionEndDate = cte.PromotionEndDate
GROUP BY	  cte.HouseholdID,
		  cte.PromotionNumber,
		  cte.PromotionStartDate,
		  cte.PromotionEndDate,
		  cte.ProductNumber,
		  cte.Total_product_revenue

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			CONCAT('Product sales per customer before and after promotion calculated for customers ',@countX,' until ',@countY),
			SYSDATETIME()
		)

SET @countX = @countX + @customer_batch;
SET @countY = @countY + @customer_batch;

END

-- Calculates product adoption effects per promotion
TRUNCATE TABLE PG_ROI_component_7_update;
INSERT INTO PG_ROI_component_7_update
SELECT	  cu.PromotionNumber,
		  cu.PromotionStartDate,
		  cu.PromotionEndDate,
		  cu.ProductNumber,
		  cu.Branch_name_EN,
		  cu.SourceInd,
		  cu.TransactionDate,
		  lp.loyalty_perc_quantity*SUM(CASE WHEN psc.Total_product_revenue <> 0 THEN cu.Revenue/psc.Total_product_revenue*psc.Quantity_after_promotion ELSE 0 END) AS 'Quantity_7_product_adoption',
		  lp.loyalty_perc_quantity*SUM(CASE WHEN psc.Total_product_revenue <> 0 THEN cu.Revenue/psc.Total_product_revenue*psc.Revenue_after_promotion ELSE 0 END) AS 'Revenue_7_product_adoption',
		  lp.loyalty_perc_quantity*SUM(CASE WHEN psc.Total_product_revenue <> 0 THEN cu.Revenue/psc.Total_product_revenue*psc.Margin_after_promotion ELSE 0 END) AS 'Margin_7_product_adoption'
FROM		  #customers_of_promotion cu
INNER JOIN  PG_ROI_component_7b_product_sales_per_customer_update psc
ON		  cu.HouseholdID = psc.HouseholdID
	   AND cu.PromotionNumber = psc.PromotionNumber
	   AND cu.PromotionStartDate = psc.PromotionStartDate
	   AND cu.PromotionEndDate = psc.PromotionEndDate
	   AND cu.ProductNumber = psc.ProductNumber
	   AND psc.Quantity_before_promotion = 0
INNER JOIN  PG_ROI_component_4a_loyalty_perc lp
ON		  cu.TransactionDate = lp.TransactionDate
	   AND cu.ProductNumber = lp.ProductNumber
	   AND cu.SourceInd = lp.SourceInd
	   AND cu.Branch_name_EN = lp.Branch_name_EN
	   AND cu.PromotionNumber = lp.PromotionNumber
	   AND cu.PromotionStartDate = lp.PromotionStartDate
	   AND cu.PromotionEndDate = lp.PromotionEndDate
GROUP BY	  cu.PromotionNumber,
		  cu.PromotionStartDate,
		  cu.PromotionEndDate,
		  cu.ProductNumber,
		  cu.Branch_name_EN,
		  cu.TransactionDate,
		  cu.SourceInd,
		  lp.loyalty_perc_quantity

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'New customer effect per promotion calculated',
			SYSDATETIME()
		)

-- Calculates number of adopting customers per promotion product per day
TRUNCATE TABLE PG_ROI_component_7c_adopting_customers_update;
INSERT INTO dbo.PG_ROI_component_7c_adopting_customers_update
SELECT	  cu.PromotionNumber,
		  cu.PromotionStartDate,
		  cu.PromotionEndDate,
		  cu.ProductNumber,
		  cu.TransactionDate,
		  cu.Branch_name_EN,
		  cu.SourceInd,
		  lp.loyalty_perc_quantity*COUNT(DISTINCT cu.HouseholdID) AS 'Adopting_customers'
FROM		  #customers_of_promotion cu
INNER JOIN  PG_ROI_component_7b_product_sales_per_customer_update psc
ON		  cu.HouseholdID = psc.HouseholdID
	   AND cu.PromotionNumber = psc.PromotionNumber
	   AND cu.PromotionStartDate = psc.PromotionStartDate
	   AND cu.PromotionEndDate = psc.PromotionEndDate
	   AND cu.ProductNumber = psc.ProductNumber
	   AND psc.Quantity_before_promotion = 0
INNER JOIN  PG_ROI_component_4a_loyalty_perc lp
ON		  cu.TransactionDate = lp.TransactionDate
	   AND cu.ProductNumber = lp.ProductNumber
	   AND cu.SourceInd = lp.SourceInd
	   AND cu.Branch_name_EN = lp.Branch_name_EN
	   AND cu.PromotionNumber = lp.PromotionNumber
	   AND cu.PromotionStartDate = lp.PromotionStartDate
	   AND cu.PromotionEndDate = lp.PromotionEndDate
GROUP BY	  cu.PromotionNumber,
		  cu.PromotionStartDate,
		  cu.PromotionEndDate,
		  cu.ProductNumber,
		  cu.TransactionDate,
		  cu.Branch_name_EN,
		  cu.SourceInd,
		  lp.loyalty_perc_quantity

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Product adoption effects calculated',
			SYSDATETIME()
		)

-- Move data for ROI component 7 to history
DELETE FROM PG_ROI_component_7
WHERE	  PromotionEndDate >= DATEADD(day,-28,@start_date)
INSERT INTO PG_ROI_component_7
SELECT	  *
FROM		  PG_ROI_component_7_update

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'End of [update_7g_ROI_promotions_component_7]',
			SYSDATETIME()
		)

END

