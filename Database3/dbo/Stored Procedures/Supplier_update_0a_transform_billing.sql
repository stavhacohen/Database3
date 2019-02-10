-- =============================================
-- Author:		Matan Marudi & Hagai Weiss
-- Create date:	2018-12-18
-- Description:	Transforms Sell-Out promotions
-- =============================================
CREATE PROCEDURE [dbo].[Supplier_update_0a_transform_billing]
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
			'Start of [Supplier_update_0a_transform_billing]',
			SYSDATETIME()
		)

SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'Insert data to update table [Staging_supplier_billing_update]',
			SYSDATETIME()
		)

/* STEP 1: Transform data type and insert to update table */
TRUNCATE TABLE Shufersal.dbo.Staging_supplier_billing_update
-- Transforms promotion file
INSERT INTO Shufersal.dbo.Staging_supplier_billing_update
SELECT	  DISCOUNT_ID,
	DISCOUNT_DESC,
	cast (CONCAT (left([DATE_FROM],4),'-',right(left([DATE_FROM],6),2),'-',RIGHT([DATE_FROM],2)) AS date ) DATE_FROM,
	cast (CONCAT (left([DATE_TO],4),'-',right(left([DATE_TO],6),2),'-',RIGHT([DATE_TO],2)) AS date ) DATE_TO,
	SUPPLIER_ID,
	SUPPLIER_NAME,
	[MONTH],
	FORMAT_ID,
	FORMAT_NAME,
	TRY_CONVERT ( decimal (10,2),TOTAL_SALES) TOTAL_SALES,
	TRY_CONVERT ( decimal (10,2),[SUPPLIER_PARTICIPATION]) SUPPLIER_PARTICIPATION,
	GETDATE() import_date
FROM		  Shufersal.dbo.Staging_supplier_billing_import


--Truncate import table
TRUNCATE TABLE Shufersal.dbo.Staging_supplier_billing_import

SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'Insert data to history [Staging_supplier_billing]',
			SYSDATETIME()
		)

/* STEP 2: Move data to history file */
INSERT INTO Shufersal.dbo.Staging_supplier_billing
SELECT	  DISCOUNT_ID,
	DISCOUNT_DESC,
	DATE_FROM,
	DATE_TO,
	SUPPLIER_ID,
	SUPPLIER_NAME,
	[MONTH],
	FORMAT_ID,
	FORMAT_NAME,
	TOTAL_SALES,
	SUPPLIER_PARTICIPATION,
	import_date
FROM Shufersal.dbo.Staging_supplier_billing_update


/* STEP 3: Manipulation on update data */
--Fixing branches
IF OBJECT_ID('tempdb..#HW_SellOut_supplier_billing_TOT_Branchs') IS NOT NULL
    DROP TABLE #HW_SellOut_supplier_billing_TOT_Branchs
-- adding the translation+joining
select sb.*
, case when format_id=1 then 1
       when format_id=2 then 7
	   when format_id=4 then 5
	   when format_id=5 then 14 --New Pharm irrelevant
	   when format_id=6 then 8
	   when format_id=7 then 6
	   when format_id=8 then 2
	   when format_id=9 then 14 --Warehouse irrelevant
	   else  NULL  -- case -new unexpected values
	   end as Branch_ID_SARIT
into #HW_SellOut_supplier_billing_TOT_Branchs
from  Staging_supplier_billing_update sb

--creating sell out promotions with avg participation and branch_name_EN
IF OBJECT_ID('tempdb..#HW_SellOut_supplier_billing_TOT_Branchs_wAvg') IS NOT NULL
    DROP TABLE #HW_SellOut_supplier_billing_TOT_Branchs_wAvg
select sop.*,sb.Branch_name_EN
into #HW_SellOut_supplier_billing_TOT_Branchs_wAvg
from #HW_SellOut_supplier_billing_TOT_Branchs sop
 left join Staging_branches sb
 on sop.Branch_ID_SARIT=sb.Branch_ID

 --creating sell out products on a day level
IF OBJECT_ID('tempdb..#HW_SellOut_supplier_billing_TOT_Branchs_wAvg_day_level') IS NOT NULL
    DROP TABLE #HW_SellOut_supplier_billing_TOT_Branchs_wAvg_day_level
select a.*, dd.[date] as date0
into #HW_SellOut_supplier_billing_TOT_Branchs_wAvg_day_level
from #HW_SellOut_supplier_billing_TOT_Branchs_wAvg a
left join promotions.dim_date dd
on dd.[date] between cast(cast(a.DATE_FROM as varchar)as date) and cast(cast(a.DATE_TO as varchar)as date)
and format(dd.[date],'yyyyMM')  = a.[MONTH]

--creating PG update table
TRUNCATE TABLE Shufersal.dbo.PG_supplier_billing_update
INSERT INTO Shufersal.dbo.PG_supplier_billing_update
select  t.DISCOUNT_ID
	   ,t.Branch_name_EN
	   ,t.date0
	   ,t.SUPPLIER_ID
	   ,MAX(t.[MONTH]) as [MONTH]
	   ,MAX(t.SUPPLIER_NAME) as SUPPLIER_NAME
	   ,MAX(t.Branch_ID_SARIT) as FORMAT_ID_Sarit
	   ,SUM(isnull(t.TOTAL_SALES,0)) as TOTAL_SALES
	   ,SUM(isnull(t.SUPPLIER_PARTICIPATION,0)) as SUPPLIER_PARTICIPATION
	   ,case when SUM(isnull(t.TOTAL_SALES,0))=0 then SUM(isnull(t.SUPPLIER_PARTICIPATION,0))
			else SUM(isnull(t.SUPPLIER_PARTICIPATION,0))/SUM(isnull(t.TOTAL_SALES,0)) 
			end as avg_partic
from #HW_SellOut_supplier_billing_TOT_Branchs_wAvg_day_level t
group by t.DISCOUNT_ID
	   ,t.Branch_name_EN
	   ,t.date0
	   ,t.SUPPLIER_ID

SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'supplier_billing_in_sales transformed',
			SYSDATETIME()
		)

-- insert to PG historic table
INSERT INTO Shufersal.dbo.PG_supplier_billing
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
,GETDATE() import_date
FROM Shufersal.dbo.PG_supplier_billing_update


SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'supplier_billing_in_sales transfered to PG historic',
			SYSDATETIME()
		)


SET @step = @step + 1;
INSERT INTO PG_update_log_Supplier
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'End of [Supplier_update_0a_transform_billing]',
			SYSDATETIME()
		)

END
