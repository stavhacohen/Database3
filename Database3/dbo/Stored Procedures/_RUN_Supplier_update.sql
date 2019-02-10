-- =============================================
-- Author:		Gal Naamani
-- Create date:	2018-12-25
-- Description:	Execute the weekly Supplier update
-- =============================================
CREATE PROCEDURE [dbo].[_RUN_Supplier_update]

    -- Standard input
    @run_nr INT = 158,
    @run_date DATE = '2018-12-21',
    @start_date DATE = '2018-09-18',
    @end_date DATE = '2018-09-24',
	@start_date_1_5 DATE,
    @end_date_1_5 DATE,

    -- Update part 7
    @after_days INT = 28

AS
BEGIN

INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			-1,
			1,
			'Start of the supplier update',
			SYSDATETIME()
		)

--Insert new RAS rows to RAS_wave1_5
DECLARE @c1 INT;
SELECT @c1=COUNT(supplier_ID)
FROM PG_input_RAS_Wave1_5
WHERE  TransactionDate>=@start_date AND TransactionDate<=@end_date

DELETE FROM PG_input_RAS_Wave1_5
WHERE  TransactionDate>=@start_date AND TransactionDate<=@end_date
INSERT INTO PG_input_RAS_Wave1_5
SELECT	  *,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL,
		  NULL
FROM	PG_input_RAS
WHERE TransactionDate>=@start_date and TransactionDate<=@end_date

INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			-1,
			2,
			'Supplier Update: Inserted/Replaced the updated RAS rows ',
			SYSDATETIME()
		)


--If we replaced existing data we need to update the supplier data for those dates again
IF (ISNULL(@c1,0)>0)
	BEGIN
		--Create PG update tables
		--Promotion Sell-Out
		TRUNCATE TABLE Shufersal.dbo.PG_supplier_billing_update
		INSERT INTO Shufersal.dbo.PG_supplier_billing_update
		SELECT DISCOUNT_ID
			  ,Branch_name_EN
		  	  ,date0
			  ,SUPPLIER_ID
			  ,[MONTH]
			  ,SUPPLIER_NAME
			  ,FORMAT_ID_Sarit
			  ,TOTAL_SALES
			  ,SUPPLIER_PARTICIPATION
			  ,avg_partic
		FROM (SELECT *,
			         ROW_NUMBER() OVER (PARTITION BY DISCOUNT_ID,Branch_name_EN,date0,SUPPLIER_ID ORDER BY import_date DESC) AS rnum
			  FROM Shufersal.dbo.PG_supplier_billing
			  WHERE date0>=@start_date and date0<=@end_date
			 ) k
		WHERE rnum=1

		--Product Sell-Out
		TRUNCATE TABLE Shufersal.dbo.PG_supplier_billing_in_sales_update
		INSERT INTO Shufersal.dbo.PG_supplier_billing_in_sales_update
		SELECT PRODUCT_ID
			  ,Branch_name_EN
			  ,date0
		  	  ,SUPPLIER_ID
			  ,MONTH
			  ,SUPPLIER_NAME
			  ,FORMAT_ID_Sarit
			  ,TOTAL_SALES
			  ,SUPPLIER_PARTICIPATION
			  ,avg_partic
		FROM (SELECT *,
			         ROW_NUMBER() OVER (PARTITION BY PRODUCT_ID,Branch_name_EN,date0,SUPPLIER_ID ORDER BY import_date DESC) AS rnum
			  FROM Shufersal.dbo.PG_supplier_billing_in_sales
			  WHERE date0>=@start_date and date0<=@end_date
			 ) k
		WHERE rnum=1

		--Sell In
		TRUNCATE TABLE Shufersal.dbo.PG_Participation_suppliers_update
		INSERT INTO Shufersal.dbo.PG_Participation_suppliers_update
		SELECT StoreFormatCode,
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
			   Quantity
		FROM (SELECT *,
			         ROW_NUMBER() OVER (PARTITION BY StoreFormatCode,ProductNumber,SupplierNumber,MonthNumber ORDER BY import_date DESC) AS rnum
			  FROM Shufersal.dbo.PG_Participation_suppliers
			  WHERE MonthNumber>=(YEAR(@start_date)*100+MONTH(@start_date)) and MonthNumber<=(YEAR(@end_date)*100+MONTH(@end_date))
			 ) k
		WHERE rnum=1
	
	    --Supplier List
		TRUNCATE TABLE Shufersal.dbo.PG_purchase_discount_update
		INSERT INTO Shufersal.dbo.PG_purchase_discount_update
		SELECT ProductNumber,
			   ProductDesc,
			   SupplierNumber,
			   SupplierDesc,
			   [Grouping],
			   [Group],
			   StartDate,
			   Sub_chain,
			   Catalog_Price,
			   Discount,
			   Net_Catalog_Price
		FROM (SELECT *,
					 ROW_NUMBER() OVER (PARTITION BY ProductNumber,Sub_chain ORDER BY import_date DESC) AS rnum
			  FROM Shufersal.dbo.Staging_purchase_discount
			  WHERE StartDate<=@start_date) k
		WHERE rnum=1

		--Set additional parameters
		SET @start_date_1_5 = @start_date
		SET @end_date_1_5 = @end_date
		SET @run_date = CONVERT(date,GETDATE())
		IF @run_nr IS NULL
			SET @run_nr = (SELECT MAX(run_nr) FROM PG_update_log);

		EXEC	Supplier_update_1a_Update_supplier_list
		    @run_nr,1, @run_date

		EXEC	Supplier_update_1b_Update_supplier_distributions
			@run_nr,10, @run_date, @start_date_1_5, @end_date_1_5

		EXEC	Supplier_update_2_Update_Retro_effects
			@run_nr,1, @run_date, @start_date_1_5, @end_date_1_5, @after_days

		EXEC	Supplier_update_3_Supplier_RAS
			@run_nr,1, @run_date, @start_date_1_5, @end_date_1_5

		INSERT INTO PG_update_log
				VALUES(	@run_nr,
						@run_date,
						-1,
						3,
						'Supplier Update: Inserted/Replaced the updated Supplier RAS rows ',
						SYSDATETIME()
		)

	END


