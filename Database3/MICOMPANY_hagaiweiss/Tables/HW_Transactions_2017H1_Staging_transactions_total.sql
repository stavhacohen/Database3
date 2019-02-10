CREATE TABLE [MICOMPANY\hagaiweiss].[HW_Transactions_2017H1_Staging_transactions_total] (
    [#BasketID]       BIGINT     NULL,
    [HouseholdID]     BIGINT     NULL,
    [SourceInd]       SMALLINT   NULL,
    [StoreFormatCode] SMALLINT   NULL,
    [LocationID]      SMALLINT   NULL,
    [TransactionDate] DATE       NULL,
    [ProductNumber]   BIGINT     NULL,
    [NetSaleNoVAT]    FLOAT (53) NULL,
    [Quantity]        FLOAT (53) NULL,
    [ItemQuantity]    INT        NULL,
    [Price_Kg]        FLOAT (53) NULL,
    [Range_Amtttt]    FLOAT (53) NULL
);

