﻿CREATE TABLE [dbo].[PG_input_RAS_LastUpdate] (
    [PromotionNumber]                    BIGINT          NULL,
    [PromotionCharacteristicsType]       INT             NULL,
    [PromotionNumberUnv]                 INT             NULL,
    [PromotionDesc]                      NVARCHAR (255)  NULL,
    [CampaignNumberPromo]                BIGINT          NULL,
    [CampaignDesc]                       NVARCHAR (255)  NULL,
    [PromotionStartDate]                 DATE            NULL,
    [PromotionEndDate]                   DATE            NULL,
    [Length]                             INT             NULL,
    [ProductNumber]                      BIGINT          NULL,
    [Product_name_HE]                    NVARCHAR (255)  NULL,
    [TransactionDate]                    DATE            NULL,
    [Branch_name_EN]                     VARCHAR (7)     NULL,
    [SourceInd]                          INT             NULL,
    [Promotion_type]                     VARCHAR (25)    NULL,
    [Department_name_EN]                 NVARCHAR (200)  NULL,
    [Department_name_HE]                 NVARCHAR (255)  NULL,
    [Subdepartment_name_EN]              NVARCHAR (200)  NULL,
    [Subdepartment_name_HE]              NVARCHAR (255)  NULL,
    [Category_name_EN]                   NVARCHAR (200)  NULL,
    [Category_name_HE]                   NVARCHAR (255)  NULL,
    [Group_name_EN]                      NVARCHAR (200)  NULL,
    [Group_name_HE]                      NVARCHAR (255)  NULL,
    [Subgroup_name_EN]                   NVARCHAR (200)  NULL,
    [Subgroup_name_HE]                   NVARCHAR (255)  NULL,
    [Multibuy_quantity]                  INT             NULL,
    [Place_in_store]                     VARCHAR (53)    NOT NULL,
    [Folder]                             INT             NOT NULL,
    [Real_quantity]                      DECIMAL (10, 2) NULL,
    [Baseline_quantity]                  DECIMAL (10, 2) NULL,
    [Uplift]                             DECIMAL (10, 2) NULL,
    [Revenue_1_promotion]                DECIMAL (10, 2) NULL,
    [Revenue_2_subs_promo]               DECIMAL (10, 2) NULL,
    [Revenue_3_subs_group]               DECIMAL (10, 2) NULL,
    [Revenue_4_promobuyer_existing]      DECIMAL (10, 2) NULL,
    [Revenue_5_promobuyer_new]           DECIMAL (10, 2) NULL,
    [Revenue_6_new_customer]             DECIMAL (10, 2) NULL,
    [Revenue_7_product_adoption]         DECIMAL (10, 2) NULL,
    [Revenue_8_hoarding]                 DECIMAL (10, 2) NULL,
    [Revenue_value_effect]               DECIMAL (10, 2) NULL,
    [Margin_1_promotion]                 DECIMAL (10, 2) NULL,
    [Margin_2_subs_promo]                DECIMAL (10, 2) NULL,
    [Margin_3_subs_group]                DECIMAL (10, 2) NULL,
    [Margin_4_promobuyer_existing]       DECIMAL (10, 2) NULL,
    [Margin_5_promobuyer_new]            DECIMAL (10, 2) NULL,
    [Margin_6_new_customer]              DECIMAL (10, 2) NULL,
    [Margin_7_product_adoption]          DECIMAL (10, 2) NULL,
    [Margin_8_hoarding]                  DECIMAL (10, 2) NULL,
    [Margin_value_effect]                DECIMAL (10, 2) NULL,
    [Promotion_segment]                  VARCHAR (19)    NULL,
    [Number_customers]                   INT             NULL,
    [Promotion_customers]                INT             NULL,
    [New_customers]                      INT             NULL,
    [Adopting_customers]                 INT             NULL,
    [Total_supplier_participation]       INT             NULL,
    [Promotion_price_per_product]        DECIMAL (10, 2) NULL,
    [Regular_price_per_product]          DECIMAL (10, 2) NULL,
    [Discount]                           DECIMAL (10, 2) NULL,
    [Promotion_margin_per_product]       DECIMAL (10, 2) NULL,
    [Regular_margin_per_product]         DECIMAL (10, 2) NULL,
    [Selling_price]                      INT             NULL,
    [Supplier_participation_per_product] INT             NULL
);

