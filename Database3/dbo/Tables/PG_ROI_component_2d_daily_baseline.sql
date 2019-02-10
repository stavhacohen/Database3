CREATE TABLE [dbo].[PG_ROI_component_2d_daily_baseline] (
    [PromotionNumber]           BIGINT          NULL,
    [PromotionStartDate]        DATE            NULL,
    [PromotionEndDate]          DATE            NULL,
    [ProductNumber]             BIGINT          NULL,
    [Branch_name_EN]            VARCHAR (7)     NULL,
    [SourceInd]                 INT             NULL,
    [TransactionDate]           DATE            NULL,
    [Baseline_days]             INT             NULL,
    [Valid_baseline_days]       INT             NULL,
    [Days_in_plan]              INT             NULL,
    [Ind_head_promotion]        INT             NOT NULL,
    [Baseline_customers]        DECIMAL (15, 2) NULL,
    [Baseline_quantity]         DECIMAL (15, 2) NULL,
    [Quantity_2_subs_promo]     DECIMAL (15, 2) NULL,
    [Revenue_2_subs_promo]      DECIMAL (15, 2) NULL,
    [Margin_2_subs_promo]       DECIMAL (15, 2) NULL,
    [Ind_continuous_promotion]  INT             NOT NULL,
    [Ind_less_28_baseline_days] INT             NOT NULL
);

