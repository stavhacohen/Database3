CREATE TABLE [dbo].[MM_BaseLine_model] (
    [ProductNumber]       BIGINT          NULL,
    [TransactionDate]     DATE            NULL,
    [SourceInd]           SMALLINT        NULL,
    [Branch_name_EN]      VARCHAR (7)     NULL,
    [Number_of_customers] INT             NULL,
    [Revenue]             DECIMAL (10, 2) NULL,
    [Quantity]            DECIMAL (10, 2) NULL,
    [Margin]              DECIMAL (10, 2) NULL
);

