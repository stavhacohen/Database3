CREATE TABLE [dbo].[HW_Staging_Catalog_product_prices_a] (
    [ProductNumber]          BIGINT        NULL,
    [From Date]              INT           NULL,
    [To Date]                INT           NULL,
    [Format]                 SMALLINT      NULL,
    [Supplier]               INT           NULL,
    [Purchase Catalog Price] NVARCHAR (50) NULL,
    [Catalog Basic Price]    NVARCHAR (50) NULL
);

