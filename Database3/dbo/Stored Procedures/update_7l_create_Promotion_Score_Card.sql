


-- =============================================
-- Author:		Gal Nachmani & Matan Marudi
-- Create date:	2018-08-19
-- Description:	...
-- =============================================
CREATE PROCEDURE [dbo].[update_7l_create_Promotion_Score_Card]
--variables
 @end_date Date='2018-08-27',
 @run_nr INT = 1,
 @run_date DATE = '2017-10-09',
 @step INT = 1

AS
BEGIN

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Start of [update_7l_create_Promotion_Score_Card]',
			SYSDATETIME()
		)
--calculte variables
Declare @Y2D date = DATEADD(yy, DATEDIFF(yy, 0, @end_date), 0)
Declare @StartDatePrevYear Date =DATEADD(yy, DATEDIFF(yy, 0, @end_date)-1, 0)
Declare @end_datePrevYear Date =DATEADD(yy, DATEDIFF(yy, 0, @end_date), -1)
Declare @Q2D date = DATEADD(q, DATEDIFF(q, 0, @end_date), 0)
Declare @M2D date = DATEADD(m, DATEDIFF(m, 0, @end_date), 0)
Declare @LMStartDate date =  DATEADD(m, DATEDIFF(m, 0, @end_date)-1, 0)
Declare @LMFinishDate date = DATEADD(m, DATEDIFF(m, 0, @end_date), -1)
Declare @LWStartDate date =DATEADD(WW, DATEDIFF(WW, 0, @end_date)-1, 0)
Declare @LWFinishDate date =DATEADD(WW, DATEDIFF(WW, 0, @end_date), -1)

--input_ras + convert date table
IF OBJECT_ID('tempdb..#Convert_dates_input_ras' ,'U') IS NOT NULL
    DROP TABLE #Convert_dates_input_ras;
select * 
into #Convert_dates_input_ras
from (select * from PG_input_RAS where TransactionDate>=@StartDatePrevYear and TransactionDate <=@end_datePrevYear) as ras 
left join Staging_DatesConversion as M on M.convertTo=ras.TransactionDate


--TOTALS FOR CATEGORY LastYear YTD
IF OBJECT_ID('tempdb..#tempLastYearYTD' ,'U') IS NOT NULL
    DROP TABLE #tempLastYearYTD;
