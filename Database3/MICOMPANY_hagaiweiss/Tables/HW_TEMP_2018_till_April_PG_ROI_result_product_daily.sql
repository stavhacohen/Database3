﻿CREATE TABLE [MICOMPANY\hagaiweiss].[HW_TEMP_2018_till_April_PG_ROI_result_product_daily] (
    [PromotionNumber]               BIGINT           NULL,
    [PromotionStartDate]            DATE             NULL,
    [PromotionEndDate]              DATE             NULL,
    [ProductNumber]                 BIGINT           NULL,
    [Branch_name_EN]                VARCHAR (7)      NULL,
    [SourceInd]                     INT              NULL,
    [TransactionDate]               DATE             NULL,
    [Department_name_HE]            NVARCHAR (255)   NULL,
    [Department_name_EN]            NVARCHAR (200)   NULL,
    [Subdepartment_name_HE]         NVARCHAR (255)   NULL,
    [Subdepartment_name_EN]         NVARCHAR (200)   NULL,
    [Category_name_HE]              NVARCHAR (255)   NULL,
    [Category_name_EN]              NVARCHAR (200)   NULL,
    [Group_name_HE]                 NVARCHAR (255)   NULL,
    [Group_name_EN]                 NVARCHAR (200)   NULL,
    [Subgroup_name_HE]              NVARCHAR (255)   NULL,
    [Subgroup_name_EN]              NVARCHAR (200)   NULL,
    [Product_name_HE]               NVARCHAR (255)   NULL,
    [CampaignNumberPromo]           BIGINT           NULL,
    [CampaignDesc]                  NVARCHAR (255)   NULL,
    [PromotionNumberUnv]            INT              NULL,
    [PromotionDesc]                 NVARCHAR (255)   NULL,
    [DiscountType]                  VARCHAR (25)     NULL,
    [Place_in_store]                VARCHAR (60)     NULL,
    [Folder]                        INT              NULL,
    [Multibuy_quantity]             INT              NULL,
    [Promotion_perc_running_year]   NUMERIC (24, 12) NULL,
    [Ind_in_plan]                   SMALLINT         NULL,
    [Discount]                      DECIMAL (38, 6)  NULL,
    [Real_quantity]                 DECIMAL (15, 2)  NULL,
    [Baseline_quantity]             DECIMAL (15, 2)  NULL,
    [Uplift]                        DECIMAL (33, 18) NULL,
    [Revenue_1_promotion]           DECIMAL (15, 2)  NULL,
    [Revenue_2_subs_promo]          DECIMAL (15, 2)  NULL,
    [Revenue_3_subs_group]          DECIMAL (15, 2)  NOT NULL,
    [Revenue_4_promobuyer_existing] DECIMAL (15, 2)  NOT NULL,
    [Revenue_5_promobuyer_new]      DECIMAL (15, 2)  NOT NULL,
    [Revenue_6_new_customer]        DECIMAL (15, 2)  NOT NULL,
    [Revenue_7_product_adoption]    DECIMAL (15, 2)  NOT NULL,
    [Revenue_8_hoarding]            DECIMAL (15, 2)  NOT NULL,
    [Revenue_value_effect]          DECIMAL (22, 2)  NULL,
    [Margin_1_promotion]            DECIMAL (15, 2)  NULL,
    [Margin_2_subs_promo]           DECIMAL (15, 2)  NULL,
    [Margin_3_subs_group]           DECIMAL (15, 2)  NOT NULL,
    [Margin_4_promobuyer_existing]  DECIMAL (15, 2)  NOT NULL,
    [Margin_5_promobuyer_new]       DECIMAL (15, 2)  NOT NULL,
    [Margin_6_new_customer]         DECIMAL (15, 2)  NOT NULL,
    [Margin_7_product_adoption]     DECIMAL (15, 2)  NOT NULL,
    [Margin_8_hoarding]             DECIMAL (15, 2)  NOT NULL,
    [Margin_value_effect]           DECIMAL (22, 2)  NULL,
    [Number_customers]              INT              NULL,
    [Existing_promotion_customers]  INT              NULL,
    [New_promotion_customers]       INT              NULL,
    [New_customers]                 INT              NULL,
    [Baseline_days]                 INT              NULL,
    [Valid_baseline_days]           INT              NULL,
    [Baseline_days_in_plan]         INT              NULL,
    [Ind_head_promotion]            INT              NOT NULL,
    [Ind_less_28_baseline_days]     INT              NOT NULL,
    [Ind_continuous_promotion]      INT              NOT NULL,
    [Ind_sufficient_discount]       INT              NULL,
    [Ind_uplift_flag]               INT              NOT NULL,
    [Ind_positive_subs]             TINYINT          NULL,
    [Ind_high_subs]                 TINYINT          NULL,
    [IO_indicator]                  VARCHAR (6)      NOT NULL,
    [Promotion_segment]             VARCHAR (19)     NULL
);

