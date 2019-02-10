CREATE TABLE [dbo].[PG_ROI_component_2b_standard_day] (
    [PromotionNumber]           BIGINT          NULL,
    [PromotionStartDate]        DATE            NULL,
    [PromotionEndDate]          DATE            NULL,
    [ProductNumber]             BIGINT          NULL,
    [Branch_name_EN]            VARCHAR (7)     NULL,
    [SourceInd]                 INT             NULL,
    [Baseline_days]             INT             NULL,
    [Valid_baseline_days]       INT             NULL,
    [Days_in_plan]              INT             NULL,
    [Baseline_customers]        DECIMAL (15, 2) NULL,
    [Baseline_quantity]         DECIMAL (15, 2) NULL,
    [Baseline_revenue]          DECIMAL (15, 2) NULL,
    [Baseline_margin]           DECIMAL (15, 2) NULL,
    [Ind_less_28_baseline_days] INT             NOT NULL,
    [Continuous_promotion]      INT             NOT NULL
);

