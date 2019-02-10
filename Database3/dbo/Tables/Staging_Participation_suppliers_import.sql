CREATE TABLE [dbo].[Staging_Participation_suppliers_import] (
    [StoreFormatCode] SMALLINT       NULL,
    [StoreFormatDesc] NVARCHAR (50)  NULL,
    [ProductNumber]   BIGINT         NULL,
    [ProductDesc]     NVARCHAR (255) NULL,
    [SupplierNumber]  INT            NULL,
    [SupplierDesc]    NVARCHAR (255) NULL,
    [MonthNumber]     INT            NULL,
    [Metrics]         NVARCHAR (50)  NULL,
    [Sales]           NVARCHAR (50)  NULL,
    [PriceA]          NVARCHAR (50)  NULL,
    [PriceB]          NVARCHAR (50)  NULL,
    [Mimush]          NVARCHAR (50)  NULL,
    [Quantity]        NVARCHAR (50)  NULL
);

