CREATE TABLE [dbo].[GN_PG_ROI_component_3d_baseline_days_subs_update] (
    [PromotionNumber]    BIGINT          NULL,
    [PromotionStartDate] DATE            NULL,
    [PromotionEndDate]   DATE            NULL,
    [ProductNumber]      BIGINT          NULL,
    [Branch_name_EN]     VARCHAR (7)     NULL,
    [SourceInd]          SMALLINT        NULL,
    [TransactionDate]    DATE            NULL,
    [Level]              VARCHAR (10)    NULL,
    [Level_ID]           INT             NULL,
    [Quantity]           DECIMAL (15, 2) NULL,
    [Revenue]            DECIMAL (15, 2) NULL,
    [Margin]             DECIMAL (15, 2) NULL,
    [correction_factor]  DECIMAL (15, 2) NULL,
    [Day_index]          SMALLINT        NULL,
    [avg_quantity]       DECIMAL (15, 2) NULL,
    [avg_revenue]        DECIMAL (15, 2) NULL,
    [avg_margin]         DECIMAL (15, 2) NULL,
    [stdevp_quantity]    DECIMAL (15, 2) NULL,
    [valid_ind]          SMALLINT        NULL
);

