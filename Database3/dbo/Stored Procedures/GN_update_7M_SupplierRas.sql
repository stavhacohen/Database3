
-- =============================================
-- Author:		Hagai and Gal
-- Create date:	2018-8-8
-- Description:	Generates input data for Promotion Score Card View
-- =============================================
CREATE PROCEDURE [dbo].[GN_update_7M_SupplierRas]
    @run_nr INT = 1,
    @end_date DATE = '2018-07-20',
	@Start_date DATE = '2018-06-25',
	@after_days INT = 28,
    @step INT = 1
AS
BEGIN

/**********************************************Preperations**********************************************/

/*Take only relevant dates that can be found in SO_SI table*/
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat' ,'U') IS NOT NULL
    DROP TABLE [#HW_Input_rasPlusFormat];
Select t1.PromotionNumber,
		t1.PromotionStartDate,
		t1.PromotionEndDate,
		t1.ProductNumber,
		t1.TransactionDate,
		t1.Branch_name_EN,
		t1.SourceInd,
		t1.Multibuy_quantity,
		t1.Real_quantity,
		t1.Baseline_quantity,
		t1.Uplift,
		t1.Revenue_3_subs_group,
		t1.Revenue_4_promobuyer_existing,
		t1.Revenue_5_promobuyer_new,
		t1.Revenue_6_new_customer,
		t1.Revenue_value_effect --For Checks
	into #HW_Input_rasPlusFormat
	from dbo.PG_input_RAS t1
	where t1.PromotionEndDate>=dateadd(day,-28,@Start_date)
	;


/**********************************************ADD Quantities of stuff to RAS_input for later adding the SI/SO table**********************************************/
BEGIN

--Add Quantities for adoption and hording (since it's the same product then we only need the quantities and later we will multiply by catalog price)
--We also number the rows to keep track
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat2' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat2;
Select t1.*,
			t2.Quantity_7_product_adoption,
			case when t3.Quantity_8_hoarding>0 then 0 else t3.Quantity_8_hoarding end as Quantity_8_hoarding,
			row_number() OVER (ORDER BY t1.TransactionDate) as rownum
into #HW_Input_rasPlusFormat2
	from #HW_Input_rasPlusFormat t1
	left join dbo.PG_ROI_component_7 t2
	on t1.PromotionNumber=t2.PromotionNumber
	and t1.ProductNumber=t2.ProductNumber
	and t1.Branch_name_EN=t2.Branch_name_EN
	and t1.TransactionDate=t2.TransactionDate
	and t1.PromotionStartDate=t2.PromotionStartDate
	and t1.PromotionEndDate=t2.PromotionEndDate
	and t1.SourceInd=t2.SourceInd
	left join dbo.PG_ROI_component_8 t3
	on t1.PromotionNumber=t3.PromotionNumber
	and t1.ProductNumber=t3.ProductNumber
	and t1.Branch_name_EN=t3.Branch_name_EN
	and t1.TransactionDate=t3.TransactionDate
	and t1.PromotionStartDate=t3.PromotionStartDate
	and t1.PromotionEndDate=t3.PromotionEndDate
	and t1.SourceInd=t3.SourceInd
		
;

END


/*********************************************Change Revenues to Catalog Price Revenues using distribution table ***********/

--Change all revenues to Catalog prices revenues by multiplying with the above result
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat3' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat3;
select t1.rownum,
		t1.PromotionNumber,
		t1.PromotionStartDate,
		t1.PromotionEndDate,
		t1.ProductNumber,
		t1.Multibuy_quantity,
		t1.Branch_name_EN,
		t1.SourceInd,
		t1.TransactionDate,
		t1.Real_quantity,
		t1.Baseline_quantity,
		t1.Revenue_3_subs_group*t3.catRev2Rev_Ratio as Cat_Revenue_3_subs_group,
		t1.Revenue_4_promobuyer_existing*t2.catRev2Rev_Ratio as Cat_Revenue_4_promobuyer_existing,
		t1.Revenue_5_promobuyer_new*t2.catRev2Rev_Ratio as Cat_Revenue_5_promobuyer_new,
		t1.Revenue_6_new_customer*t2.catRev2Rev_Ratio as Cat_Revenue_6_new_customer,
		t1.Quantity_7_product_adoption,
		t1.Quantity_8_hoarding,
		t1.Revenue_value_effect
into #HW_Input_rasPlusFormat3
from #HW_Input_rasPlusFormat2 t1
left join GN_Catalog_revenue_ratio_tot t2
on t2.Branch_name_EN=t1.Branch_name_EN
and t2.SourceInd=t1.SourceInd
left join GN_Catalog_revenue_ratio_subs t3
on t3.ProductNumber=t1.ProductNumber
and t3.Branch_name_EN=t1.Branch_name_EN
and t3.SourceInd=t1.SourceInd


/**********************************************Add supplierID+Catalog Price to promotioncustomer Table**********************************************/

BEGIN

-- Add Supplier_ID
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat4' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat4;
select distinct * /*There are a lot of cases where everything is the same but there are several dates of activation, so we take the distinct*/
into #HW_Input_rasPlusFormat4
from (SELECT 
	t1.*,
	t2.supplier as supplier_ID,
	t2.Catalog_Price as CatalogPrice,
	count(*) over (partition by t1.rownum) as cnt_suppliers,
	t2.StartDate
  FROM #HW_Input_rasPlusFormat3 t1
  left join HW_Catalog_Supplier_Union_update t2
  on t1.ProductNumber=t2.ProductNumber
	and t1.Branch_name_EN=t2.branch_name_EN
	and t1.TransactionDate<=t2.EndDate
	and t1.TransactionDate>=t2.StartDate) m

--Divide Quantities between suppliers. Note that we don't divide the hording/adoption quantities, we do it in the end
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat4_5' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat4_5;
select t1.*
			,t1.Real_quantity/isnull(t1.cnt_suppliers,1) as DistributedRealQuantity
			,t1.Baseline_quantity/isnull(t1.cnt_suppliers,1) as DistributedBaseQuantity
into #HW_Input_rasPlusFormat4_5
from #HW_Input_rasPlusFormat4 t1
		

--Add another rownumbers to keep track (supposed to stay the same)
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat4_75' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat4_75;
select *,
		row_number() OVER (ORDER BY TransactionDate) as rownum_After_suppliers 
into #HW_Input_rasPlusFormat4_75
from #HW_Input_rasPlusFormat4_5

;

END

/**********************************************Add Distribution of Components revenues with specific suppliers**********************************************/

BEGIN

--Add the customerEffects percentages by joining with the supplier distribution table
--Note that for these effects (component 4,5,6) we take the distribution over all transactions
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat5' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat5;
select t1.*,
	t2.perc_CatRev as perc_CatRev_customerEffects
into #HW_Input_rasPlusFormat5
from #HW_Input_rasPlusFormat4_75 t1
left join GN_totalTransactions_supplier_dist t2
on t2.supplier_ID=t1.supplier_ID
and t2.sourceINd=t1.sourceind
and t1.branch_name_en=t2.branch_name_en

--Take for each row in the input_RAS the average percentage the specific supplier has out of all the subgroups the product is in
--Note that for these effects (component 3) we take the distribution over the subgroups
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat6' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat6;
select t1.rownum_After_suppliers,
		avg(t2.perc_CatRev) as perc_CatRev_Substitution
into #HW_Input_rasPlusFormat6 
from (select p1.*,
			p2.level_ID
		from #HW_Input_rasPlusFormat5 p1
		left join PG_product_substitute_levels p2
		on p2.product_ID=p1.ProductNumber
		) t1
left join GN_subgroups_supplier_dist t2
on t2.supplier_ID=t1.supplier_ID
and t2.sourceINd=t1.sourceind
and t1.branch_name_en=t2.branch_name_en
and t2.level_ID=t1.level_ID
group by rownum_After_suppliers


--Add the substitution percentages
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat7' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat7;
select t1.*,
		t2.perc_CatRev_Substitution
into #HW_Input_rasPlusFormat7 
from #HW_Input_rasPlusFormat5 t1
left join #HW_Input_rasPlusFormat6 t2
on t2.rownum_After_suppliers=t1.rownum_After_suppliers

;
END

/**********************************************Join SI/SO tables**********************************************/


/*add Sell-Out PRODUCT*/
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat8' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat8;

	Select	t1.*,
			t2.avg_Partic as SellOut_Prod
	Into #HW_Input_rasPlusFormat8
	from #HW_Input_rasPlusFormat7 t1
	left join (select * from HW_SellOut_Products_TOT where date0>=dateadd(day,-28,@Start_date)) t2
	on t1.ProductNumber=t2.Product_ID
	and t1.TransactionDate=t2.date0
	and t1.Branch_name_EN=t2.Branch_name_EN
	and t2.SUPPLIER_ID=t1.Supplier_ID
;


--Make Multibuy calculations to fit financial reports
IF OBJECT_ID('tempdb..#temp' ,'U') IS NOT NULL
    DROP TABLE #temp;
select	t1.rownum_After_suppliers,
		t1.PromotionNumber,
		t1.ProductNumber,
		t1.SourceInd,
		t1.Supplier_ID,
		t1.Branch_name_EN,
		t1.TransactionDate,
		t2.MONTH,
		t2.avg_Partic,
		t2.Tot_Partic,
		t2.Tot_sales,
		--If we want to distinguish between SourceINd we should add it to the partition by
		sum(t1.DistributedRealQuantity) over (partition by t1.PromotionNumber,t1.Supplier_ID,t1.Branch_name_EN,t2.MONTH) as TotalSalesInput_RAS
into #temp
from #HW_Input_rasPlusFormat8 t1
left join ( --ADd total participation over entire promotion
			Select p2.*,
					sum(p2.Supplier_participation/p2.numDays) over (partition by p2.Branch_name_EN,p2.Supplier_ID,p2.DISCOUNT_ID,p2.MONTH) as Tot_Partic,
					sum(p2.TOTAL_SALES/p2.numDays) over (partition by p2.Branch_name_EN,p2.Supplier_ID,p2.DISCOUNT_ID,p2.MONTH) as Tot_sales
			From (--Add number of promotion Days in the relevant month in each row
					select p.*,
						count(*) over (partition by p.Branch_name_EN,p.Supplier_ID,p.DISCOUNT_ID,p.MONTH) as numDays
					from (select * from HW_SellOut_Promotions_update 
					               where [MONTH]>=100*year(dateadd(day,-28,@Start_date))+month(dateadd(day,-28,@Start_date))
								   ) p
					) p2
			) t2
on t2.DISCOUNT_ID= (Case when len(t1.PromotionNumber) >8 then left(t1.PromotionNumber,len(t1.PromotionNumber)-3) else t1.PromotionNumber END)
	and t1.TransactionDate=t2.date0
	and t1.Branch_name_EN=t2.Branch_name_EN
	and t2.SUPPLIER_ID=t1.Supplier_ID

--add Sell-Out PROMOTION
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat9' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat9;
	Select	t1.*,
			case when t1.Multibuy_quantity<=1 then t2.avg_Partic 
				else (case when t2.Tot_sales<=(t2.TotalSalesInput_RAS/t1.Multibuy_quantity) then t2.Tot_Partic/t2.TotalSalesInput_RAS else t2.avg_Partic/t1.Multibuy_quantity end)
				end as SellOut_Prom
	Into #HW_Input_rasPlusFormat9
	from #HW_Input_rasPlusFormat8 t1
	left join #temp t2
	on t2.PromotionNumber=t1.PromotionNumber
	and t1.TransactionDate=t2.TransactionDate
	and t1.Branch_name_EN=t2.Branch_name_EN
	and t2.SUPPLIER_ID=t1.Supplier_ID
	and t1.SourceInd=t2.SourceInd
	and t1.ProductNumber=t2.ProductNumber
	and t1.rownum_After_suppliers=t2.rownum_After_suppliers
;

--Add Sell-in
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat10' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat10;
	Select	t1.*,
			isnull(t1.SellOut_Prod,0)+isnull(t1.SellOut_Prom,0) as SellOut_TOT,
			t1.CatalogPrice-t2.PriceA as SellIn
	Into #HW_Input_rasPlusFormat10
	from #HW_Input_rasPlusFormat9 t1
	left join (select p1.VendorNumber,p1.ProductNumber,p1.MonthNumber,avg(p1.PriceA) as PriceA,
				         p2.Branch_name_EN
					from (select * from dbo.HW_Staging_sell_in_update where StoreFormatCode<8) p1
					left join Staging_branches p2
					on p2.Branch_ID=p1.StoreFormatCode
					Group by 
					p1.VendorNumber,p1.ProductNumber,p1.MonthNumber,p2.Branch_name_EN 
				) t2
	on t1.supplier_ID=t2.VendorNumber
	and t1.ProductNumber=t2.ProductNumber
	and datepart(Year,t1.TransactionDate)=round(t2.MonthNumber/100,0)
	and datepart(Month,t1.TransactionDate)=t2.MonthNumber-100*round(t2.MonthNumber/100,0)
	and t1.Branch_name_EN=t2.Branch_name_EN
;

--****************************Adding Supplier Segmentation *****************************

BEGIN 

--Delete negative participation (doesn't make sense buisness wise)
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat10_25' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat10_25;
select	t1.*,
		case when t1.SellOut_Prod<0 then 0 else t1.SellOut_Prod end as SellOut_Prod_c,
		case when t1.SellOut_Prom<0 then 0 else t1.SellOut_Prom end as SellOut_Prom_c,
		case when t1.SellIn<0 then 0 else t1.SellIn end as SellIn_c
Into #HW_Input_rasPlusFormat10_25
from #HW_Input_rasPlusFormat10 t1

--Add Revenue and Participation
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat10_5' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat10_5;
select	t1.*,
		(isnull(t1.DistributedRealQuantity,0)-isnull(t1.DistributedBaseQuantity,0)+isnull(t1.Quantity_7_product_adoption,0)/t1.cnt_suppliers+isnull(t1.Quantity_8_hoarding,0)/t1.cnt_suppliers)*t1.CatalogPrice+
		isnull(t1.Cat_Revenue_3_subs_group,0)*isnull(t1.perc_CatRev_Substitution,0)+(isnull(t1.Cat_Revenue_4_promobuyer_existing,0)+isnull(t1.Cat_Revenue_5_promobuyer_new,0))*isnull(t1.perc_CatRev_customerEffects,0) as Revenue_Value_Effect_Cat
		,-isnull(t1.DistributedRealQuantity,0)*(isnull(t1.SellIn_c,0)+isnull(t1.SellOut_Prod_c,0)+ISNULL(t1.SellOut_Prom_c,0)) as Tot_Participation
Into #HW_Input_rasPlusFormat10_5
from #HW_Input_rasPlusFormat10_25 t1

--Create Segmentation based on NetValue Effect on promotion level
-->0 => win for supplier
--<=0 => lose for supplier
IF OBJECT_ID('tempdb..#HW_Input_rasPlusFormat10_75' ,'U') IS NOT NULL
    DROP TABLE #HW_Input_rasPlusFormat10_75;
select	t1.PromotionNumber, t1.Supplier_ID,
		sum(isnull(Revenue_Value_Effect_Cat,0)) as RevenueValueEffect,
		sum(isnull(Tot_Participation,0)) as Tot_Participation,
		case when sum(isnull(Revenue_Value_Effect_Cat,0))=0 then '2. Lose'
			 when sum(isnull(Tot_Participation,0))=0 then '1. Win'
			 when (sum(isnull(Revenue_Value_Effect_Cat,0))/abs(sum(isnull(Tot_Participation,0))))>2 then '1. Win' 
			 else '2. Lose' end as Supplier_Segment
Into #HW_Input_rasPlusFormat10_75
from #HW_Input_rasPlusFormat10_5 t1
group by t1.PromotionNumber, t1.Supplier_ID

;
END


/**********************************************Finalize table **********************************************/

--will duplicate duplicates because we didn
IF OBJECT_ID('dbo.PG_input_RAS_Wave1_5_w_correction_update', 'U') IS NOT NULL
    DROP TABLE dbo.PG_input_RAS_Wave1_5_w_correction_update;
select distinct *
into dbo.PG_input_RAS_Wave1_5_w_correction_update
from (select	t2.*,
		t1.cnt_suppliers,
		t1.Supplier_ID,
		t3.Supplier_name_HE,
		t1.DistributedRealQuantity,
		t1.DistributedBaseQuantity,
		t1.CatalogPrice,
		t1.SellOut_Prod_c as SellOut_Prod,
		t1.SellOut_Prom_c as SellOut_Prom,
		t1.SellIn_c as SellIn,
		t1.DistributedRealQuantity*t1.CatalogPrice as Revenue_1_promotion_Cat,
		-t1.DistributedBaseQuantity*t1.CatalogPrice as Revenue_2_subs_promo_Cat,
		t1.Cat_Revenue_3_subs_group*t1.perc_CatRev_Substitution as Revenue_3_subs_group_Cat,
		t1.Cat_Revenue_4_promobuyer_existing*t1.perc_CatRev_customerEffects as Revenue_4_promobuyer_existing_Cat,
		t1.Cat_Revenue_5_promobuyer_new*t1.perc_CatRev_customerEffects as Revenue_5_promobuyer_new_Cat,
		t1.Cat_Revenue_6_new_customer*t1.perc_CatRev_customerEffects as Revenue_6_new_customer_Cat,
		t1.Quantity_7_product_adoption*t1.CatalogPrice/t1.cnt_suppliers as Revenue_7_Product_adoption_Cat,
		case when t1.Quantity_8_hoarding*t1.CatalogPrice/t1.cnt_suppliers<-t1.DistributedRealQuantity*t1.CatalogPrice then -t1.DistributedRealQuantity*t1.CatalogPrice 
			 else t1.Quantity_8_hoarding*t1.CatalogPrice/t1.cnt_suppliers end as Revenue_8_hording_Cat,
		t1.Revenue_Value_Effect_Cat
		,t1.Tot_Participation
		,t4.Supplier_Segment
		,case when t4.Supplier_Segment='1. Win' and t2.Promotion_segment in ('3. Potential winner','2. Diamond','1. Winner') then '1. Win-Win'
			  when t4.Supplier_Segment='1. Win' and t2.Promotion_segment in ('6. Margin killer','5. Bleeder','4. Grey herd') then '3. Lose-Win'
			  when t4.Supplier_Segment='2. Lose' and t2.Promotion_segment in ('3. Potential winner','2. Diamond','1. Winner') then '2. Win-Lose'
			  when t4.Supplier_Segment='2. Lose' and t2.Promotion_segment in ('6. Margin killer','5. Bleeder','4. Grey herd') then '4. Lose-Lose'
		 end as Supplier_Matrix_segment
		,t1.rownum_After_suppliers
from #HW_Input_rasPlusFormat10_5 t1
inner join dbo.PG_input_RAS t2
on t2.PromotionNumber=t1.PromotionNumber
and t1.TransactionDate=t2.TransactionDate
and t1.ProductNumber=t2.ProductNumber
and t1.Branch_name_EN=t2.Branch_name_EN
and t1.SourceInd=t2.SourceInd
and t1.Real_quantity=t2.Real_quantity 
and t1.Baseline_quantity=t2.Baseline_quantity
and t1.PromotionStartDate=t2.PromotionStartDate
and t1.PromotionEndDate=t2.PromotionEndDate
left join (select p1.Supplier_ID,MAX(p1.Supplier_name_HE) as Supplier_name_HE
			from Staging_assortment_supplier p1
			group by p1.Supplier_ID ) t3
on t3.Supplier_ID=t1.supplier_ID
left join #HW_Input_rasPlusFormat10_75 t4
on t4.supplier_ID=t1.Supplier_ID
and t1.PromotionNumber=t4.PromotionNumber) m
 
;


drop table #temp
drop table #HW_Input_rasPlusFormat
drop table #HW_Input_rasPlusFormat2
drop table #HW_Input_rasPlusFormat3
drop table #HW_Input_rasPlusFormat4
drop table #HW_Input_rasPlusFormat4_5
drop table #HW_Input_rasPlusFormat4_75
drop table #HW_Input_rasPlusFormat5
drop table #HW_Input_rasPlusFormat6
drop table #HW_Input_rasPlusFormat7
drop table #HW_Input_rasPlusFormat8
drop table #HW_Input_rasPlusFormat9
drop table #HW_Input_rasPlusFormat10
drop table #HW_Input_rasPlusFormat10_25
drop table #HW_Input_rasPlusFormat10_5
drop table #HW_Input_rasPlusFormat10_75

END