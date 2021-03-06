﻿







CREATE view [dbo].[vw_bulkexport_MM_Final_Weeklyupdate] as
select 
getdate() as export_date, --1
min(PromotionNumber) as PromotionNumber ,--2
PromotionNumberOriginal,--3
max(PromotionNumberUnv) as PromotionNumberUnv--4
,PromotionCharacteristicsType--5
,min(PromotionStartDate) as PromotionStartDate --6
,max(PromotionEndDate) as PromotionEndDate--7
,max([Length]) as 'Length'--8
,ProductNumber --9
--,ir.Product_name_HE
,TransactionDate--10
--,ir.Branch_name_EN
,Branch_name_EN_id --11
,SourceInd --12
--,ir.Promotion_type
,max(Promotion_type_id) as Promotion_type_id --13
--,ir.Department_name_EN
--,ir.Department_name_HE
--,ir.Subdepartment_name_EN
--,ir.Subdepartment_name_HE
--,ir.Category_name_EN
--,ir.Category_name_HE
--,ir.Group_name_EN
--,ir.Group_name_HE
--,ir.Subgroup_name_EN
--,ir.Subgroup_name_HE
,sum(Multibuy_quantity) as Multibuy_quantity --14
--,ir.Place_in_store
,max(Place_in_store_id) as Place_in_store_id --15
,max(Folder) as Folder --16
,sum(Real_quantity) as Real_quantity --17
,sum(Baseline_quantity) as Baseline_quantity --18
,sum(Uplift) as Uplift  --19
,sum(Revenue_1_promotion) as Revenue_1_promotion --20
,sum(Revenue_2_subs_promo) as Revenue_2_subs_promo --21
,sum(Revenue_3_subs_group) as Revenue_3_subs_group--22
,sum(Revenue_4_promobuyer_existing) as Revenue_4_promobuyer_existing--23
,sum(Revenue_5_promobuyer_new) as Revenue_5_promobuyer_new--24
,sum(Revenue_6_new_customer) as Revenue_6_new_customer --25
,sum(Revenue_7_product_adoption) as Revenue_7_product_adoption--26
,sum(Revenue_8_hoarding) as Revenue_8_hoarding--27
,sum(Revenue_value_effect) as Revenue_value_effect--28
,sum(Margin_1_promotion) as Margin_1_promotion--29
,sum(Margin_2_subs_promo) as Margin_2_subs_promo--30
,sum(Margin_3_subs_group) as Margin_3_subs_group--31
,sum(Margin_4_promobuyer_existing)as Margin_4_promobuyer_existing--32
,sum(Margin_5_promobuyer_new)as Margin_5_promobuyer_new--33
,sum(Margin_6_new_customer)as Margin_6_new_customer--34
,sum(Margin_7_product_adoption)as Margin_7_product_adoption--35
,sum(Margin_8_hoarding)as Margin_8_hoarding--36
,sum(Margin_value_effect)as Margin_value_effect--37
--,ir.Promotion_segment
,max(Promotion_segment_id)as Promotion_segment_id--38
,max(Promotion_price_per_product)as Promotion_price_per_product--39
,max(Regular_price_per_product)as Regular_price_per_product--40
,max(Discount)as Discount --41
,max(Promotion_margin_per_product) as Promotion_margin_per_product--42
,max(Regular_margin_per_product)as Regular_margin_per_product--43

 from 
(select 
getdate() as export_date
,ir.PromotionNumber
,PromotionNumberOriginal = Case when len(ir.PromotionNumber) >8 then left(ir.PromotionNumber,len(ir.PromotionNumber)-3) else ir.PromotionNumber END
,ir.PromotionNumberUnv
,ctype.PromotionCharacteristicsType  as PromotionCharacteristicsType
--,case when Stage.PromotionCharacteristicsType is null then ctype.PromotionCharacteristicsType else Stage.PromotionCharacteristicsType END as PromotionCharacteristicsType
--,ir.PromotionDesc
,ir.PromotionStartDate
,ir.PromotionEndDate
,ir.[Length]
,ir.ProductNumber
--,ir.Product_name_HE
,ir.TransactionDate
--,ir.Branch_name_EN
,bid.ID as 'Branch_name_EN_id' --added releaseX id
,ir.SourceInd
--,ir.Promotion_type
,ptid.ID as 'Promotion_type_id'--added releaseX id
--,ir.Department_name_EN
--,ir.Department_name_HE
--,ir.Subdepartment_name_EN
--,ir.Subdepartment_name_HE
--,ir.Category_name_EN
--,ir.Category_name_HE
--,ir.Group_name_EN
--,ir.Group_name_HE
--,ir.Subgroup_name_EN
--,ir.Subgroup_name_HE
,ir.Multibuy_quantity
--,ir.Place_in_store
,pid.ID as 'Place_in_store_id'--added releaseX id
,ir.Folder
,ir.Real_quantity
,ir.Baseline_quantity
,ir.Uplift
,ir.Revenue_1_promotion
,ir.Revenue_2_subs_promo
,ir.Revenue_3_subs_group
,ir.Revenue_4_promobuyer_existing
,ir.Revenue_5_promobuyer_new
,ir.Revenue_6_new_customer
,ir.Revenue_7_product_adoption
,ir.Revenue_8_hoarding
,ir.Revenue_value_effect
,ir.Margin_1_promotion
,ir.Margin_2_subs_promo
,ir.Margin_3_subs_group
,ir.Margin_4_promobuyer_existing
,ir.Margin_5_promobuyer_new
,ir.Margin_6_new_customer
,ir.Margin_7_product_adoption
,ir.Margin_8_hoarding
,ir.Margin_value_effect
--,ir.Promotion_segment
,segid.ID as 'Promotion_segment_id'--added releaseX id
,ir.Promotion_price_per_product
,ir.Regular_price_per_product
,ir.Discount
,ir.Promotion_margin_per_product
,ir.Regular_margin_per_product

FROM [dbo].[PG_input_RAS] ir
LEFT JOIN [dbo].[ReleaseX_BranchID] bid ON ir.Branch_name_EN = bid.NAME
LEFT JOIN [dbo].[ReleaseX_PromoType_ID] ptid ON ir.Promotion_type = ptid.NAME
LEFT JOIN [dbo].[ReleaseX_PlaceID] pid ON ir.Place_in_store = pid.NAME
LEFT JOIN [dbo].[ReleaseX_SegmentID] segid ON ir.Promotion_segment = segid.NAME
LEFT JOIN (select * from(
	select *,
	ROW_NUMBER() over(PARTITION BY PromotionNumber
								,PromotionStartDate
								,PromotionEndDate
								,ProductNumber ORDER BY PromotionNumber
													,PromotionStartDate
													,PromotionEndDate
													,ProductNumber) AS ROW_ID
	from [dbo].PG_promotions_stores ) AS ctype_temp
	WHERE ROW_ID=1 ) AS ctype
	ON Case when len(ir.PromotionNumber) >8 then left(ir.PromotionNumber,len(ir.PromotionNumber)-3) else ir.PromotionNumber END = ctype.PromotionNumber 
	AND ir.PromotionStartDate=ctype.PromotionStartDate
	AND ir.PromotionEndDate=ctype.PromotionEndDate
	AND ir.ProductNumber=ctype.ProductNumber

WHERE TransactionDate >= '2018-09-04' and TransactionDate <= '2018-09-10') as Final
group by PromotionNumberOriginal,ProductNumber,TransactionDate,SourceInd,Branch_name_EN_id,PromotionCharacteristicsType
  



