SELECT 
Group_name_HE					   as Group_name_HE
,Category_name_HE				   as Category_name_HE
,Subdepartment_name_HE			   as Subdepartment_name_HE
,Department_name_HE					as Department_name_HE
,SUM(Revenue_1_promotion)		   as r1_promotion_LastYear
,SUM(Revenue_value_effect)		   as Revenue_value_effect_LastYear
,SUM(Margin_1_promotion)		   as m1_promotion_LastYear
,SUM(Margin_value_effect)		   as Margin_value_effect_LastYear
,SUM(case when (convertFrom>=@Y2D and convertFrom <=@end_date) then Revenue_1_promotion else 0 end)		   as YTD_r1_promotion_LastYear
,SUM(case when (convertFrom>=@Y2D and convertFrom <=@end_date) then Revenue_value_effect else 0 end)		   as YTD_Revenue_value_effect_LastYear
,SUM(case when (convertFrom>=@Y2D and convertFrom <=@end_date) then Margin_1_promotion else 0 end)		   as YTD_m1_promotion_LastYear
,SUM(case when (convertFrom>=@Y2D and convertFrom <=@end_date) then Margin_value_effect else 0 end)		   as YTD_Margin_value_effect_LastYear
,SUM(case when (convertFrom>=@Q2D and convertFrom <=@end_date) then Revenue_1_promotion else 0 end)		   as QTD_r1_promotion_LastYear
,SUM(case when (convertFrom>=@Q2D and convertFrom <=@end_date) then Revenue_value_effect else 0 end)		   as QTD_Revenue_value_effect_LastYear
,SUM(case when (convertFrom>=@Q2D and convertFrom <=@end_date) then Margin_1_promotion else 0 end)		       as QTD_m1_promotion_LastYear
,SUM(case when (convertFrom>=@Q2D and convertFrom <=@end_date) then Margin_value_effect else 0 end)		   as QTD_Margin_value_effect_LastYear
,SUM(case when (convertFrom>=@M2D and convertFrom <=@end_date) then Revenue_1_promotion else 0 end)		   as MTD_r1_promotion_LastYear
,SUM(case when (convertFrom>=@M2D and convertFrom <=@end_date) then Revenue_value_effect else 0 end)		   as MTD_Revenue_value_effect_LastYear
,SUM(case when (convertFrom>=@M2D and convertFrom <=@end_date) then Margin_1_promotion else 0 end)		       as MTD_m1_promotion_LastYear
,SUM(case when (convertFrom>=@M2D and convertFrom <=@end_date) then Margin_value_effect else 0 end)		   as MTD_Margin_value_effect_LastYear
,SUM(case when (convertFrom>=@LMStartDate and convertFrom <=@LMFinishDate) then Revenue_1_promotion else 0 end)		   as LM_r1_promotion_LastYear
,SUM(case when (convertFrom>=@LMStartDate and convertFrom <=@LMFinishDate) then Revenue_value_effect else 0 end)		   as LM_Revenue_value_effect_LastYear
,SUM(case when (convertFrom>=@LMStartDate and convertFrom <=@LMFinishDate) then Margin_1_promotion else 0 end)		       as LM_m1_promotion_LastYear
,SUM(case when (convertFrom>=@LMStartDate and convertFrom <=@LMFinishDate) then Margin_value_effect else 0 end)		   as LM_Margin_value_effect_LastYear
,SUM(case when (convertFrom>=@LWStartDate and convertFrom <=@LWFinishDate) then Revenue_1_promotion else 0 end)		   as LW_r1_promotion_LastYear
,SUM(case when (convertFrom>=@LWStartDate and convertFrom <=@LWFinishDate) then Revenue_value_effect else 0 end)		   as LW_Revenue_value_effect_LastYear
,SUM(case when (convertFrom>=@LWStartDate and convertFrom <=@LWFinishDate) then Margin_1_promotion else 0 end)		       as LW_m1_promotion_LastYear
,SUM(case when (convertFrom>=@LWStartDate and convertFrom <=@LWFinishDate) then Margin_value_effect else 0 end)		   as LW_Margin_value_effect_LastYear
INTO #tempLastYearYTD
FROM #Convert_dates_input_ras
GROUP BY Group_name_HE
,Category_name_HE				 
,Subdepartment_name_HE			   
,Department_name_HE	


--TOTALS FOR CATEGORY CurrentYear YTD
IF OBJECT_ID('tempdb..#tempCurrentYearYTD' ,'U') IS NOT NULL
    DROP TABLE #tempCurrentYearYTD;
