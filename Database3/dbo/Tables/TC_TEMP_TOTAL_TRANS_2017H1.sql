CREATE TABLE [dbo].[TC_TEMP_TOTAL_TRANS_2017H1] (
    [PromotionNumber]     BIGINT          NULL,
    [PromotionStartDate]  DATE            NULL,
    [PromotionEndDate]    DATE            NULL,
    [Multibuy_quantity]   INT             NULL,
    [ProductNumber]       BIGINT          NULL,
    [SourceInd]           SMALLINT        NULL,
    [Branch_name_EN]      VARCHAR (7)     NULL,
    [TransactionDate]     DATE            NULL,
    [Number_of_customers] INT             NOT NULL,
    [Real_quantity]       DECIMAL (10, 2) NOT NULL,
    [Quantity]            DECIMAL (10, 2) NOT NULL,
    [Revenue]             DECIMAL (10, 2) NOT NULL,
    [Margin]              DECIMAL (10, 2) NOT NULL
);

