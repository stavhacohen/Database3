



















CREATE VIEW [promotions].[dimensional_model_date_test_wave1_5]
AS
-- TODO: remove hardcode product hierarchy
SELECT pro.NAME Promotion_name
	,pro.business_id Promotion_business_id
	,pro.business_id Promotion_universal_id
	,cam.id_campaign Campaign_id
	,seg.NAME Promotion_segment
	,prot.NAME Promotion_type
	,frm.name_EN [Format]
	,dep.name_EN Product_department
	,cat.name_EN Product_category
	,grp.name_EN Product_group
	,subgrp.name_EN Product_subgroup
	,pis.name Place_in_store
	,pstart.[date] Promotion_start
	,pend.[date] Promotion_end
	,fct.measure_length Promotion_duration
	,CASE 
		WHEN pend.[date] >= GETDATE()
			THEN 'Running'
		WHEN pend.[date] BETWEEN DATEADD(dd, - 28, getdate())
				AND GETDATE()
			THEN 'completed <=4 weeks ago'
		ELSE 'completed > 4 weeks ago'
		END Promotion_status
	,prd.NAME Product_name
	,prd.business_id Product_number
	,dte.[date] [date]
	,nydte.[date] date_next_year
	,pydte.[date] date_last_year
	,fct.measure_revenue_value_effect Revenue_value_effect
	,fct.measure_r9_discarded_products R9_discarded_products
	,fct.measure_r8_hoarding R8_hoarding
	,fct.measure_r7_product_adoption R7_Product_adoption
	,fct.measure_r6_new_customer R6_New_customer
	,fct.measure_r5_promobuyer_new R5_Promobuyer_new
	,fct.measure_r4_promobuyer_existing R4_Promobuyer_existing
	,fct.measure_r3_subs_group R3_Subs_group
	,fct.measure_r2_subs_promo R2_Subs_promo
	,fct.measure_r1_promotion R1_Promotion
	,fct.measure_margin_value_effect Margin_value_effect
	,fct.measure_m9_discarded_products m9_discarded_products
	,fct.measure_m8_hoarding M8_Hoarding
	,fct.measure_m7_product_adoption M7_Product_adoption
	,fct.measure_m6_new_customer M6_New_customer
	,fct.measure_m5_promobuyer_new M5_Promobuyer_new
	,fct.measure_m4_promobuyer_existing M4_Promobuyer_existing
	,fct.measure_m3_subs_group M3_Subs_group
	,fct.measure_m2_subs_promo M2_Subs_promo
	,fct.measure_m1_promotion M1_Promotion
	,fct.measure_kpi_supplier_participation_per_product Supplier_participation
	,fct.measure_kpi_selling_price Selling_price
	,fct.measure_kpi_regular_price_per_product Regular_price
	,fct.measure_kpi_discount Discount
	,fct.measure_kpi_regular_margin_per_product Regular_margin
	,fct.measure_kpi_promotion_price_per_product Promotion_price
	,fct.measure_kpi_promotion_margin_per_product Promotion_margin
	,fct.measure_kpi_promotion_customers Promotion_customers
	,fct.measure_kpi_number_customers Regular_customers
	,fct.measure_kpi_new_customers New_customers
	,fct.measure_kpi_adopting_customers Adopting_customers
	,fct.measure_kpi_bruto_uplift_revenue Bruto_uplift_revenue
	,fct.measure_kpi_netto_uplift_revenue Netto_uplift_revenue
	,fct.measure_kpi_bruto_uplift_margin Bruto_uplift_margin
	,fct.measure_kpi_netto_uplift_margin Netto_uplift_margin
	,fct.measure_kpi_total_supplier_participation Average_supplier_participation
	,fct.measure_quantity_baseline Quantity_baseline
	,fct.measure_quantity_real Quantity_sales
	,CASE 
		WHEN fct.measure_quantity_baseline <> 0
			THEN fct.measure_quantity_real/fct.measure_quantity_baseline
		ELSE NULL
		END AS Uplift
	,CONVERT(NVARCHAR(255),pro.business_id) + ' - ' + pro.name Promotion_name_id,
	fct.id_date
	,fct.id_promotion as id_promotion
	,fct.id_product as id_product
	,fct.id_product_category as id_subgroup
	,dep.id_product_category as id_department
	,sup.business_supplier_id as id_Supplier
	,sup.NAME as supplier_name
	,fct.measure_revenue_value_effect_Cat as measure_revenue_value_effect_Cat
      ,fct.measure_r9_discarded_products_Cat as measure_r9_discarded_products_Cat
      ,fct.measure_r8_hoarding_Cat as measure_r8_hoarding_Cat
      ,fct.measure_r7_product_adoption_Cat as measure_r7_product_adoption_Cat
      ,fct.measure_r6_new_customer_Cat as measure_r6_new_customer_Cat
      ,fct.measure_r5_promobuyer_new_Cat as measure_r5_promobuyer_new_Cat
      ,fct.measure_r4_promobuyer_existing_Cat as measure_r4_promobuyer_existing_Cat
      ,fct.measure_r3_subs_group_Cat as measure_r3_subs_group_Cat
      ,fct.measure_r2_subs_promo_Cat as measure_r2_subs_promo_Cat
      ,fct.measure_r1_promotion_Cat as measure_r1_promotion_Cat
      ,fct.measure_Distributed_Baseline_Quantity as measure_Distributed_Baseline_Quantity
      ,fct.measure_Distributed_Real_Quantity as measure_Distributed_Real_Quantity
      ,fct.measure_kpi_sell_out_promotion as measure_kpi_sell_out_promotion
      ,fct.measure_kpi_sell_out_product as measure_kpi_sell_out_product
      ,fct.measure_kpi_sell_in_discount as measure_kpi_sell_in_discount
      ,fct.measure_Net_Value_Cat as measure_Net_Value_Catv
      ,fct.measure_Tot_Participation_Cat as measure_Tot_Participation_Cat
	  --,sup_mat_seg.name as supplier_matrix_segment
	  ,LOWER(REPLACE(sup_mat_seg.name, '-', '_'))  as supplier_matrix_segment
	  --, 'win_win' as supplier_matrix_segment
	  --, CASE WHEN sup.business_supplier_id%2=0 THEN 'win_win' ELSE 'lose_lose' end as supplier_matrix_segment
	--,sup_seg.name as supplier_segment

