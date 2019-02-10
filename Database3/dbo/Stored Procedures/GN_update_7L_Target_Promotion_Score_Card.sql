
-- =============================================
-- Author:		Hagai and Gal
-- Create date:	2018-8-8
-- Description:	Generates input data for Promotion Score Card View
-- =============================================
CREATE PROCEDURE [dbo].[GN_update_7L_Target_Promotion_Score_Card]
    @run_nr INT = 1,
    @end_date DATE = '2018-07-20',
	@Start_date DATE = '2018-06-25',
    @step INT = 1
AS
BEGIN

DECLARE @LASTYEAR_start DATE = CAST(cast(Year(@Start_date)-1 as varchar) + '-01-01' AS DATE)
DECLARE @LASTYEAR_end DATE = CAST(cast(Year(@Start_date)-1 as varchar) + '-12-31' AS DATE)
DECLARE @RECENTYEAR_start DATE = CAST(cast(Year(@end_date) as varchar) + '-01-01' AS DATE)
DECLARE @LASTYEAR_thisDay Date = DATEADD(year, -2, @end_date);

--SET @step = @step + 1;
--INSERT INTO PG_update_log
--	VALUES(	@run_nr,
--			@run_date,
--			7,
--			@step,
--			'Start of [update_7L_Target_Promotion_Score_Card]',
--			SYSDATETIME()
--		)


--**************************************ADDING revenues from Input_RAS**************************************

--TOTALS FOR CATEGORY LastYear
IF OBJECT_ID('tempdb..#temp_LastYear' ,'U') IS NOT NULL
    DROP TABLE #temp_LastYear;
SELECT 
Group_name_HE					   as Group_name_HE
,Category_name_HE				   as Category_name_HE
,Subdepartment_name_HE			   as Subdepartment_name_HE
,Department_name_HE					as Department_name_HE
,SUM(Revenue_1_promotion)		   as r1_promotion_2017
,SUM(Revenue_value_effect)		   as Revenue_value_effect_2017
,SUM(Margin_1_promotion)		   as m1_promotion_2017
,SUM(Margin_value_effect)		   as Margin_value_effect_2017
INTO #temp_LastYear
FROM PG_input_RAS
WHERE TransactionDate>=@LASTYEAR_start AND TransactionDate<=@LASTYEAR_end
GROUP BY Group_name_HE
,Category_name_HE				 
,Subdepartment_name_HE			   
,Department_name_HE	



--TOTALS FOR CATEGORY LastYear YTD
IF OBJECT_ID('tempdb..#temp_LastYearYTD' ,'U') IS NOT NULL
    DROP TABLE #temp_LastYearYTD;
SELECT 
Group_name_HE					   as Group_name_HE
,Category_name_HE				   as Category_name_HE
,Subdepartment_name_HE			   as Subdepartment_name_HE
,Department_name_HE					as Department_name_HE
,SUM(Revenue_1_promotion)		   as YTD_r1_promotion_2017
,SUM(Revenue_value_effect)		   as YTD_Revenue_value_effect_2017
,SUM(Margin_1_promotion)		   as YTD_m1_promotion_2017
,SUM(Margin_value_effect)		   as YTD_Margin_value_effect_2017
INTO #temp_LastYearYTD
FROM PG_input_RAS
WHERE TransactionDate>=@LASTYEAR_start AND TransactionDate<=@LASTYEAR_thisDay
GROUP BY Group_name_HE
,Category_name_HE				 
,Subdepartment_name_HE			   
,Department_name_HE	

--TOTALS FOR CATEGORY RecentYear YTD
IF OBJECT_ID('tempdb..#temp_RecentYearYTD' ,'U') IS NOT NULL
    DROP TABLE #temp_RecentYearYTD;
SELECT 
Group_name_HE					   as Group_name_HE
,Category_name_HE				   as Category_name_HE
,Subdepartment_name_HE			   as Subdepartment_name_HE
,Department_name_HE				   as Department_name_HE
,SUM(Revenue_1_promotion)		   as YTD_r1_promotion_2018
,SUM(Revenue_value_effect)		   as YTD_Revenue_value_effect_2018
,SUM(Margin_1_promotion)		   as YTD_m1_promotion_2018
,SUM(Margin_value_effect)		   as YTD_Margin_value_effect_2018
INTO #temp_RecentYearYTD
FROM PG_input_RAS
WHERE TransactionDate>=@RECENTYEAR_start AND TransactionDate<=@end_date
GROUP BY Group_name_HE
,Category_name_HE				 
,Subdepartment_name_HE			   
,Department_name_HE	

--Add all of the tables
IF OBJECT_ID('tempdb..#ByCategory1' ,'U') IS NOT NULL
    DROP TABLE #ByCategory1;
