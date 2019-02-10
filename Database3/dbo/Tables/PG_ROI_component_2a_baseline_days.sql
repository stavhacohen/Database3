CREATE TABLE [dbo].[PG_ROI_component_2a_baseline_days] (
    [PromotionNumber]         BIGINT          NULL,
    [PromotionStartDate]      DATE            NULL,
    [PromotionEndDate]        DATE            NULL,
    [ProductNumber]           BIGINT          NULL,
    [Branch_name_EN]          VARCHAR (7)     NULL,
    [SourceInd]               INT             NULL,
    [TransactionDate]         DATE            NULL,
    [Number_of_customers]     INT             NOT NULL,
    [Quantity]                DECIMAL (15, 2) NULL,
    [Revenue]                 DECIMAL (15, 2) NULL,
    [Margin]                  DECIMAL (15, 2) NULL,
    [correction_factor]       DECIMAL (10, 4) NULL,
    [Day_index]               BIGINT          NULL,
    [avg_number_of_customers] DECIMAL (15, 2) NULL,
    [avg_quantity]            DECIMAL (15, 2) NULL,
    [avg_revenue]             DECIMAL (15, 2) NULL,
    [avg_margin]              DECIMAL (15, 2) NULL,
    [stdevp_quantity]         DECIMAL (15, 2) NULL,
    [Valid_ind]               INT             NOT NULL,
    [Ind_in_plan]             SMALLINT        NULL,
    [Continuous_promotion]    INT             NOT NULL
);

