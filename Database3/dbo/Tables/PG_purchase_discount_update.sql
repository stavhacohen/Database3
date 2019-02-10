CREATE TABLE [dbo].[PG_purchase_discount_update] (
    [ProductNumber]     BIGINT          NULL,
    [ProductDesc]       NVARCHAR (50)   NULL,
    [SupplierNumber]    INT             NULL,
    [SupplierDesc]      NVARCHAR (255)  NULL,
    [Grouping]          INT             NULL,
    [Group]             INT             NULL,
    [StartDate]         DATE            NULL,
    [Sub_chain]         INT             NULL,
    [Catalog_Price]     DECIMAL (10, 2) NULL,
    [Discount]          DECIMAL (10, 2) NULL,
    [Net_Catalog_Price] DECIMAL (10, 2) NULL
);

