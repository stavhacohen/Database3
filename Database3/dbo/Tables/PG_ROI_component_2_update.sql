CREATE TABLE [dbo].[PG_ROI_component_2_update] (
    [PromotionNumber]           BIGINT          NULL,
    [ProductNumber]             BIGINT          NULL,
    [PromotionStartDate]        DATE            NULL,
    [PromotionEndDate]          DATE            NULL,
    [SourceInd]                 INT             NULL,
    [Branch_name_EN]            VARCHAR (7)     NULL,
    [TransactionDate]           DATE            NULL,
    [Baseline_days]             INT             NULL,
    [Valid_baseline_days]       INT             NULL,
    [Baseline_days_in_plan]     INT             NULL,
    [Ind_head_promotion]        INT             NOT NULL,
    [Ind_continuous_promotion]  INT             NOT NULL,
    [Ind_less_28_baseline_days] INT             NOT NULL,
    [Ind_sufficient_discount]   INT             NULL,
    [Ind_uplift_flag]           INT             NOT NULL,
    [Baseline_customers]        DECIMAL (15, 2) NULL,
    [Baseline_quantity]         DECIMAL (15, 2) NULL,
    [Quantity_2_subs_promo]     DECIMAL (15, 2) NULL,
    [Revenue_2_subs_promo]      DECIMAL (15, 2) NULL,
    [Margin_2_subs_promo]       DECIMAL (15, 2) NULL
);

