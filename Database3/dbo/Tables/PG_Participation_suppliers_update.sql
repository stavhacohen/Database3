CREATE TABLE [dbo].[PG_Participation_suppliers_update] (
    [StoreFormatCode] SMALLINT         NULL,
    [StoreFormatDesc] NVARCHAR (50)    NULL,
    [ProductNumber]   BIGINT           NULL,
    [ProductDesc]     NVARCHAR (255)   NULL,
    [SupplierNumber]  INT              NULL,
    [SupplierDesc]    NVARCHAR (255)   NULL,
    [MonthNumber]     INT              NULL,
    [Metrics]         NVARCHAR (50)    NULL,
    [Sales]           DECIMAL (23, 13) NULL,
    [PriceA]          DECIMAL (23, 13) NULL,
    [PriceB]          DECIMAL (23, 13) NULL,
    [Mimush]          DECIMAL (23, 13) NULL,
    [Quantity]        DECIMAL (10, 2)  NULL
);

