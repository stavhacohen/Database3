
-- =============================================
-- Author:		Hagai and Gal
-- Create date:	2018-8-8
-- Description:	Generates input data for Promotion Score Card View
-- =============================================
CREATE PROCEDURE [dbo].[GN_update_Prep_7M_SupplierRas]
    @run_nr INT = 1,
    @end_date DATE = '2018-07-20',
	@Start_date DATE = '2018-06-25',
	@after_days INT = 28,
    @step INT = 1
AS
BEGIN

--**********************************************************************************************************
--**********************************************************************************************************
--***************************************************Supplier***********************************************
--**********************************************************************************************************
--**********************************************************************************************************

Begin


--Multiple What we do : 
--1) For now we just take the latest starting supplier
IF OBJECT_ID('tempdb..#DealWithMultiSup' ,'U') IS NOT NULL
    DROP TABLE #DealWithMultiSup;
select t.ProductNumber,
		t.Branch_name_EN,
		t.Supplier,
	   t.StartDate,
		t.EndDate,
		t.Catalog_price
into #DealWithMultiSup
from (		select m2.*,
				ROW_NUMBER() over (partition by ProductNumber,Branch_name_EN order by StartDate desc) as OrderByRank
		from (select p3.ProductNumber,
					p3.StartDate,
					p3.EndDate,
					p3.Supplier,
					p3.Branch_name_EN,
					AVG(p3.Catalog_PRice) as Catalog_price 
					from (select p1.ProductNumber,
								p1.StartDate,
								p1.EndDate,
								p1.Supplier,
								cast(p1.Catalog_Price as decimal(9,2)) as Catalog_price,
								p2.Branch_name_EN
							from dbo.HW_Catalog_Supplier_recent p1
							left join Staging_branches p2
							on p2.Branch_ID=p1.[Format]) p3
					group by p3.ProductNumber,p3.StartDate,p3.EndDate,p3.Supplier,p3.Branch_name_EN
			) m2
) t
where OrderByRank=1

--Correction for missing Supplier Data - What we do : 
--1) Take all the rows with missing supplier ID (t1) and add to them the relevant supplier rows (t2) based on product and dates
--2) We also add there for each supplier the number of other branches it was seen in (cnt_supplier_branch)
--3) Then we give each supplier for a specific original row (from t1) a rank based on : a) Illan's Rules b) How frequent it is in other branches c) Hierarchy of the branches
--3_5) Illan's rules are : For all -> first look at Sheli then Deal, For Deal --> first look at Extra then Sheli, For Extra --> first look at Deal then Sheli
--4) In this ranking (OrderByRank) we first look at which supplier is most frequent, and if there are many with the same frequency, we had that which is in the highest hierarchy branch. If there are two of these, we choose randomly one of them 
IF OBJECT_ID('tempdb..#DealWithMissingSup_1' ,'U') IS NOT NULL
    DROP TABLE #DealWithMissingSup_1;
select t1.ProductNumber,
		t2.Branch_name_EN,
		t3.StartDate,
		t3.EndDate,
		t3.Supplier,
		t3.Catalog_Price
