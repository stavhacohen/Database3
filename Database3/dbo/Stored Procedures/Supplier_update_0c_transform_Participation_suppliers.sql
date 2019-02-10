
-- =============================================
-- Author:		Matan Marudi & Hagai Weiss
-- Create date:	2018-12-18
-- Description:	Transforms Sell-in
-- =============================================
CREATE PROCEDURE [dbo].[Supplier_update_0c_transform_Participation_suppliers]
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
			'Start of [Supplier_update_0c_transform_Participation_supplier]',
			SYSDATETIME()
		)


SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'Inserting data to staging update and staging historic tables',
			SYSDATETIME()
		)

/* STEP 1: Promotions */
-- Transforms promotion file
INSERT INTO Shufersal.dbo.Staging_Participation_suppliers_update
SELECT	  	
	StoreFormatCode,
	StoreFormatDesc,
	ProductNumber,
	ProductDesc,
	SupplierNumber,
	SupplierDesc,
	MonthNumber,
	Metrics,
	TRY_CONVERT ( decimal (10,2),Sales)Sales,
	TRY_CONVERT ( decimal (10,2),PriceA)PriceA,
	TRY_CONVERT ( decimal (10,2),PriceB)PriceB,
	TRY_CONVERT ( decimal (10,2),Mimush)Mimush,
	TRY_CONVERT ( decimal (10,2),Quantity)Quantity
FROM Shufersal.dbo.Staging_Participation_suppliers_import


-- insert data to staging Historic
INSERT INTO Shufersal.dbo.Staging_Participation_suppliers
SELECT	  	
	StoreFormatCode,
	StoreFormatDesc,
	ProductNumber,
	ProductDesc,
	SupplierNumber,
	SupplierDesc,
	MonthNumber,
	Metrics,
	Sales,
	PriceA,
	PriceB,
	Mimush,
	Quantity,
	GETDATE() import_date
FROM Shufersal.dbo.Staging_Participation_suppliers_update

--truncate import table
TRUNCATE TABLE Staging_Participation_suppliers_import

SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'building PG update table',
			SYSDATETIME()
		)

--build PG update table (truncate first)
TRUNCATE TABLE Shufersal.dbo.PG_Participation_suppliers_update
INSERT INTO Shufersal.dbo.PG_Participation_suppliers_update
SELECT	  	
	StoreFormatCode,
	StoreFormatDesc,
	ProductNumber,
	ProductDesc,
	SupplierNumber,
	SupplierDesc,
	MonthNumber,
	Metrics,
	Sales/NULLIF(Quantity,0) Sales,
	PriceA/NULLIF(Quantity,0) PriceA,
	PriceB/NULLIF(Quantity,0) PriceB,
	Mimush/NULLIF(Quantity,0) Mimush,
	Quantity
FROM Shufersal.dbo.Staging_Participation_suppliers_update




SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'inserting PG update to history',
			SYSDATETIME()
		)

--insert PG update to history
INSERT INTO Shufersal.dbo.PG_Participation_suppliers
SELECT	  	
	StoreFormatCode,
	StoreFormatDesc,
	ProductNumber,
	ProductDesc,
	SupplierNumber,
	SupplierDesc,
	MonthNumber,
	Metrics,
	Sales,
	PriceA,
	PriceB,
	Mimush,
	Quantity,
	GETDATE() import_date
FROM Shufersal.dbo.PG_Participation_suppliers_update




SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'End of [Supplier_update_0c_transform_Participation_supplier]',
			SYSDATETIME()
		)

END

