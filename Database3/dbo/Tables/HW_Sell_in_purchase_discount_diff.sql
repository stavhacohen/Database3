CREATE TABLE [dbo].[HW_Sell_in_purchase_discount_diff] (
    [ProductNumber]     BIGINT        NULL,
    [ProductDesc]       NVARCHAR (24) NULL,
    [SupplierNumber]    INT           NULL,
    [SupplierDesc]      NVARCHAR (24) NULL,
    [Grouping]          SMALLINT      NULL,
    [Group]             SMALLINT      NULL,
    [StartDate]         INT           NULL,
    [Sub_chain]         SMALLINT      NULL,
    [Catalog_Price]     REAL          NULL,
    [Discount]          REAL          NULL,
    [Net_Catalog_Price] REAL          NULL
);

