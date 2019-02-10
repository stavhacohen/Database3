

-- =============================================
-- Author:		Matan Marudi
-- Create date:	2017-10-23
-- Description:	Transforms promotions and promotions stores to input files
-- =============================================
CREATE PROCEDURE [dbo].[Supplier_update_0d_transform_purchase_discount]
    @run_nr INT = 1,
    @step INT = 1,
    @run_date DATE = '2017-10-10'
AS
BEGIN

INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'Start of [Supplier_update_0d_transform_purchase_discount]',
			SYSDATETIME()
		)

/* STEP 1: Promotions */
-- Transforms promotion file
INSERT INTO Shufersal.dbo.Staging_purchase_discount
SELECT	  	
	ProductNumber,
	ProductDesc,
	SupplierNumber,
	SupplierDesc,
	[Grouping],
	[Group],
	cast (CONCAT (left(StartDate,4),'-',right(left(StartDate,6),2),'-',RIGHT(StartDate,2)) AS date ) StartDate,
	Sub_chain,
	TRY_CONVERT ( decimal (10,2),Catalog_Price)Catalog_Price,
	TRY_CONVERT ( decimal (10,2),Discount)Discount,
	TRY_CONVERT ( decimal (10,2),Net_Catalog_Price)Net_Catalog_Price,
	GETDATE() import_date
FROM		  Shufersal.dbo.Staging_purchase_discount_import

TRUNCATE TABLE Shufersal.dbo.PG_purchase_discount_update
INSERT INTO Shufersal.dbo.PG_purchase_discount_update
SELECT	  	
	ProductNumber,
	ProductDesc,
	SupplierNumber,
	SupplierDesc,
	[Grouping],
	[Group],
	cast (CONCAT (left(StartDate,4),'-',right(left(StartDate,6),2),'-',RIGHT(StartDate,2)) AS date ) StartDate,
	Sub_chain,
	TRY_CONVERT ( decimal (10,2),Catalog_Price) Catalog_Price,
	TRY_CONVERT ( decimal (10,2),Discount) Discount,
	TRY_CONVERT ( decimal (10,2),Net_Catalog_Price) Net_Catalog_Price
FROM Shufersal.dbo.Staging_purchase_discount_import

TRUNCATE TABLE Shufersal.dbo.Staging_purchase_discount_import

SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'Staging_purchase_discount transformed',
			SYSDATETIME()
		)


SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'New purchase_discount data inserted into dbo.Staging_purchase_discount',
			SYSDATETIME()
		)



SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'End of [Supplier_update_0d_transform_purchase_discount]',
			SYSDATETIME()
		)

END


