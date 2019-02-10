CREATE TABLE [dbo].[ROI_component_2a_baseline_days_CTE] (
    [PromotionNumber]     BIGINT           NULL,
    [PromotionStartDate]  DATE             NULL,
    [PromotionEndDate]    DATE             NULL,
    [ProductNumber]       BIGINT           NULL,
    [Branch_name_EN]      VARCHAR (7)      NULL,
    [SourceInd]           INT              NULL,
    [TransactionDate]     DATE             NULL,
    [Number_of_customers] INT              NOT NULL,
    [Quantity]            DECIMAL (10, 2)  NOT NULL,
    [Revenue]             DECIMAL (10, 2)  NOT NULL,
    [Margin]              DECIMAL (10, 2)  NOT NULL,
    [correction_factor]   DECIMAL (26, 16) NULL,
    [Day_index]           BIGINT           NULL
);

