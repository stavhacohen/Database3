CREATE TABLE [dbo].[GN_PG_ROI_component_3f_baseline_subs_daily_update] (
    [ProductNumber]           BIGINT          NULL,
    [Branch_name_EN]          VARCHAR (7)     NULL,
    [SourceInd]               SMALLINT        NULL,
    [TransactionDate]         DATE            NULL,
    [Level]                   VARCHAR (17)    NULL,
    [Level_ID]                INT             NULL,
    [Avg_baseline_days]       DECIMAL (15, 2) NULL,
    [Avg_valid_baseline_days] DECIMAL (15, 2) NULL,
    [Baseline_quantity]       DECIMAL (15, 2) NULL,
    [Baseline_revenue]        DECIMAL (15, 2) NULL,
    [Baseline_margin]         DECIMAL (15, 2) NULL,
    [Delta_quantity]          DECIMAL (15, 2) NULL,
    [Delta_revenue]           DECIMAL (15, 2) NULL,
    [Delta_margin]            DECIMAL (15, 2) NULL
);

