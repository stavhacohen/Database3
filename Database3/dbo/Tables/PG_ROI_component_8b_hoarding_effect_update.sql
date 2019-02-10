CREATE TABLE [dbo].[PG_ROI_component_8b_hoarding_effect_update] (
    [PromotionNumber]    BIGINT          NULL,
    [PromotionStartDate] DATE            NULL,
    [PromotionEndDate]   DATE            NULL,
    [ProductNumber]      BIGINT          NULL,
    [Branch_name_EN]     VARCHAR (7)     NULL,
    [SourceInd]          INT             NULL,
    [Baseline_days]      INT             NULL,
    [Baseline_quantity]  DECIMAL (15, 2) NULL,
    [Delta_quantity]     DECIMAL (15, 2) NULL,
    [Delta_revenue]      DECIMAL (15, 2) NULL,
    [Delta_margin]       DECIMAL (15, 2) NULL
);

