CREATE TABLE [dbo].[MM_FIX_PG_ROI_component_1] (
    [PromotionNumber]              BIGINT          NULL,
    [PromotionCharacteristicsType] INT             NULL,
    [ProductNumber]                BIGINT          NULL,
    [PromotionStartDate]           DATE            NULL,
    [PromotionEndDate]             DATE            NULL,
    [SourceInd]                    INT             NULL,
    [Branch_name_EN]               VARCHAR (7)     NULL,
    [TransactionDate]              DATE            NULL,
    [Ind_head_promotion]           INT             NOT NULL,
    [Number_of_customers]          INT             NOT NULL,
    [Real_quantity]                DECIMAL (15, 2) NULL,
    [Quantity_1_promotion]         DECIMAL (15, 2) NULL,
    [Revenue_1_promotion]          DECIMAL (15, 2) NULL,
    [Margin_1_promotion]           DECIMAL (15, 2) NULL
);

