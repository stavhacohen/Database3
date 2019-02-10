﻿CREATE TABLE [tmp].[testset] (
    [date]                               DATETIME       NULL,
    [format]                             NVARCHAR (255) NULL,
    [place_in_store]                     NVARCHAR (255) NULL,
    [promotion_segment]                  NVARCHAR (255) NULL,
    [department]                         NVARCHAR (255) NULL,
    [subdepartment]                      NVARCHAR (255) NULL,
    [category]                           NVARCHAR (255) NULL,
    [group]                              NVARCHAR (255) NULL,
    [subgroup]                           NVARCHAR (255) NULL,
    [promotion_number]                   FLOAT (53)     NULL,
    [Revenue_1_promotion]                FLOAT (53)     NULL,
    [Revenue_2_subs_promo]               FLOAT (53)     NULL,
    [Revenue_3_subs_group]               FLOAT (53)     NULL,
    [Revenue_4_promobuyer_existing]      FLOAT (53)     NULL,
    [Revenue_5_promobuyer_new]           FLOAT (53)     NULL,
    [Revenue_6_new_customer]             FLOAT (53)     NULL,
    [Revenue_7_product_adoption]         FLOAT (53)     NULL,
    [Revenue_8_hoarding]                 FLOAT (53)     NULL,
    [Revenue_value_effect]               FLOAT (53)     NULL,
    [Margin_1_promotion]                 FLOAT (53)     NULL,
    [Margin_2_subs_promo]                FLOAT (53)     NULL,
    [Margin_3_subs_group]                FLOAT (53)     NULL,
    [Margin_4_promobuyer_existing]       FLOAT (53)     NULL,
    [Margin_5_promobuyer_new]            FLOAT (53)     NULL,
    [Margin_6_new_customer]              FLOAT (53)     NULL,
    [Margin_7_product_adoption]          FLOAT (53)     NULL,
    [Margin_8_hoarding]                  FLOAT (53)     NULL,
    [Margin_value_effect]                FLOAT (53)     NULL,
    [KPI_Revenue_value_effect]           FLOAT (53)     NULL,
    [KPI_Sold_quantity]                  FLOAT (53)     NULL,
    [KPI_Number_products]                FLOAT (53)     NULL,
    [KPI_Number_customers]               FLOAT (53)     NULL,
    [KPI_Promotion_customers]            FLOAT (53)     NULL,
    [KPI_New_customers]                  FLOAT (53)     NULL,
    [KPI_Adopting_customers]             FLOAT (53)     NULL,
    [KPI_Average_selling_price]          FLOAT (53)     NULL,
    [KPI_Average_margin]                 FLOAT (53)     NULL,
    [KPI_Average_buying_price]           FLOAT (53)     NULL,
    [KPI_Average_supplier_participation] FLOAT (53)     NULL,
    [KPI_Bruto_uplift_quantity]          FLOAT (53)     NULL,
    [KPI_Bruto_uplift_revenue]           FLOAT (53)     NULL,
    [KPI_Netto_uplift_revenue]           FLOAT (53)     NULL,
    [KPI_Bruto_uplift_margin]            FLOAT (53)     NULL,
    [KPI_Netto_uplift_margin]            FLOAT (53)     NULL,
    [promotion_type]                     NVARCHAR (255) NULL
);

