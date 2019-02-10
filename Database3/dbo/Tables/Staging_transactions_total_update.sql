CREATE TABLE [dbo].[Staging_transactions_total_update] (
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


GO
CREATE CLUSTERED INDEX [cl_index_householdID]
    ON [dbo].[Staging_transactions_total_update]([HouseholdID] ASC);


GO
CREATE NONCLUSTERED INDEX [index_productnr]
    ON [dbo].[Staging_transactions_total_update]([ProductNumber] ASC);


GO
CREATE NONCLUSTERED INDEX [index_transDate]
    ON [dbo].[Staging_transactions_total_update]([TransactionDate] ASC);

