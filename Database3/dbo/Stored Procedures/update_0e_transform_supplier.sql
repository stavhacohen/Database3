-- =============================================
-- Author:		Tjeerd van Campen
-- Create date:	2018-06-11
-- Description:	Update supplier source data
-- =============================================
CREATE PROCEDURE [dbo].[update_0e_transform_supplier]
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
			'Start of [update_0e_transform_supplier]',
			SYSDATETIME()
		)

/* STEP 1: Purchase prices */
-- Transforms purchase prices
-- Make unique productnumber / subchain per supplier
INSERT INTO Staging_purchase_prices_update
SELECT	 [PRODUCT]
		  ,[NAME_PRODUCT]
		  ,[SUPPLIER]
		  ,[NAME_SUPPLIER]
		  ,[GROUPING]
		  ,[GROUP]
		  ,[FROM_DATE]
		  ,[TO_DATE]
		  ,Branch_name_EN
		  ,[CATALOG_PRICE]
		  ,[DISCOUNT_PERC]
		  ,[NET_PRICE]
FROM		  Staging_purchase_prices_import pp
INNER JOIN  dbo.Staging_branches br
ON		  pp.SUB_CHAIN = br.Branch_ID
	   AND br.Branch_name_EN IN ('Sheli','Organic','Deal','Online','Extra','Express','Yesh')
TRUNCATE TABLE Staging_purchase_prices_import

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'Purchase price file transformed',
			SYSDATETIME()
		)

-- Merges two purchase prices files
-- business rule based on data delivery
/*
DELETE FROM Staging_purchase_prices2
WHERE 


IF OBJECT_ID('tempdb.dbo.#purchase_prices','U') IS NOT NULL
    DROP TABLE #purchase_prices
SELECT	  *
INTO		  #purchase_prices
FROM		  Staging_purchase_prices_update
EXCEPT
SELECT	  *
FROM		  Staging_purchase_prices2

INSERT INTO Staging_purchase_prices2
SELECT	  *
FROM		  #purchase_prices

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'New purchase prices data inserted into dbo.Staging_purchase_prices',
			SYSDATETIME()
		)
*/

END
