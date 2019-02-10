CREATE TABLE [dbo].[PG_Participation_suppliers] (
    [StoreFormatCode] SMALLINT         NULL,
    [StoreFormatDesc] NVARCHAR (50)    NULL,
    [ProductNumber]   BIGINT           NULL,
    [ProductDesc]     NVARCHAR (255)   NULL,
    [SupplierNumber]  INT              NULL,
    [SupplierDesc]    NVARCHAR (255)   NULL,
    [MonthNumber]     INT              NULL,
    [Metrics]         NVARCHAR (50)    NULL,
    [Sales]           DECIMAL (36, 24) NULL,
    [PriceA]          DECIMAL (36, 24) NULL,
    [PriceB]          DECIMAL (36, 24) NULL,
    [Mimush]          DECIMAL (36, 24) NULL,
    [Quantity]        DECIMAL (10, 2)  NULL,
    [import_date]     DATETIME         NOT NULL
);