SELECT 
Group_name_HE					   as Group_name_HE
,Category_name_HE				   as Category_name_HE
,Subdepartment_name_HE			   as Subdepartment_name_HE
,Department_name_HE				   as Department_name_HE
,SUM(Revenue_1_promotion)		   as YTD_r1_promotion_CurrentYear
,SUM(Revenue_value_effect)		   as YTD_Revenue_value_effect_CurrentYear
,SUM(Margin_1_promotion)		   as YTD_m1_promotion_CurrentYear
,SUM(Margin_value_effect)		   as YTD_Margin_value_effect_CurrentYear
,SUM(case when TransactionDate>=@Q2D then Revenue_1_promotion else 0 end)		   as QTD_r1_promotion_CurrentYear
,SUM(case when TransactionDate>=@Q2D then Revenue_value_effect else 0 end)		   as QTD_Revenue_value_effect_CurrentYear
,SUM(case when TransactionDate>=@Q2D then Margin_1_promotion else 0 end)		       as QTD_m1_promotion_CurrentYear
,SUM(case when TransactionDate>=@Q2D then Margin_value_effect else 0 end)		   as QTD_Margin_value_effect_CurrentYear
,SUM(case when TransactionDate>=@M2D then Revenue_1_promotion else 0 end)		   as MTD_r1_promotion_CurrentYear
,SUM(case when TransactionDate>=@M2D then Revenue_value_effect else 0 end)		   as MTD_Revenue_value_effect_CurrentYear
,SUM(case when TransactionDate>=@M2D then Margin_1_promotion else 0 end)		       as MTD_m1_promotion_CurrentYear
,SUM(case when TransactionDate>=@M2D then Margin_value_effect else 0 end)		   as MTD_Margin_value_effect_CurrentYear
,SUM(case when datepart(month,transactionDate)=datepart(month,@LMStartDate) then Revenue_1_promotion else 0 end)		   as LM_r1_promotion_CurrentYear
,SUM(case when datepart(month,transactionDate)=datepart(month,@LMStartDate) then Revenue_value_effect else 0 end)		   as LM_Revenue_value_effect_CurrentYear
,SUM(case when datepart(month,transactionDate)=datepart(month,@LMStartDate) then Margin_1_promotion else 0 end)		       as LM_m1_promotion_CurrentYear
,SUM(case when datepart(month,transactionDate)=datepart(month,@LMStartDate) then Margin_value_effect else 0 end)		   as LM_Margin_value_effect_CurrentYear
,SUM(case when datepart(WEEK,transactionDate)=datepart(WEEK,@LWStartDate) then Revenue_1_promotion else 0 end)		   as LW_r1_promotion_CurrentYear
,SUM(case when datepart(WEEK,transactionDate)=datepart(WEEK,@LWStartDate) then Revenue_value_effect else 0 end)		   as LW_Revenue_value_effect_CurrentYear
,SUM(case when datepart(WEEK,transactionDate)=datepart(WEEK,@LWStartDate) then Margin_1_promotion else 0 end)		       as LW_m1_promotion_CurrentYear
,SUM(case when datepart(WEEK,transactionDate)=datepart(WEEK,@LWStartDate) then Margin_value_effect else 0 end)		   as LW_Margin_value_effect_CurrentYear
,@end_date as EndDate
INTO #tempCurrentYearYTD
FROM PG_input_RAS
WHERE TransactionDate>=@Y2D AND TransactionDate<=@end_date
GROUP BY Group_name_HE
,Category_name_HE				 
,Subdepartment_name_HE			   
,Department_name_HE	


--Merge the tables
IF OBJECT_ID('tempdb..#ByCategory1' ,'U') IS NOT NULL
    DROP TABLE #ByCategory1;
