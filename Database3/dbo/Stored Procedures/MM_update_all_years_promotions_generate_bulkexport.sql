-- =============================================
-- Author:		Matan Marudi
-- Create date:	2018-12-31
-- Description:	Generates output tables for Shufersal DWG
-- =============================================
CREATE PROCEDURE [dbo].[MM_update_all_years_promotions_generate_bulkexport]
	@run_nr INT = 165,
	@run_date DATE = '2018-12-31',
	@step INT = 1,
	@start_date DATE = '2017-01-01',
	@end_date DATE = '2017-12-31',
	@bound_revenue FLOAT = 50000,
	@upper_bound_margin INT = 15000,
	@lower_bound_margin INT = 0,
	@after_days INT = 28
	--[PG_bulkexport_weekly_drop]
AS
BEGIN

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Start of [update_7m_ROI_promotions_generate_bulkexport]',
			SYSDATETIME()
		)


-- Calculates promotion segments
IF OBJECT_ID('tempdb.dbo.#ROI_result_promotion_segments','U') IS NOT NULL
    DROP TABLE #ROI_result_promotion_segments
;WITH CTE AS
(select  Case when len(PromotionNumber) >8 then left(PromotionNumber,len(PromotionNumber)-3) else PromotionNumber END PromotionNumberOriginal,
Branch_name_EN,
PromotionCharacteristicsType,
		  SUM(Revenue_1_promotion) Revenue_1_promotion,
		  SUM(Revenue_value_effect) AS 'Revenue_value_effect',
		  SUM(Margin_value_effect) AS 'Margin_value_effect'
from PG_input_RAS
group by Case when len(PromotionNumber) >8 then left(PromotionNumber,len(PromotionNumber)-3) else PromotionNumber END
,Branch_name_EN,PromotionCharacteristicsType
)
SELECT	  cte.PromotionNumberOriginal,PromotionCharacteristicsType,
		  CASE WHEN SUM(Revenue_1_promotion)=0 
			    THEN '9.Zero revenue'
			  WHEN SUM(Revenue_value_effect) >= SUM(br.Multiplier_percentage*@bound_revenue) AND SUM(Margin_value_effect) >= SUM(br.Multiplier_percentage*@upper_bound_margin)
				THEN '1. Winner'
			  WHEN SUM(Revenue_value_effect) < SUM(br.Multiplier_percentage*@bound_revenue) AND SUM(Margin_value_effect) >= SUM(br.Multiplier_percentage*@upper_bound_margin)
				THEN '2. Diamond'
			  WHEN SUM(Revenue_value_effect) >= SUM(br.Multiplier_percentage*@bound_revenue) AND SUM(Margin_value_effect) >= SUM(br.Multiplier_percentage*@lower_bound_margin)
				THEN '3. Potential winner'
			  WHEN SUM(Revenue_value_effect) < SUM(br.Multiplier_percentage*@bound_revenue) AND SUM(Margin_value_effect) >= SUM(br.Multiplier_percentage*@lower_bound_margin)
				THEN '4. Grey herd'
			  WHEN SUM(Revenue_value_effect) >= SUM(br.Multiplier_percentage*@bound_revenue) AND SUM(Margin_value_effect) < SUM(br.Multiplier_percentage*@lower_bound_margin)
				THEN '5. Bleeder'
			  WHEN SUM(Revenue_value_effect) < SUM(br.Multiplier_percentage*@bound_revenue) AND SUM(Margin_value_effect) < SUM(br.Multiplier_percentage*@lower_bound_margin)
				THEN '6. Margin killer'
		  END AS 'Promotion_segment'
INTO		  #ROI_result_promotion_segments
FROM		  CTE cte
LEFT JOIN	  PG_branch_revenue_percentages br
ON		  cte.Branch_name_EN = br.Branch_name_EN
GROUP BY	  cte.PromotionNumberOriginal,cte.PromotionCharacteristicsType


-- add segments IDs
IF OBJECT_ID('tempdb.dbo.#ROI_result_promotion_segments_id','U') IS NOT NULL
    DROP TABLE #ROI_result_promotion_segments_id
select *
into #ROI_result_promotion_segments_id
from #ROI_result_promotion_segments ir
LEFT JOIN [dbo].[ReleaseX_SegmentID] segid ON ir.Promotion_segment = segid.NAME


-- Generates bulkexport
--into PG_bulkexport__weekly_drop
--IF OBJECT_ID('tempdb.dbo.#ras_temp','U') IS NOT NULL
--    DROP TABLE #ras_temp

select 
getdate() as export_date
,case when min(PromotionNumber)=max(PromotionNumber) then max(PromotionNumber) else null end  as PromotionNumber 
,Case when len(ir.PromotionNumber) >8 then left(ir.PromotionNumber,len(ir.PromotionNumber)-3) else ir.PromotionNumber END PromotionNumberOriginal
,case when max(PromotionNumberUnv)=min(PromotionNumberUnv)  then max(PromotionNumberUnv) else null end as PromotionNumberUnv
,ir.PromotionCharacteristicsType
,case when max(PromotionStartDate)=min(PromotionStartDate) then max(PromotionStartDate) else '1900-01-01' end as PromotionStartDate
,case when max(PromotionEndDate)=min(PromotionEndDate) then min (PromotionEndDate) else '1900-01-01' end as PromotionEndDate
,case when max(PromotionEndDate)=min(PromotionEndDate) and max(PromotionStartDate)=min(PromotionStartDate) then DATEDIFF(day,min(PromotionStartDate),max(PromotionEndDate))+1 
else null end AS 'Length'
,ProductNumber
,TransactionDate
,bid.ID
,SourceInd
,case when min(ptid.ID)=max(ptid.ID) then min(ptid.ID) else null end  as Promotion_type_id
,sum(Multibuy_quantity) as Multibuy_quantity
,case when min(pid.ID)=max(pid.ID)then min(pid.ID) else null end as Place_in_store_id
,case when max(Folder)=min(Folder) then max(Folder) else null end   as Folder
,cast (sum(Real_quantity) as decimal(14,2)) as Real_quantity
,cast (sum(Baseline_quantity) as decimal(14,2)) as Baseline_quantity
,CASE WHEN sum(Baseline_quantity) = 0 THEN NULL
	  ELSE  cast ( sum(Real_quantity)/sum(Baseline_quantity) as decimal(14,2)) END  as Uplift 
