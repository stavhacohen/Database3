﻿CREATE TABLE [dbo].[PG_ROI_input_ROI_explorer_2017_groceries_promotions] (
    [PromotionNumber]               BIGINT          NULL,
    [PromotionNumberOriginal]       BIGINT          NULL,
    [PromotionCharacteristicsType]  INT             NULL,
    [PromotionNumberUnv]            INT             NULL,
    [PromotionDesc]                 NVARCHAR (255)  NULL,
    [PromotionStartDate]            DATE            NULL,
    [PromotionEndDate]              DATE            NULL,
    [year]                          INT             NULL,
    [yearmonth]                     INT             NULL,
    [yearweek]                      INT             NULL,
    [Length]                        INT             NULL,
    [Sold_quantity]                 DECIMAL (38, 2) NULL,
    [Baseline_quantity]             DECIMAL (38, 2) NULL,
    [Uplift]                        DECIMAL (38, 6) NULL,
    [Department_name_EN]            NVARCHAR (200)  NULL,
    [Department_name_HE]            NVARCHAR (255)  NULL,
    [Subdepartment_name_EN]         NVARCHAR (200)  NULL,
    [Subdepartment_name_HE]         NVARCHAR (255)  NULL,
    [Category_name_EN]              NVARCHAR (200)  NULL,
    [Category_name_HE]              NVARCHAR (255)  NULL,
    [Revenue_value_effect]          DECIMAL (38, 2) NULL,
    [Margin_value_effect]           DECIMAL (38, 2) NULL,
    [Revenue_1_promotion]           DECIMAL (38, 2) NULL,
    [Revenue_2_subs_promo]          DECIMAL (38, 2) NULL,
    [Revenue_3_subs_group]          DECIMAL (38, 2) NULL,
    [Revenue_4_promobuyer_existing] DECIMAL (38, 2) NULL,
    [Revenue_5_promobuyer_new]      DECIMAL (38, 2) NULL,
    [Revenue_6_new_customer]        DECIMAL (38, 2) NULL,
    [Revenue_7_product_adoption]    DECIMAL (38, 2) NULL,
    [Revenue_8_hoarding]            DECIMAL (38, 2) NULL,
    [Margin_1_promotion]            DECIMAL (38, 2) NULL,
    [Margin_2_subs_promo]           DECIMAL (38, 2) NULL,
    [Margin_3_subs_group]           DECIMAL (38, 2) NULL,
    [Margin_4_promobuyer_existing]  DECIMAL (38, 2) NULL,
    [Margin_5_promobuyer_new]       DECIMAL (38, 2) NULL,
    [Margin_6_new_customer]         DECIMAL (38, 2) NULL,
    [Margin_7_product_adoption]     DECIMAL (38, 2) NULL,
    [Margin_8_hoarding]             DECIMAL (38, 2) NULL,
    [Deal]                          INT             NOT NULL,
    [Extra]                         INT             NOT NULL,
    [Express]                       INT             NOT NULL,
    [Sheli]                         INT             NOT NULL,
    [Organic]                       INT             NOT NULL,
    [DiscountType]                  VARCHAR (25)    NULL,
    [Promotion_segment]             VARCHAR (19)    NULL,
    [Place_in_store]                VARCHAR (53)    NOT NULL,
    [Folder]                        INT             NOT NULL,
    [Multibuy_quantity]             INT             NULL,
    [Discount]                      DECIMAL (38, 6) NULL,
    [Discount_segment]              VARCHAR (9)     NULL,
    [Discount_in_ILS]               DECIMAL (38, 6) NULL,
    [IO_indicator]                  VARCHAR (6)     NOT NULL,
    [CampaignNumberPromo]           BIGINT          NULL,
    [CampaignDesc]                  NVARCHAR (255)  NULL,
    [Brand_name]                    NVARCHAR (255)  NULL,
    [Private_label]                 INT             NULL,
    [Category_manager]              NVARCHAR (255)  NULL,
    [Supplier_ID]                   BIGINT          NULL
);