SELECT  
ISNULL(ISNULL(y7.Group_name_HE,td7.Group_name_HE),td8.Group_name_HE) as Group_name_HE
,ISNULL(ISNULL(y7.Category_name_HE,td7.Category_name_HE),td8.Category_name_HE) as Category_name_HE
,ISNULL(ISNULL(y7.Subdepartment_name_HE,td7.Subdepartment_name_HE),td8.Subdepartment_name_HE) as Subdepartment_name_HE
,ISNULL(ISNULL(y7.department_name_HE,td7.department_name_HE),td8.department_name_HE) as department_name_HE
,y7.[r1_promotion_2017]				 as r1_promotion_2017
,y7.[Revenue_value_effect_2017]		 as Revenue_value_effect_2017
,td7.[YTD_Revenue_value_effect_2017] as YTD_Revenue_value_effect_2017
,td8.[YTD_Revenue_value_effect_2018]     as YTD_Revenue_value_effect_2018
,y7.[m1_promotion_2017]				 as m1_promotion_2017
,y7.[Margin_value_effect_2017]			 as Margin_value_effect_2017
,td7.[YTD_Margin_value_effect_2017]		 as YTD_Margin_value_effect_2017
,td8.[YTD_Margin_value_effect_2018]			 as YTD_Margin_value_effect_2018
INTO #ByCategory1
FROM #temp_LastYear y7 
FULL JOIN #temp_LastYearYTD td7 
ON y7.Group_name_HE = td7.Group_name_HE 
and y7.Category_name_HE = td7.Category_name_HE
and y7.Subdepartment_name_HE = td7.Subdepartment_name_HE
and y7.department_name_HE = td7.department_name_HE 
FULL JOIN #temp_RecentYearYTD td8
ON y7.Group_name_HE = td8.Group_name_HE 
and y7.Category_name_HE = td8.Category_name_HE
and y7.Subdepartment_name_HE = td8.Subdepartment_name_HE
and y7.department_name_HE = td8.department_name_HE 


IF OBJECT_ID('dbo.GN_TargetViewTable', 'U') IS NOT NULL
    DROP TABLE dbo.GN_TargetViewTable;
select    *
into dbo.GN_TargetViewTable
from #ByCategory1 

--*****************************Adding Target and Deltas for non-Time View***************************************

--Fictional target for now
IF OBJECT_ID('tempdb..#ByCategory2' ,'U') IS NOT NULL
    DROP TABLE #ByCategory2;
select t1.*,
		5 as Growth_perc_target,
		case when YTD_Revenue_value_effect_2017>0 then 105*t1.YTD_Revenue_value_effect_2017/100 
			 else YTD_Revenue_value_effect_2017+1000 --arbitrary
			 end as YTD_Target_rev_value_2018, 
		case when YTD_Margin_value_effect_2017>0 then 105*t1.YTD_Margin_value_effect_2017/100 
			 else YTD_Margin_value_effect_2017+1000 --arbitrary
			 end as YTD_Target_Marg_value_2018, 
		case when YTD_Revenue_value_effect_2017>0 then (YTD_Revenue_value_effect_2018-105*t1.YTD_Revenue_value_effect_2017/100)/(105*t1.YTD_Revenue_value_effect_2017/100)
			 when YTD_Revenue_value_effect_2017>-1000 then (YTD_Revenue_value_effect_2018-YTD_Revenue_value_effect_2017-1000)/(YTD_Revenue_value_effect_2017+1000)
			 else -(YTD_Revenue_value_effect_2018-YTD_Revenue_value_effect_2017-1000)/(YTD_Revenue_value_effect_2017+1000) --arbitrary
			 end as YTD_Target_rev_value_Delta, 
		case when YTD_Margin_value_effect_2017>0 then (YTD_Margin_value_effect_2018-105*t1.YTD_Margin_value_effect_2017/100)/(105*t1.YTD_Margin_value_effect_2017/100) 
			 when YTD_Margin_value_effect_2017>-1000 then (YTD_Margin_value_effect_2018-YTD_Margin_value_effect_2017-1000)/(YTD_Margin_value_effect_2017+1000) --arbitrary
			 else -(YTD_Margin_value_effect_2018-YTD_Margin_value_effect_2017-1000)/(YTD_Margin_value_effect_2017+1000)
			 end as YTD_Target_Marg_value_Delta
into #ByCategory2
from dbo.GN_TargetViewTable t1

--SET @step = @step + 1;
--INSERT INTO PG_update_log
--	VALUES(	@run_nr,
--			@run_date,
--			7,
--			@step,
--			'End of [update_7L_Target_Promotion_Score_Card]',
--			SYSDATETIME()
--		)

END

