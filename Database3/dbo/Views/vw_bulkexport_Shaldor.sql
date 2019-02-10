






CREATE view [dbo].[vw_bulkexport_Shaldor] as
select 
getdate() as export_date
,ir.PromotionNumber
,ir.PromotionNumberUnv
,ir.PromotionDesc
,ir.PromotionStartDate
,ir.PromotionEndDate
,ir.[Length]
,ir.ProductNumber
,ir.Product_name_HE
,ir.TransactionDate
,ir.Branch_name_EN
--,bid.ID as 'Branch_name_EN_id' --added releaseX id
,ir.SourceInd
,ir.Promotion_type
--,ptid.ID as 'Promotion_type_id'--added releaseX id
,ir.Department_name_EN
,ir.Department_name_HE
,ir.Subdepartment_name_EN
,ir.Subdepartment_name_HE
,ir.Category_name_EN
,ir.Category_name_HE
,ir.Group_name_EN
,ir.Group_name_HE
,ir.Subgroup_name_EN
,ir.Subgroup_name_HE
,ir.Multibuy_quantity
,ir.Place_in_store
--,pid.ID as 'Place_in_store_id'--added releaseX id
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
,ir.Promotion_segment
--,segid.ID as 'Promotion_segment_id'--added releaseX id
,ir.Promotion_price_per_product
,ir.Regular_price_per_product
,ir.Discount
,ir.Promotion_margin_per_product
,ir.Regular_margin_per_product

FROM [dbo].[PG_input_RAS] ir
--LEFT JOIN [dbo].[ReleaseX_BranchID] bid ON ir.Branch_name_EN = bid.NAME
--LEFT JOIN [dbo].[ReleaseX_PromoType_ID] ptid ON ir.Promotion_type = ptid.NAME
--LEFT JOIN [dbo].[ReleaseX_PlaceID] pid ON ir.Place_in_store = pid.NAME
--LEFT JOIN [dbo].[ReleaseX_SegmentID] segid ON ir.Promotion_segment = segid.NAME
WHERE TransactionDate >= '2017-05-27'
  





