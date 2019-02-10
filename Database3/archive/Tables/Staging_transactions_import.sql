CREATE TABLE [archive].[Staging_transactions_import] (
    [meta_valid_from] DATETIME         NOT NULL,
    [meta_valid_to]   DATETIME         NOT NULL,
    [meta_id_update]  UNIQUEIDENTIFIER NULL,
    [meta_loaded]     DATETIME         NOT NULL,
    [meta_origin]     NVARCHAR (510)   NOT NULL,
    [meta_loaded_by]  [sysname]        NOT NULL,
    [#BasketID]       BIGINT           NULL,
    [HouseholdID]     BIGINT           NULL,
    [SourceInd]       SMALLINT         NULL,
    [StoreFormatCode] SMALLINT         NULL,
    [LocationID]      SMALLINT         NULL,
    [TransactionDate] NVARCHAR (255)   NULL,
    [ProductNumber]   BIGINT           NULL,
    [NetSaleNoVAT]    NVARCHAR (255)   NULL,
    [Quantity]        NVARCHAR (255)   NULL,
    [ItemQuantity]    NVARCHAR (255)   NULL,
    [Price_Kg]        NVARCHAR (255)   NULL,
    [Range_Amtttt]    NVARCHAR (255)   NULL
);