into #DealWithMissingSup_1
from (select distinct productnumber from #DealWithMultiSup) t1
cross join (select distinct Branch_name_EN from #DealWithMultiSup) t2
left join #DealWithMultiSup t3
on t1.ProductNumber=t3.ProductNumber
and t2.Branch_name_EN=t3.Branch_name_EN

IF OBJECT_ID('tempdb..#DealWithMissingSup_2' ,'U') IS NOT NULL
    DROP TABLE #DealWithMissingSup_2;
select m2.*,
		ROW_NUMBER() over (partition by ProductNumber,Branch_name_EN order by SupplierRanking_internal,EndDate desc) as OrderByRank
into #DealWithMissingSup_2
from (select m.*,
		case when m.Supplier is null then 0
			 when m.Branch_name_EN='Deal' and m.Branch_2='Extra' then 1000+m.cnt_supp_branches*10
			 when m.Branch_name_EN='Extra' and m.Branch_2='Deal' then 1000+m.cnt_supp_branches*10
			 when m.Branch_2='Sheli' then 110+m.cnt_supp_branches*10
			 when m.Branch_2='Deal' then 100+m.cnt_supp_branches*10
			 when m.Branch_2='Extra' then 7+m.cnt_supp_branches*10
			 when m.Branch_2='Organic' then 6+m.cnt_supp_branches*10
			 when m.Branch_2='Online' then 5+m.cnt_supp_branches*10
			 when m.Branch_2='Express' then 4+m.cnt_supp_branches*10
			  else m.cnt_supp_branches*10 end as SupplierRanking_internal
	  from (select t1.ProductNumber,
					t1.Branch_name_EN,
					t2.Branch_2,
					t2.Supplier,
					t2.StartDate,
					t2.EndDate,
					t2.Catalog_price,
					t2.cnt_supp_branches
			from (select * from #DealWithMissingSup_1 where Supplier is null and ProductNumber is not null) t1
			left join (select t.ProductNumber,
								t.StartDate,
								t.EndDate,
								t.Supplier,
								t.Branch_name_EN as Branch_2,
								t.Catalog_price,
							  count(*) over (partition by t.ProductNumber,t.Supplier) as cnt_supp_branches
						from #DealWithMissingSup_1 t
						where t.Supplier is not null) t2
			on t1.ProductNumber=t2.ProductNumber) m
	) m2

IF OBJECT_ID('tempdb..#DealWithMissingSup' ,'U') IS NOT NULL
    DROP TABLE #DealWithMissingSup;
select t.ProductNumber,t.Branch_name_EN,t.Supplier,t.StartDate,t.EndDate,t.Catalog_price
into #DealWithMissingSup
from #DealWithMissingSup_2 t
where OrderByRank=1
and Supplier is not Null

--************************** END OF CORRECTION FOR MISSING SUPPLIER DATA **********************

--connect both
IF OBJECT_ID('tempdb..#HW_Catalog_Supplier_recent' ,'U') IS NOT NULL
    DROP TABLE #HW_Catalog_Supplier_recent;
select *
into #HW_Catalog_Supplier_recent
from (select * from #DealWithMissingSup
union 
select * from #DealWithMultiSup) m
where Branch_name_EN is not null


--Update our list of suppliers
--We assume we got a list of unique suppliers, i.e. without multiple suppliers for same product/branch. This is why all the AVG,MAX,MIN there should not change anything
select t1.ProductNumber,
	   t1.Branch_name_EN,
	   coalesce(t2.Supplier,t1.Supplier) as Supplier,
	   coalesce(t2.StartDate,t1.StartDate) as StartDate,
	   coalesce(t2.EndDate,t1.EndDate) as EndDate,
	   coalesce(t2.Catalog_proce,t1.Catalog_price) as Catalog_price 
from HW_Catalog_Supplier_Union_update t1
left join #HW_Catalog_Supplier_recent t2
on t1.ProductNumber=t2.ProductNumber
and t1.Branch_name_EN=t2.Branch_name_EN

--add new products
INSERT HW_Catalog_Supplier_Union_update(
		ProductNumber,
		Branch_name_EN,
		StartDate,
		EndDate,
		Supplier,
		Catalog_Price
)
SELECT ProductNumber,
		Branch_name_EN,
		StartDate,
		EndDate,
		Supplier,
		Catalog_Price
FROM #HW_Catalog_Supplier_recent 
WHERE ProductNumber not in (select ProductNumber from HW_Catalog_Supplier_Union_update)


;
END

--**********************************************************************************************************
--**********************************************************************************************************
--***************************************************Sell Out Preperations**********************************
--**********************************************************************************************************
--**********************************************************************************************************

BEGIN

--Translate branches to correct index - Yosi and Sarit are in a different dictionary.
IF OBJECT_ID('tempdb..#branches') IS NOT NULL
    DROP TABLE #branches
select distinct format_id,FORMAT_NAME 
into #branches
from HW_SellOut_supplier_billing_recent

-- adding the translation
IF OBJECT_ID('tempdb..#HW_SellOut_supplier_billing_recent_Branchs') IS NOT NULL
    DROP TABLE #HW_SellOut_supplier_billing_recent_Branchs
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
into #HW_SellOut_supplier_billing_recent_Branchs
from  HW_SellOut_supplier_billing_recent sb

-- adding the translation
IF OBJECT_ID('tempdb..#HW_SellOut_supplier_billing_in_sales_recent_Branchs') IS NOT NULL
    DROP TABLE #HW_SellOut_supplier_billing_in_sales_recent_Branchs
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
into #HW_SellOut_supplier_billing_in_sales_recent_Branchs
from  HW_SellOut_supplier_billing_in_sales_recent sb


--creating sell out promotions with avg participation and branch_name_EN
IF OBJECT_ID('tempdb..#HW_SellOut_supplier_billing_recent_Branchs_wAvg') IS NOT NULL
    DROP TABLE #HW_SellOut_supplier_billing_recent_Branchs_wAvg
select sop.*,sb.Branch_name_EN
into #HW_SellOut_supplier_billing_recent_Branchs_wAvg
from #HW_SellOut_supplier_billing_recent_Branchs sop
 left join Staging_branches sb
 on sop.Branch_ID_SARIT=sb.Branch_ID

--creating sell out product with avg participation and branch_name_EN
IF OBJECT_ID('tempdb..#HW_SellOut_supplier_billing_in_sales_recent_Branchs_wAvg') IS NOT NULL
    DROP TABLE #HW_SellOut_supplier_billing_in_sales_recent_Branchs_wAvg
select sop.*,sb.Branch_name_EN 
into #HW_SellOut_supplier_billing_in_sales_recent_Branchs_wAvg
from #HW_SellOut_supplier_billing_in_sales_recent_Branchs sop
 left join Staging_branches sb
 on sop.Branch_ID_SARIT=sb.Branch_ID

-- creating sell out promotions on a day level
IF OBJECT_ID('tempdb..#HW_SellOut_supplier_billing_in_sales_recent_Branchs_wAvg_day_level') IS NOT NULL
    DROP TABLE #HW_SellOut_supplier_billing_in_sales_recent_Branchs_wAvg_day_level
select a.*, dd.[date] as date0 
into #HW_SellOut_supplier_billing_in_sales_recent_Branchs_wAvg_day_level
from #HW_SellOut_supplier_billing_in_sales_recent_Branchs_wAvg a
left join promotions.dim_date dd
on dd.[date] between cast(cast(a.DATE_FROM as varchar)as date) and cast(cast(a.DATE_TO as varchar)as date)
and format(dd.[date],'yyyyMM')  = a.[MONTH]

--creating sell out products on a day level
IF OBJECT_ID('tempdb..#HW_SellOut_supplier_billing_recent_Branchs_wAvg_day_level') IS NOT NULL
    DROP TABLE #HW_SellOut_supplier_billing_recent_Branchs_wAvg_day_level
select a.*, dd.[date] as date0
into #HW_SellOut_supplier_billing_recent_Branchs_wAvg_day_level
from #HW_SellOut_supplier_billing_recent_Branchs_wAvg a
left join promotions.dim_date dd
on dd.[date] between cast(cast(a.DATE_FROM as varchar)as date) and cast(cast(a.DATE_TO as varchar)as date)
and format(dd.[date],'yyyyMM')  = a.[MONTH]

--Save
IF OBJECT_ID('dbo.HW_SellOut_Promotions_recent', 'U') IS NOT NULL
    DROP TABLE dbo.HW_SellOut_Promotions_recent;
select  t.DISCOUNT_ID
	   ,t.Branch_name_EN
	   ,t.date0
	   ,t.SUPPLIER_ID
	   ,MAX(t.MONTH) as MONTH
	   ,MAX(t.SUPPLIER_NAME) as SUPPLIER_NAME
	   ,MAX(t.Branch_ID_SARIT) as FORMAT_ID_Sarit
	   ,SUM(isnull(t.TOTAL_SALES,0)) as TOTAL_SALES
	   ,SUM(isnull(t.SUPPLIER_PARTICIPATION,0)) as SUPPLIER_PARTICIPATION
	   ,case when SUM(isnull(t.TOTAL_SALES,0))=0 then SUM(isnull(t.SUPPLIER_PARTICIPATION,0))
			else SUM(isnull(t.SUPPLIER_PARTICIPATION,0))/SUM(isnull(t.TOTAL_SALES,0)) 
			end as avg_partic
into Shufersal.dbo.HW_SellOut_Promotions_recent
from #HW_SellOut_supplier_billing_recent_Branchs_wAvg_day_level t
group by t.DISCOUNT_ID
	   ,t.Branch_name_EN
	   ,t.date0
	   ,t.SUPPLIER_ID
--Save
IF OBJECT_ID('dbo.HW_SellOut_Products_recent', 'U') IS NOT NULL
    DROP TABLE dbo.HW_SellOut_Products_recent;
select t.PRODUCT_ID
	   ,t.Branch_name_EN
	   ,t.date0
	   ,t.SUPPLIER_ID
	   ,MAX(t.MONTH) as MONTH
	   ,MAX(t.SUPPLIER_NAME) as SUPPLIER_NAME
	   ,MAX(t.Branch_ID_SARIT) as FORMAT_ID_Sarit
	   ,SUM(isnull(t.TOTAL_SALES,0)) as TOTAL_SALES
	   ,SUM(isnull(t.SUPPLIER_PARTICIPATION,0)) as SUPPLIER_PARTICIPATION
	   ,case when SUM(isnull(t.TOTAL_SALES,0))=0 then SUM(isnull(t.SUPPLIER_PARTICIPATION,0))
			else SUM(isnull(t.SUPPLIER_PARTICIPATION,0))/SUM(isnull(t.TOTAL_SALES,0)) 
			end as avg_partic
into Shufersal.dbo.HW_SellOut_Products_recent
from #HW_SellOut_supplier_billing_in_sales_recent_Branchs_wAvg_day_level t
group by t.PRODUCT_ID
	   ,t.Branch_name_EN
	   ,t.date0
	   ,t.SUPPLIER_ID


-- Move new data to TOT table
IF OBJECT_ID('tempdb..#SO_temp1') IS NOT NULL
    DROP TABLE #SO_temp1
select *
into #SO_temp1
from HW_SellOut_Products_TOT
union 
select * from HW_SellOut_Products_recent
--
Truncate table HW_SellOut_Products_TOT 
--
INSERT INTO HW_SellOut_Products_TOT
SELECT	  *
FROM	#SO_temp1

IF OBJECT_ID('tempdb..#SO_temp2') IS NOT NULL
    DROP TABLE #SO_temp2
select *
into #SO_temp2
from HW_SellOut_Promotions_TOT
union 
select * from HW_SellOut_Promotions_recent
--
Truncate table HW_SellOut_Promotions_TOT 
--
INSERT INTO HW_SellOut_Promotions_TOT
SELECT	  *
FROM	#SO_temp2

;
END


--**********************************************************************************************************
--**********************************************************************************************************
--**************************************Supplier Percentages from revenues**********************************
--**********************************************************************************************************
--**********************************************************************************************************

BEGIN

--****************************************ADDING CATALOG PRICES AND REVENUES****************** 
IF OBJECT_ID('dbo.GN_PG_sales_per_product_per_day_wo_returns_update', 'U') IS NOT NULL
    DROP TABLE dbo.GN_PG_sales_per_product_per_day_wo_returns_update;
SELECT t.ProductNumber,
		t.TransactionDate,
		t.SourceInd,
		t.Branch_name_EN,
		case when t.Quantity<0 then 0 else t.Quantity end as Quantity,
		case when t.Revenue<0 then 0 else t.Revenue end as Revenue,
		t2.Catalog_price as CatalogPrice,
		t2.Catalog_price*t.Quantity as CatalogRevenue,
		t2.Supplier as Supplier_ID,
		count(*) over (partition by t.ProductNumber,t.Branch_name_EN,t.sourceIND,t.TransactionDate) as cnt_suppliers,
		t2.StartDate,
		row_number() over (order by t.TransactionDate) as rownum
into GN_PG_sales_per_product_per_day_wo_returns_update
  FROM [Shufersal].[dbo].[PG_sales_per_product_per_day_wo_returns] t
left join dbo.HW_Catalog_Supplier_Union_update t2
on t2.ProductNumber=t.ProductNumber
and t.Branch_name_EN=t2.Branch_name_EN
where t.TransactionDate>=dateadd(day,-28,@Start_date)

--For each product add the total revenue/margin in the Branch+SourceIND it was baught
--We already have supplier so we need to divide by the number of suppliers for each product
IF OBJECT_ID('tempdb..#temp' ,'U') IS NOT NULL
    DROP TABLE [#temp];
select t1.*,
		sum(t1.Revenue/t1.cnt_suppliers) over (partition by t1.SourceInd,t1.Branch_name_EN) as tot_rev_BranchSource,
		sum(isnull(t1.CatalogRevenue,0)/t1.cnt_suppliers) over (partition by t1.SourceInd,t1.Branch_name_EN) as tot_CatRev_BranchSource /*Assumption : quantity of a product is divided equally between all suplliers*/
into #temp
from GN_PG_sales_per_product_per_day_wo_returns_update t1

--Calculate for each Branch+SourceInd the relative revenue a product had over all dates
IF OBJECT_ID('tempdb..#temp2' ,'U') IS NOT NULL
    DROP TABLE [#temp2];
select t1.ProductNumber,
		t1.SUPPLIER_ID,
		t1.Branch_name_EN,
		t1.SourceInd,
		case when sum(t1.CatalogPrice) is null then NULL else avg(t1.CatalogPrice) end as CatalogPrice,
		avg(t1.tot_rev_BranchSource) as tot_rev_BranchSource,
		case when sum(t1.CatalogRevenue) is null then NULL else avg(t1.tot_CatRev_BranchSource) end as tot_CatRev_BranchSource,
		case when avg(t1.tot_rev_BranchSource)=0 then 0 
		     else sum(case when t1.tot_rev_BranchSource=0 then 0 else t1.Revenue/t1.cnt_suppliers end)/avg(t1.tot_rev_BranchSource) 
			 end as perc_rev,
		case when avg(t1.tot_CatRev_BranchSource)=0 then 0
		     else sum(case when t1.tot_CatRev_BranchSource=0 then 0 else t1.CatalogRevenue/t1.cnt_suppliers end)/avg(t1.tot_CatRev_BranchSource) 
			 end as perc_CatRev
into #temp2
from #temp t1
group by t1.ProductNumber,
		t1.SUPPLIER_ID,
		t1.Branch_name_EN,
		t1.SourceInd

--Calculate for each Branch+SourceInd the relative revenue a SUPPLIER had over all dates (aggregating it's products)
IF OBJECT_ID('tempdb..#temp3' ,'U') IS NOT NULL
    DROP TABLE [#temp3];
select t1.SUPPLIER_ID,
		t1.SourceInd,
		t1.Branch_name_EN,
		count(distinct t1.ProductNumber) as cnt_products,
		avg(t1.tot_rev_BranchSource) as tot_rev_BranchSource,
		avg(t1.tot_CatRev_BranchSource) as tot_CatRev_BranchSource,
		sum(t1.perc_rev) as perc_rev,
		sum(isnull(t1.perc_CatRev,0)) as perc_CatRev
into #temp3
from #temp2 t1
group by t1.SUPPLIER_ID,
		t1.SourceInd,
		t1.Branch_name_EN

--save
IF OBJECT_ID('dbo.GN_totalTransactions_supplier_dist', 'U') IS NOT NULL
    DROP TABLE dbo.GN_totalTransactions_supplier_dist;
select *
into dbo.GN_totalTransactions_supplier_dist
from #temp3

--***********************************************FOR SUBSTITUTION********************************
--for each Product+SourceInd+Branch_name add a subgroup level_ID and the total revenue for that subgroup in the sepcific sourceIND+Branch
IF OBJECT_ID('tempdb..#subtemp1' ,'U') IS NOT NULL
    DROP TABLE #subtemp1;
select  t1.ProductNumber,
t1.TransactionDate,
t1.SourceInd,
t1.Branch_name_EN,
t1.supplier_ID,
t1.Revenue, t1.CatalogRevenue,t1.cnt_suppliers,
count(*) over (partition by t1.ProductNumber,t1.Branch_name_EN,t1.sourceIND,t1.TransactionDate,t1.supplier_ID) as cnt_levels_per_product,
			sum(t1.Revenue/t1.cnt_suppliers) over (partition by t1.SourceInd,t1.Branch_name_EN,t2.level_id) as tot_rev_BranchSourceLevel,
		case when t1.CatalogRevenue is null then NULL else (sum(t1.CatalogRevenue/t1.cnt_suppliers) over (partition by t1.SourceInd,t1.Branch_name_EN,t2.level_id)) end as tot_CatRev_BranchSourceLevel,
		t2.tot_cnt_level_products as cnt_products_in_level,
		t2.level_ID
into #subtemp1
from #temp t1
left join (select *,
					count(*) over (partition by level_ID) as tot_cnt_level_products,
					count(*) over (partition by Product_ID) as cnt_levels_per_product	
					from PG_product_substitute_levels 

) t2
on t2.product_ID=t1.ProductNumber

--Calculate for each Branch+SourceInd+level_ID the relative revenue a SUPPLIER had over all dates (aggregating it's products)
IF OBJECT_ID('tempdb..#subtemp3' ,'U') IS NOT NULL
    DROP TABLE [#subtemp3];
select t1.SUPPLIER_ID,
		t1.SourceInd,
		t1.Branch_name_EN,
		t1.level_ID,
		count(distinct t1.ProductNumber) as cnt_products_supplier_in_level,
		avg(isnull(t1.cnt_products_in_level,0)) as cnt_products_tot_in_level, /*only works well if level_ID is not NULL*/
		avg(t1.tot_rev_BranchSourceLevel) as tot_rev_BranchSourceLevel,
		case when sum(t1.tot_CatRev_BranchSourceLevel) is null then NULL else avg(t1.tot_CatRev_BranchSourceLevel) end as tot_CatRev_BranchSourceLevel,
		case  when sum(t1.tot_rev_BranchSourceLevel) is null then null 
			  when avg(t1.tot_rev_BranchSourceLevel)=0 then 0
			  else sum(case when t1.tot_rev_BranchSourceLevel=0 then 0 
							else t1.Revenue/cnt_suppliers end)/avg(t1.tot_rev_BranchSourceLevel)
			  end as perc_rev,
		case  when sum(t1.tot_CatRev_BranchSourceLevel) is null then null 
			  when AVG(t1.tot_CatRev_BranchSourceLevel)=0 then 0
			  else sum(case when t1.tot_CatRev_BranchSourceLevel=0 then 0 
							else t1.CatalogRevenue/cnt_suppliers end)/AVG(t1.tot_CatRev_BranchSourceLevel) 
			  end as perc_CatRev
into #subtemp3
from #subtemp1 t1
group by t1.SUPPLIER_ID,
		t1.SourceInd,
		t1.level_ID,
		t1.Branch_name_EN

--save
IF OBJECT_ID('dbo.GN_subgroups_supplier_dist', 'U') IS NOT NULL
    DROP TABLE dbo.GN_subgroups_supplier_dist;
select *
into dbo.GN_subgroups_supplier_dist
from #subtemp3

;
END

--**********************************************************************************************************
--**********************************************************************************************************
--*********************************CATALOG REVENUE to REGULAR REVENUE ratio**********************************
--**********************************************************************************************************
--**********************************************************************************************************

BEGIN

--Calculate the general Ratio bewteen catalog revenue and store price revenue
--This is a simplification. If we had time we would have added a supplier_ID and catalog price to the transaction table and did the same calculation Jesper did for the new table.
--Since we didn't have time we used this simplification
IF OBJECT_ID('dbo.GN_Catalog_revenue_ratio_tot', 'U') IS NOT NULL
    DROP TABLE dbo.GN_Catalog_revenue_ratio_tot;
select t1.Branch_name_EN,t1.SourceInd,
		case when sum(case when t1.CatalogRevenue is null then 0 else t1.Revenue end)=0 then 0 else sum(isnull(t1.CatalogRevenue/t1.cnt_suppliers,0))/sum(case when t1.CatalogRevenue is null then 0 else t1.Revenue/t1.cnt_suppliers end) end as catRev2Rev_Ratio
into dbo.GN_Catalog_revenue_ratio_tot
from GN_PG_sales_per_product_per_day_wo_returns_update t1
group by t1.Branch_name_EN,t1.SourceInd


IF OBJECT_ID('tempdb..#cat2rev_ratio_subgroup_level_ID' ,'U') IS NOT NULL
    DROP TABLE #cat2rev_ratio_subgroup_level_ID;
select 
		t1.level_ID,
		t2.SourceInd,
		t2.Branch_name_EN,
		sum(t2.sum_rev) as sum_rev,
		sum(t2.sum_cat_rev) as sum_cat_rev,
		count(t1.product_ID) as Num_products
into #cat2rev_ratio_subgroup_level_ID
from PG_product_substitute_levels t1
left join (select p1.ProductNumber,p1.SourceInd,p1.Branch_name_EN,
			sum(case when p1.CatalogRevenue is null then 0 else p1.Revenue/p1.cnt_suppliers end) as sum_rev,
			sum(isnull(p1.CatalogRevenue/p1.cnt_suppliers,0)) as sum_cat_rev
			from GN_PG_sales_per_product_per_day_wo_returns p1
			group by p1.ProductNumber,p1.SourceInd,p1.Branch_name_EN) t2
on t2.ProductNumber=t1.product_ID
group by t1.level_ID,t2.SourceInd,t2.Branch_name_EN


--Calculate the Ratio bewteen catalog revenue and store price revenue inside the substitution groups of each product
--Since a product can be in multiple subgroups then we do have doubles, but the assumption is that overall it will tone down
IF OBJECT_ID('dbo.GN_Catalog_revenue_ratio_subs', 'U') IS NOT NULL
    DROP TABLE dbo.GN_Catalog_revenue_ratio_subs;
select m.product_ID as ProductNumber,
		m.Branch_name_EN,
		m.SourceInd,
		case when sum(isnull(m.sum_rev,0))=0 then 0 else sum(isnull(m.sum_cat_rev,0))/sum(isnull(m.sum_rev,0)) end as catRev2Rev_Ratio
into GN_Catalog_revenue_ratio_subs
from (select t1.product_ID, t1.level_ID,
		t2.SourceInd,
		t2.Branch_name_EN,
		t2.sum_rev,
		t2.sum_cat_rev
	from PG_product_substitute_levels t1
	left join #cat2rev_ratio_subgroup_level_ID t2
	on t2.level_ID=t1.level_ID) m
group by m.product_ID,
		m.Branch_name_EN,
		m.SourceInd


;
END


-- Move sales_per_product data to history
DELETE FROM GN_PG_sales_per_product_per_day_wo_returns
WHERE TransactionDate>=dateadd(day,-28,@Start_date)
INSERT INTO GN_PG_sales_per_product_per_day_wo_returns
SELECT	 ProductNumber,
		TransactionDate,
		SourceInd,
		Branch_name_EN,
		Quantity,
		Revenue,
		CatalogPrice,
		CatalogRevenue,
		Supplier_ID,
		cnt_suppliers,
		StartDate
FROM	GN_PG_sales_per_product_per_day_wo_returns_update


;
END

