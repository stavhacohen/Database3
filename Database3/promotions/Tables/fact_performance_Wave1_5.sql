﻿CREATE TABLE [promotions].[fact_performance_Wave1_5] (
    [measure_kpi_adopting_customers]                 INT             NULL,
    [measure_kpi_bruto_uplift_margin]                NUMERIC (18, 2) NULL,
    [measure_kpi_bruto_uplift_revenue]               NUMERIC (18, 2) NULL,
    [measure_kpi_discount]                           NUMERIC (18, 2) NULL,
    [measure_kpi_netto_uplift_margin]                NUMERIC (18, 2) NULL,
    [measure_kpi_netto_uplift_revenue]               NUMERIC (18, 2) NULL,
    [measure_kpi_new_customers]                      INT             NULL,
    [measure_kpi_number_customers]                   INT             NULL,
    [measure_kpi_promotion_customers]                INT             NULL,
    [measure_kpi_promotion_margin_per_product]       NUMERIC (18, 2) NULL,
    [measure_kpi_promotion_price_per_product]        NUMERIC (18, 2) NULL,
    [measure_kpi_regular_margin_per_product]         NUMERIC (18, 2) NULL,
    [measure_kpi_regular_price_per_product]          NUMERIC (18, 2) NULL,
    [measure_kpi_selling_price]                      NUMERIC (18, 2) NULL,
    [measure_kpi_supplier_participation_per_product] INT             NULL,
    [measure_kpi_total_supplier_participation]       INT             NULL,
    [measure_length]                                 INT             NULL,
    [measure_m1_promotion]                           NUMERIC (18, 2) NULL,
    [measure_m2_subs_promo]                          NUMERIC (18, 2) NULL,
    [measure_m3_subs_group]                          NUMERIC (18, 2) NULL,
    [measure_m4_promobuyer_existing]                 NUMERIC (18, 2) NULL,
    [measure_m5_promobuyer_new]                      NUMERIC (18, 2) NULL,
    [measure_m6_new_customer]                        NUMERIC (18, 2) NULL,
    [measure_m7_product_adoption]                    NUMERIC (18, 2) NULL,
    [measure_m8_hoarding]                            NUMERIC (18, 2) NULL,
    [measure_margin_value_effect]                    NUMERIC (18, 2) NULL,
    [measure_quantity_baseline]                      NUMERIC (18, 2) NULL,
    [measure_quantity_real]                          NUMERIC (18, 2) NULL,
    [measure_r1_promotion]                           NUMERIC (18, 2) NULL,
    [measure_r2_subs_promo]                          NUMERIC (18, 2) NULL,
    [measure_r3_subs_group]                          NUMERIC (18, 2) NULL,
    [measure_r4_promobuyer_existing]                 NUMERIC (18, 2) NULL,
    [measure_r5_promobuyer_new]                      NUMERIC (18, 2) NULL,
    [measure_r6_new_customer]                        NUMERIC (18, 2) NULL,
    [measure_r7_product_adoption]                    NUMERIC (18, 2) NULL,
    [measure_r8_hoarding]                            NUMERIC (18, 2) NULL,
    [measure_revenue_value_effect]                   NUMERIC (18, 2) NULL,
    [measure_m9_discarded_products]                  NUMERIC (18, 2) NULL,
    [measure_r9_discarded_products]                  NUMERIC (18, 2) NULL,
    [id_campaign]                                    INT             NOT NULL,
    [id_date]                                        INT             NOT NULL,
    [id_date_next_year]                              INT             NOT NULL,
    [id_date_last_year]                              INT             NOT NULL,
    [id_format]                                      INT             NOT NULL,
    [id_kpi_promotion_segment]                       INT             NOT NULL,
    [id_place_in_store]                              INT             NOT NULL,
    [id_product]                                     INT             NOT NULL,
    [id_product_category]                            INT             NOT NULL,
    [id_promotion]                                   INT             NOT NULL,
    [id_promotion_end]                               INT             NOT NULL,
    [id_promotion_start]                             INT             NOT NULL,
    [id_promotion_type]                              INT             NOT NULL,
    [id_meta_load_date]                              INT             NOT NULL,
    [measure_revenue_value_effect_Cat]               NUMERIC (18, 2) NULL,
    [measure_r9_discarded_products_Cat]              NUMERIC (18, 2) NULL,
    [measure_r8_hoarding_Cat]                        NUMERIC (18, 2) NULL,
    [measure_r7_product_adoption_Cat]                NUMERIC (18, 2) NULL,
    [measure_r6_new_customer_Cat]                    NUMERIC (18, 2) NULL,
    [measure_r5_promobuyer_new_Cat]                  NUMERIC (18, 2) NULL,
    [measure_r4_promobuyer_existing_Cat]             NUMERIC (18, 2) NULL,
    [measure_r3_subs_group_Cat]                      NUMERIC (18, 2) NULL,
    [measure_r2_subs_promo_Cat]                      NUMERIC (18, 2) NULL,
    [measure_r1_promotion_Cat]                       NUMERIC (18, 2) NULL,
    [measure_Distributed_Baseline_Quantity]          NUMERIC (18, 2) NULL,
    [measure_Distributed_Real_Quantity]              NUMERIC (18, 2) NULL,
    [id_Supplier]                                    BIGINT          NULL,
    [measure_kpi_sell_out_promotion]                 NUMERIC (18, 5) NULL,
    [measure_kpi_sell_out_product]                   NUMERIC (18, 5) NULL,
    [measure_kpi_sell_in_discount]                   NUMERIC (18, 5) NULL,
    [measure_Net_Value_Cat]                          NUMERIC (18, 2) NULL,
    [measure_Tot_Participation_Cat]                  NUMERIC (18, 2) NULL,
    [measure_cnt_suppliers]                          INT             NULL,
    [id_kpi_supplier_segment]                        INT             NULL,
    [id_kpi_supplier_matrix_segment]                 INT             NULL
);