SELECT  
ISNULL(ISNULL(td7.Group_name_HE,td7.Group_name_HE),td8.Group_name_HE) as Group_name_HE
,ISNULL(ISNULL(td7.Category_name_HE,td7.Category_name_HE),td8.Category_name_HE) as Category_name_HE
,ISNULL(ISNULL(td7.Subdepartment_name_HE,td7.Subdepartment_name_HE),td8.Subdepartment_name_HE) as Subdepartment_name_HE
,ISNULL(ISNULL(td7.department_name_HE,td7.department_name_HE),td8.department_name_HE) as department_name_HE
,td8.YTD_r1_promotion_CurrentYear 
,td8.YTD_Revenue_value_effect_CurrentYear
,td8.YTD_m1_promotion_CurrentYear
,td8.YTD_Margin_value_effect_CurrentYear
,td8.QTD_r1_promotion_CurrentYear 
,td8.QTD_Revenue_value_effect_CurrentYear
,td8.QTD_m1_promotion_CurrentYear
,td8.QTD_Margin_value_effect_CurrentYear
,td8.MTD_r1_promotion_CurrentYear
,td8.MTD_Revenue_value_effect_CurrentYear
,td8.MTD_m1_promotion_CurrentYear
,td8.MTD_Margin_value_effect_CurrentYear
,td8.LM_r1_promotion_CurrentYear
,td8.LM_Revenue_value_effect_CurrentYear
,td8.LM_m1_promotion_CurrentYear
,td8.LM_Margin_value_effect_CurrentYear
,td8.LW_r1_promotion_CurrentYear
,td8.LW_Revenue_value_effect_CurrentYear
,td8.LW_m1_promotion_CurrentYear
,td8.LW_Margin_value_effect_CurrentYear
,td7.[r1_promotion_LastYear]				 as r1_promotion_LastYear
,td7.[Revenue_value_effect_LastYear]		 as Revenue_value_effect_LastYear
,td7.[YTD_Revenue_value_effect_LastYear] as YTD_Revenue_value_effect_LastYear
,td7.[QTD_Revenue_value_effect_LastYear]		 as QTD_Revenue_value_effect_LastYear
,td7.[MTD_Revenue_value_effect_LastYear]		 as MTD_Revenue_value_effect_LastYear
,td7.[LM_Revenue_value_effect_LastYear]		 as LM_Revenue_value_effect_LastYear
,td7.[LW_Revenue_value_effect_LastYear]		 as LW_Revenue_value_effect_LastYear
,td7.[m1_promotion_LastYear]				 as m1_promotion_LastYear
,td7.[Margin_value_effect_LastYear]			 as Margin_value_effect_LastYear
,td7.[YTD_Margin_value_effect_LastYear]		 as YTD_Margin_value_effect_LastYear
,td7.[QTD_Margin_value_effect_LastYear]		 as QTD_Margin_value_effect_LastYear
,td7.[MTD_Margin_value_effect_LastYear]		 as MTD_Margin_value_effect_LastYear
,td7.[LM_Margin_value_effect_LastYear]		 as LM_Margin_value_effect_LastYear
,td7.[LW_Margin_value_effect_LastYear]		 as LW_Margin_value_effect_LastYear
,@end_date as EndDate 
INTO #ByCategory1
FROM #tempLastYearYTD td7 
FULL JOIN #tempCurrentYearYTD td8
ON td7.Group_name_HE = td8.Group_name_HE 
and td7.Category_name_HE = td8.Category_name_HE
and td7.Subdepartment_name_HE = td8.Subdepartment_name_HE
and td7.department_name_HE = td8.department_name_HE 


--Adding group numbers - very fragile because we're not sure about which files to use. what goes through updates and what is not.

--******order the table from last entry to first*********
IF OBJECT_ID('tempdb..#Staging_assortment_product_ordered' ,'U') IS NOT NULL
    DROP TABLE #Staging_assortment_product_ordered;
select *
into #Staging_assortment_product_ordered
from Staging_assortment_product
order by run_date desc

IF OBJECT_ID('tempdb..#ByCategory1_5' ,'U') IS NOT NULL
    DROP TABLE #ByCategory1_5;
select t1.*,
		(SELECT Top 1 t2.Category_Manager_name_HE FROM #Staging_assortment_product_ordered t2
		WHERE t2.Group_name_HE=t1.Group_name_HE
and t2.Category_name_HE=t1.Category_name_HE
and t2.Subdepartment_name_HE=t1.Subdepartment_name_HE
and t2.Department_name_HE=t1.department_name_HE
		and t2.Category_Manager_name_HE is not null
		) AS Category_Manager_name_HE
into #ByCategory1_5
from #ByCategory1 t1
order by department_name_HE

IF OBJECT_ID('dbo.#TargetViewTable', 'U') IS NOT NULL
    DROP TABLE dbo.#TargetViewTable;
select    *
into dbo.#TargetViewTable
from #ByCategory1_5 

IF OBJECT_ID('dbo.#TargetViewTable_w_group_num', 'U') IS NOT NULL
    DROP TABLE dbo.#TargetViewTable_w_group_num;
