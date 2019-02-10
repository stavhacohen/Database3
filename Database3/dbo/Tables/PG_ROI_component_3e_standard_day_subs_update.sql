CREATE TABLE [dbo].[PG_ROI_component_3e_standard_day_subs_update] (
    [PromotionNumber]     BIGINT          NULL,
    [PromotionStartDate]  DATE            NULL,
    [PromotionEndDate]    DATE            NULL,
    [ProductNumber]       BIGINT          NULL,
    [Branch_name_EN]      VARCHAR (7)     NULL,
    [SourceInd]           TINYINT         NULL,
    [Level]               VARCHAR (17)    NULL,
    [Level_ID]            INT             NULL,
    [Baseline_days]       INT             NULL,
    [Valid_baseline_days] INT             NULL,
    [Baseline_quantity]   DECIMAL (15, 2) NULL,
    [Baseline_revenue]    DECIMAL (15, 2) NULL,
    [Baseline_margin]     DECIMAL (15, 2) NULL
);

