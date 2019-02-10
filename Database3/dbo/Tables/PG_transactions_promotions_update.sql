CREATE TABLE [dbo].[PG_transactions_promotions_update] (
    [ProductNumber]   BIGINT          NULL,
    [HouseholdID]     BIGINT          NULL,
    [TransactionDate] DATE            NULL,
    [Branch_name_EN]  VARCHAR (7)     NULL,
    [SourceInd]       SMALLINT        NULL,
    [Quantity]        DECIMAL (15, 2) NULL,
    [Revenue]         DECIMAL (15, 2) NULL,
    [Margin]          DECIMAL (15, 2) NULL
);