select t1.*,
		(SELECT Top 1 t2.[Group] FROM #Staging_assortment_product_ordered t2
		WHERE t2.Group_name_HE=t1.Group_name_HE
and t2.Category_name_HE=t1.Category_name_HE
		and t2.[group] is not null
		) AS Group_num
into #TargetViewTable_w_group_num
from dbo.#TargetViewTable t1
order by department_name_HE





--*****************************Adding Target + cat _id **************************************

IF OBJECT_ID('dbo.#TargetViewTable_w_group_num', 'U') IS NOT NULL
    DROP TABLE dbo.#TargetViewTable_w_group_num;
select GN.*
,MM.[rev_growth_ambition ] as Revenue_target_groth
,MM.Target_rev_ve as Revenue_target
,MM.growth_margin_ambition as Margin_target_groth
,MM.Target_mrg_ve as Margin_target
,cats_id.cat_id
into #TargetViewTable_w_group_num_finale
from #TargetViewTable_w_group_num as GN
left join Staging_targets_import as MM on GN.Group_num=MM.Group_id
left join (select Category_name_HE,department_name_HE ,ROW_NUMBER() over (order by Category_name_HE,department_name_HE)  as cat_id
from #ByCategory1
group by department_name_HE,Category_name_HE )  as cats_id
on cats_id.Category_name_HE=GN.Category_name_HE 
and cats_id.department_name_HE=gn.department_name_HE

--*****************************Adding time column **************************************
IF OBJECT_ID('dbo.PG_Promotion_Score_Card', 'U') IS NOT NULL
    DROP TABLE dbo.PG_Promotion_Score_Card;
 SELECT Group_name_HE
      ,Category_name_HE
	  ,cat_id
      ,Subdepartment_name_HE
      ,department_name_HE
	  ,EndDate
      ,Category_Manager_name_HE
      ,Group_num
      ,Revenue_target
	  ,Revenue_target_groth
      ,Margin_target
	  ,Margin_target_groth
	  ,Revenue_value_effect_LastYear as Revenue_value_effect_LastYear_fullyear
	  ,Margin_value_effect_LastYear as Margin_value_effect_LastYear_full_year
	  ,YTD_r1_promotion_CurrentYear as r1_promotion
      ,YTD_Revenue_value_effect_CurrentYear as Revenue_value_effect
      ,YTD_m1_promotion_CurrentYear as m1_promotion
	  ,YTD_Margin_value_effect_CurrentYear as Margin_value_effect
	  ,YTD_Revenue_value_effect_LastYear as Revenue_value_effect_LY
	  ,YTD_Margin_value_effect_LastYear as Margin_value_effect_LY
	  ,'year-to-date' as [time]
into PG_Promotion_Score_Card
FROM   #TargetViewTable_w_group_num_finale
union 
--ADD Q2D
 SELECT Group_name_HE
      ,Category_name_HE
	  ,cat_id
      ,Subdepartment_name_HE
      ,department_name_HE
	  ,EndDate
      ,Category_Manager_name_HE
      ,Group_num
      ,Revenue_target
	  ,Revenue_target_groth
      ,Margin_target
	  ,Margin_target_groth
	  ,Revenue_value_effect_LastYear as Revenue_value_effect_LastYear_fullyear
	  ,Margin_value_effect_LastYear as Margin_value_effect_LastYear_full_year
	  ,[QTD_r1_promotion_CurrentYear] as r1_promotion
	  ,[QTD_Revenue_value_effect_CurrentYear] as Revenue_value_effect
	  ,[QTD_m1_promotion_CurrentYear] as m1_promotion
      ,[QTD_Margin_value_effect_CurrentYear] as Margin_value_effect
	  ,[QTD_Revenue_value_effect_LastYear] as Revenue_value_effect_LY
	  ,[QTD_Margin_value_effect_LastYear] as Margin_value_effect_LY
	  ,'quarter-to-date' as [time]
