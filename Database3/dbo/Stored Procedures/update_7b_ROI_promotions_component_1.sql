-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-04
-- Description:	Script for component 1 of ROI for weekly and monthly promotions
-- =============================================
CREATE PROCEDURE [dbo].[update_7b_ROI_promotions_component_1]
	@run_nr INT = 174,
    @run_date DATE = '2019-01-29',
	@step INT = 1,
    @start_date DATE = '2018-09-01',
    @end_date DATE = '2018-09-15'
AS
BEGIN

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Start of [update_7b_ROI_promotions_component_1]',
			SYSDATETIME()
		)

-- Calculates first component of the waterfall
TRUNCATE TABLE dbo.PG_ROI_component_1_update;
INSERT INTO dbo.PG_ROI_component_1_update
SELECT	  cp.PromotionNumber,
		  cp.PromotionCharacteristicsType,
		  cp.ProductNumber,
		  cp.PromotionStartDate,
		  cp.PromotionEndDate,
		  cp.SourceInd,
		  cp.Branch_name_EN,
		  dt.date AS 'TransactionDate',
		  dt.Valid_ind AS 'Ind_head_promotion',
		  ISNULL(dt.Valid_ind*at.Number_of_customers,0) AS 'Number_of_customers',
		  ISNULL(dt.Valid_ind*at.Quantity,0) AS 'Real_quantity',
		  ISNULL(dt.Valid_ind*at.Quantity,0) AS 'Quantity_1_promotion',
		  ISNULL(dt.Valid_ind*at.Revenue,0) AS 'Revenue_1_promotion',
		  ISNULL(dt.Valid_ind*at.Margin,0) AS 'Margin_1_promotion'
FROM		  PG_promotions_update cp
INNER JOIN  PG_promotions_dates_update dt
ON		  dt.PromotionNumber = cp.PromotionNumber
	   AND dt.ProductNumber = cp.ProductNumber
	   AND dt.Branch_name_EN = cp.Branch_name_EN
	   AND dt.SourceInd = cp.SourceInd
	   AND dt.Valid_ind = 1
LEFT JOIN   PG_sales_per_product_per_day_wo_returns at
ON		  cp.ProductNumber = at.ProductNumber
	   AND cp.Branch_name_EN = at.Branch_name_EN
	   AND cp.SourceInd = at.SourceInd
	   AND at.TransactionDate = dt.date

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'ROI component 1 calculated',
			SYSDATETIME()
		)

-- Move ROI component 1 data to history
DELETE FROM PG_ROI_component_1
WHERE	  TransactionDate BETWEEN @start_date AND @end_date
INSERT INTO PG_ROI_component_1
SELECT	  *
FROM		  dbo.PG_ROI_component_1_update
WHERE	  TransactionDate BETWEEN @start_date AND @end_date

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'End of [update_7b_ROI_promotions_component_1]',
			SYSDATETIME()
		)

END
