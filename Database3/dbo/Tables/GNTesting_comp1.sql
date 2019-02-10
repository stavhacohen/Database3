CREATE TABLE [dbo].[GNTesting_comp1] (
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
    [Real_quantity]                DECIMAL (21, 2) NOT NULL,
    [Quantity_1_promotion]         DECIMAL (21, 2) NOT NULL,
    [Revenue_1_promotion]          DECIMAL (21, 2) NOT NULL,
    [Margin_1_promotion]           DECIMAL (21, 2) NOT NULL,
    [R1_2]                         DECIMAL (15, 2) NULL,
    [M1_2]                         DECIMAL (15, 2) NULL,
    [R1_3]                         DECIMAL (15, 2) NULL,
    [M1_3]                         DECIMAL (15, 2) NULL
);

