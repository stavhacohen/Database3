CREATE TABLE [dbo].[HW_Staging_catalog_product_prices_b] (
    [ProductNumber]          BIGINT        NULL,
    [From_Date]              INT           NULL,
    [To_Date]                INT           NULL,
    [Format]                 SMALLINT      NULL,
    [Supplier]               INT           NULL,
    [Purchase_Catalog_Price] NVARCHAR (50) NULL,
    [Catalog_Basic_Price]    NVARCHAR (50) NULL
);

