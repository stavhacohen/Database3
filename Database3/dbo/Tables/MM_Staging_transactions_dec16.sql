CREATE TABLE [dbo].[MM_Staging_transactions_dec16] (
    [#BasketID]       BIGINT         NULL,
    [HouseholdID]     BIGINT         NULL,
    [SourceInd]       SMALLINT       NULL,
    [StoreFormatCode] SMALLINT       NULL,
    [LocationID]      SMALLINT       NULL,
    [TransactionDate] NVARCHAR (255) NULL,
    [ProductNumber]   BIGINT         NULL,
    [NetSaleNoVAT]    NVARCHAR (255) NULL,
    [Quantity]        NVARCHAR (255) NULL,
    [ItemQuantity]    NVARCHAR (255) NULL,
    [Price_Kg]        NVARCHAR (255) NULL,
    [Range_Amtttt]    NVARCHAR (255) NULL
);

