CREATE TABLE [dbo].[Staging_purchase_discount_import] (
    [ProductNumber]     BIGINT         NULL,
    [ProductDesc]       NVARCHAR (50)  NULL,
    [SupplierNumber]    INT            NULL,
    [SupplierDesc]      NVARCHAR (255) NULL,
    [Grouping]          INT            NULL,
    [Group]             INT            NULL,
    [StartDate]         INT            NULL,
    [Sub_chain]         INT            NULL,
    [Catalog_Price]     NVARCHAR (50)  NULL,
    [Discount]          NVARCHAR (50)  NULL,
    [Net_Catalog_Price] NVARCHAR (50)  NULL
);