--Create a table which holds what supplier information we currently have in each month both in the RAS and in the import tables
IF OBJECT_ID('tempdb..#CNT_sup_Data' ,'U') IS NOT NULL
    DROP TABLE [#CNT_sup_Data];
SELECT t1.YM AS [YearMonth],
	   t1.cnt_tot AS Cnt_Rows_in_RAS1_5,
       t1.participation AS Cnt_Rows_with_Participation,
       t1.suppliers AS Cnt_Rows_with_Supplier,
	   t2.cnt AS Cnt_Rows_in_billing,
	   t3.cnt AS Cnt_Rows_in_billing_in_sales,
	   t4.cnt AS Cnt_Rows_in_sellin,
	   t5.cnt AS Cnt_Rows_in_supplier_list
INTO [#CNT_sup_Data]
FROM (SELECT YEAR(TransactionDate)*100+MONTH(TransactionDate) AS YM,
             SUM(CASE WHEN supplier_ID IS NULL THEN 0 ELSE 1 END) AS Suppliers,
	         SUM(CASE WHEN Tot_Participation IS NULL THEN 0 ELSE 1 END) AS Participation,
			 COUNT(*) AS cnt_tot
	  FROM PG_input_RAS_Wave1_5
	  GROUP BY YEAR(TransactionDate)*100+MONTH(TransactionDate)
	 ) t1
LEFT JOIN (SELECT [MONTH] AS YM,
				  COUNT(*) AS cnt 
		   FROM Staging_supplier_billing_import 
		   GROUP BY [MONTH]
		  ) t2
ON t1.YM=t2.YM
LEFT JOIN (SELECT [MONTH] AS YM,
				  COUNT(*) AS cnt 
		   FROM Staging_supplier_billing_in_sales_import 
		   GROUP BY [MONTH]
		  ) t3
ON t1.YM=t3.YM
LEFT JOIN (SELECT MonthNumber AS YM,
                  COUNT(*) AS cnt 
		   FROM Staging_Participation_suppliers_import 
		   GROUP BY MonthNumber
		  ) t4
ON t1.YM=t4.YM
left JOIN (SELECT ROUND(StartDate/100,0) AS YM,
                  COUNT(*) AS cnt
		   FROM Staging_purchase_discount_import
		   GROUP BY ROUND(StartDate/100,0)
		  ) t5
ON t1.YM=t5.YM

--Automaticaly choose for the update the minimum (earliest) month where we do not have supplier data in the RAS and do have supplier data in the import files
SELECT @start_date_1_5=CONVERT(DATE,CONVERT(CHAR(8),MIN([YearMonth]*100+1))),
	   @end_date_1_5=EOMONTH(CONVERT(DATE,CONVERT(CHAR(8),MIN([YearMonth]*100+1))))
FROM #CNT_sup_Data
WHERE (Cnt_Rows_with_Participation+Cnt_Rows_with_Supplier)<(Cnt_Rows_in_billing+Cnt_Rows_in_billing_in_sales+Cnt_Rows_in_sellin+Cnt_Rows_in_supplier_list)
AND ISNULL(Cnt_Rows_in_billing,0)>0
AND ISNULL(Cnt_Rows_in_billing_in_sales,0)>0
AND ISNULL(Cnt_Rows_in_sellin,0)>0
AND ISNULL(Cnt_Rows_in_supplier_list,0)>0

--Set additional parameters
SET @run_date = CONVERT(date,GETDATE())
IF @run_nr IS NULL
    SET @run_nr = (SELECT MAX(run_nr) FROM PG_update_log);

IF (@start_date_1_5 IS NOT NULL AND @end_date_1_5 IS NOT NULL)
	BEGIN
		
		INSERT INTO PG_update_log
		VALUES(	@run_nr,
				@run_date,
				-1,
				4,
				'Start update procedure with current data we have',
				SYSDATETIME()
			)

		EXEC	Supplier_update_0a_transform_billing
					@run_nr,1, @run_date

		EXEC	Supplier_update_0b_transform_billing_in_sales
					@run_nr,7, @run_date

		EXEC	Supplier_update_0c_transform_Participation_suppliers
					@run_nr,13, @run_date

		EXEC	Supplier_update_0d_transform_purchase_discount
					@run_nr,18, @run_date

		EXEC	Supplier_update_1a_Update_supplier_list
					@run_nr,1, @run_date

		EXEC	Supplier_update_1b_Update_supplier_distributions
					@run_nr,10, @run_date, @start_date_1_5, @end_date_1_5

		EXEC	Supplier_update_2_Update_Retro_effects
					@run_nr,1, @run_date, @start_date_1_5, @end_date_1_5, @after_days

		EXEC	Supplier_update_3_Supplier_RAS
					@run_nr,1, @run_date, @start_date_1_5, @end_date_1_5

		INSERT INTO PG_update_log
		VALUES(	@run_nr,
				@run_date,
				3,
				14,
				'RAS data was updated with current data we have, SUGGESTION: VALIDATE',
				SYSDATETIME()
			)

	END
ELSE 
	BEGIN
		INSERT INTO PG_update_log
		VALUES(	@run_nr,
				@run_date,
				3,
				1,
				'All RAS data is up to date with current data we have',
				SYSDATETIME()
			)
	END

EXEC	Supplier_update_4_create_fact_performance
		  @run_nr, @run_date

INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			5,
			1,
			'End of the supplier update',
			SYSDATETIME()
		)

END