FROM [promotions].[fact_performance_Wave1_5] fct
LEFT JOIN [promotions].[dim_campaign_Wave1_5] cam ON fct.id_campaign = cam.id_campaign
LEFT JOIN [promotions].[dim_date_Wave1_5] dte ON fct.id_date = dte.id_date
LEFT JOIN [promotions].[dim_format_Wave1_5] frm ON fct.id_format = frm.id_format
LEFT JOIN [promotions].[dim_place_in_store_Wave1_5] pis ON fct.id_place_in_store = pis.id_place_in_store
LEFT JOIN [promotions].[dim_product_Wave1_5] prd ON fct.id_product = prd.id_product
LEFT JOIN [promotions].[dim_promotion_Wave1_5] pro ON fct.id_promotion = pro.id_promotion
LEFT JOIN [promotions].[dim_promotion_type_Wave1_5] prot ON fct.id_promotion_type = prot.id_promotion_type
LEFT JOIN [promotions].[dim_promotion_segment_Wave1_5] seg ON fct.id_kpi_promotion_segment = seg.id_promotion_segment
LEFT JOIN [promotions].[dim_product_category_Wave1_5] subgrp ON fct.id_product_category = subgrp.id_product_category
LEFT JOIN [promotions].[dim_product_category_Wave1_5] grp ON subgrp.parent_id = grp.id_product_category
LEFT JOIN [promotions].[dim_product_category_Wave1_5] cat ON grp.parent_id = cat.id_product_category
LEFT JOIN [promotions].[dim_product_category_Wave1_5] dep ON cat.parent_id = dep.id_product_category
LEFT JOIN [promotions].[dim_date_Wave1_5] pstart ON fct.id_promotion_start = pstart.id_date
LEFT JOIN [promotions].[dim_date_Wave1_5] pend ON fct.id_promotion_end = pend.id_date
LEFT JOIN [promotions].[dim_date_Wave1_5] nydte ON fct.id_date_next_year = nydte.id_date
LEFT JOIN [promotions].[dim_date_Wave1_5] pydte ON fct.id_date_last_year = pydte.id_date
LEFT JOIN [promotions].[dim_supplier_Wave1_5] sup on fct.id_Supplier = sup.id_supplier
left join [promotions].[dim_Supplier_Matrix_segment_Wave1_5] sup_mat_seg on fct.id_kpi_supplier_matrix_segment=sup_mat_seg.id_supplier_matrix_segment
left join [promotions].[dim_Supplier_segment_Wave1_5] sup_seg on fct.id_kpi_supplier_segment=sup_seg.id_supplier_segment






