FROM   #TargetViewTable_w_group_num_finale
--ADD M2D
union 
 SELECT Group_name_HE
      ,Category_name_HE
	  ,cat_id
      ,Subdepartment_name_HE
      ,department_name_HE
	  ,EndDate
      ,Category_Manager_name_HE
      ,Group_num
      ,Revenue_target
	  ,Revenue_target_groth
      ,Margin_target
	  ,Margin_target_groth
	  ,Revenue_value_effect_LastYear as Revenue_value_effect_LastYear_fullyear
	  ,Margin_value_effect_LastYear as Margin_value_effect_LastYear_full_year
	  ,[MTD_r1_promotion_CurrentYear]as r1_promotion
      ,[MTD_Revenue_value_effect_CurrentYear] as Revenue_value_effect
      ,[MTD_m1_promotion_CurrentYear] as m1_promotion
      ,[MTD_Margin_value_effect_CurrentYear] as Margin_value_effect
	  ,[MTD_Revenue_value_effect_LastYear] as Revenue_value_effect_LY
      ,[MTD_Margin_value_effect_LastYear] as Margin_value_effect_LY
	  ,'month-to-date' as [time]
FROM   #TargetViewTable_w_group_num_finale
--ADD LM
union 
 SELECT Group_name_HE
      ,Category_name_HE
	  ,cat_id
      ,Subdepartment_name_HE
      ,department_name_HE
	  ,EndDate
      ,Category_Manager_name_HE
      ,Group_num
      ,Revenue_target
	  ,Revenue_target_groth
      ,Margin_target
	  ,Margin_target_groth
	  ,Revenue_value_effect_LastYear as Revenue_value_effect_LastYear_fullyear
	  ,Margin_value_effect_LastYear as Margin_value_effect_LastYear_full_year
	  ,[LM_r1_promotion_CurrentYear] as r1_promotion
      ,[LM_Revenue_value_effect_CurrentYear] as Revenue_value_effect
      ,[LM_m1_promotion_CurrentYear] as m1_promotion
      ,[LM_Margin_value_effect_CurrentYear] as Margin_value_effect
	  ,[LM_Revenue_value_effect_LastYear] as Revenue_value_effect_LY
      ,[LM_Margin_value_effect_LastYear] as Margin_value_effect_LY
	  ,'last-month' as [time]
FROM   #TargetViewTable_w_group_num_finale
--ADD LW
union 
 SELECT Group_name_HE
      ,Category_name_HE
	  ,cat_id
      ,Subdepartment_name_HE
      ,department_name_HE
	  ,EndDate
      ,Category_Manager_name_HE
      ,Group_num
      ,Revenue_target
	  ,Revenue_target_groth
      ,Margin_target
	  ,Margin_target_groth
	  ,Revenue_value_effect_LastYear as Revenue_value_effect_LastYear_fullyear
	  ,Margin_value_effect_LastYear as Margin_value_effect_LastYear_full_year
	  ,[LW_r1_promotion_CurrentYear] AS  r1_promotion
      ,[LW_Revenue_value_effect_CurrentYear] as Revenue_value_effect
      ,[LW_m1_promotion_CurrentYear] as m1_promotion
      ,[LM_Margin_value_effect_CurrentYear] as Margin_value_effect
      ,[LW_Revenue_value_effect_LastYear] as Revenue_value_effect_LY
      ,[LW_Margin_value_effect_LastYear]  as Margin_value_effect_LY
	  ,'last-week' as [time]
FROM   #TargetViewTable_w_group_num_finale


SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'End of [update_7l_create_Promotion_Score_Card]',
			SYSDATETIME()
		)

drop table #ByCategory1
drop table #ByCategory1_5
drop table #Convert_dates_input_ras
drop table #Staging_assortment_product_ordered
drop table #TargetViewTable
drop table #TargetViewTable_w_group_num_finale
drop table #tempCurrentYearYTD
drop table #tempLastYearYTD

END
