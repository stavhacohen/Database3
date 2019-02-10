CREATE TABLE [dbo].[PG_transactions] (
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
    ON [dbo].[PG_transactions]([HouseholdID] ASC);


GO
CREATE NONCLUSTERED INDEX [index_date]
    ON [dbo].[PG_transactions]([TransactionDate] ASC);


GO
CREATE NONCLUSTERED INDEX [index_product]
    ON [dbo].[PG_transactions]([ProductNumber] ASC);


GO
CREATE NONCLUSTERED INDEX [index_format]
    ON [dbo].[PG_transactions]([StoreFormatCode] ASC);