,cast (sum(Revenue_1_promotion) as decimal(14,2)) as Revenue_1_promotion 
,cast (sum(Revenue_2_subs_promo) as decimal(14,2)) as Revenue_2_subs_promo
,cast (sum(Revenue_3_subs_group) as decimal(14,2)) as Revenue_3_subs_group
,cast (sum(Revenue_4_promobuyer_existing) as decimal(14,2)) as Revenue_4_promobuyer_existing
,cast (sum(Revenue_5_promobuyer_new) as decimal(14,2)) as Revenue_5_promobuyer_new
,cast (sum(Revenue_6_new_customer) as decimal(14,2)) as Revenue_6_new_customer 
,cast (sum(Revenue_7_product_adoption) as decimal(14,2)) as Revenue_7_product_adoption
,cast (sum(Revenue_8_hoarding) as decimal(14,2)) as Revenue_8_hoarding
,cast (sum(Revenue_value_effect) as decimal(14,2)) as Revenue_value_effect
,cast (sum(Margin_1_promotion) as decimal(14,2)) as Margin_1_promotion
,cast (sum(Margin_2_subs_promo) as decimal(14,2)) as Margin_2_subs_promo
,cast (sum(Margin_3_subs_group) as decimal(14,2)) as Margin_3_subs_group
,cast (sum(Margin_4_promobuyer_existing) as decimal(14,2)) as Margin_4_promobuyer_existing
,cast (sum(Margin_5_promobuyer_new) as decimal(14,2)) as Margin_5_promobuyer_new
,cast (sum(Margin_6_new_customer) as decimal(14,2)) as Margin_6_new_customer
,cast (sum(Margin_7_product_adoption) as decimal(14,2)) as Margin_7_product_adoption
,cast (sum(Margin_8_hoarding) as decimal(14,2)) as Margin_8_hoarding
,cast (sum(Margin_value_effect) as decimal(14,2)) as Margin_value_effect
,case when min(segid.ID)=max(segid.ID) then max(segid.ID) else null end as Promotion_segment_id
,cast (CASE WHEN sum(Real_quantity)= 0 THEN 0
		ELSE sum(Revenue_1_promotion)/sum(Real_quantity) END as decimal(10,2)) AS 'Promotion_price_per_product'
,cast (CASE WHEN sum(Baseline_quantity) = 0 THEN 0
		ELSE SUM(-Revenue_2_subs_promo)/sum(Baseline_quantity) END as decimal(10,2)) AS 'Regular_price_per_product'
,cast (avg(Discount)as decimal(10,2))as  Discount
,CAST ( CASE WHEN sum(Real_quantity) = 0 THEN 0
		ELSE sum(Margin_1_promotion)/sum(Real_quantity) END as decimal(10,2)) AS 'Promotion_margin_per_product'
,CAST ( CASE WHEN sum(Baseline_quantity) = 0 THEN 0
		 ELSE sum(-Margin_2_subs_promo)/sum(Baseline_quantity) END as decimal(10,2)) AS 'Regular_margin_per_product'
		into #bulkexport_allyears
from pg_input_RAS ir
LEFT JOIN [dbo].[ReleaseX_BranchID] bid ON ir.Branch_name_EN = bid.NAME
LEFT JOIN [dbo].[ReleaseX_PromoType_ID] ptid ON ir.Promotion_type = ptid.NAME
LEFT JOIN [dbo].[ReleaseX_PlaceID] pid ON ir.Place_in_store = pid.NAME
LEFT JOIN #ROI_result_promotion_segments_id segid ON Case when len(ir.PromotionNumber) >8 then left(ir.PromotionNumber,len(ir.PromotionNumber)-3) else ir.PromotionNumber END = segid.promotionnumberoriginal
and (coalesce(ir.PromotionCharacteristicsType, -1) = coalesce(segid.PromotionCharacteristicsType, -1))
--WHERE TransactionDate >= @start_date and TransactionDate <= @end_date
--WHERE TransactionDate >= DATEADD(day,-@after_days,@start_date) and TransactionDate <= @end_date-- and ir.PromotionCharacteristicsType is not null
group by Case when len(ir.PromotionNumber) >8 then left(ir.PromotionNumber,len(ir.PromotionNumber)-3) else ir.PromotionNumber END
,ProductNumber,TransactionDate,SourceInd,bid.ID,ir.PromotionCharacteristicsType

truncate table PG_bulkexport_2015
truncate table PG_bulkexport_2016
truncate table PG_bulkexport_2017
truncate table PG_bulkexport_2018

insert into PG_bulkexport_2015
select * 
from #bulkexport_allyears
where year(TransactionDate)=2015

insert into PG_bulkexport_2016
select * 
from #bulkexport_allyears
where year(TransactionDate)=2016

insert into PG_bulkexport_2017
select * 
from #bulkexport_allyears
where year(TransactionDate)=2017

insert into PG_bulkexport_2018
select * 
from #bulkexport_allyears
where year(TransactionDate)=2018
SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'End of [update_7m_ROI_promotions_generate_bulkexport]',
			SYSDATETIME()
		)

END
