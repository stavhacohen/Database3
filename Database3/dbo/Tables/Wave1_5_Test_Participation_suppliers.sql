CREATE TABLE [dbo].[Wave1_5_Test_Participation_suppliers] (
    [StoreFormatCode] SMALLINT        NULL,
    [StoreFormatDesc] NVARCHAR (50)   NULL,
    [ProductNumber]   BIGINT          NULL,
    [ProductDesc]     NVARCHAR (255)  NULL,
    [SupplierNumber]  INT             NULL,
    [SupplierDesc]    NVARCHAR (255)  NULL,
    [MonthNumber]     INT             NULL,
    [Metrics]         NVARCHAR (50)   NULL,
    [Sales]           DECIMAL (10, 2) NULL,
    [PriceA]          DECIMAL (10, 2) NULL,
    [PriceB]          DECIMAL (10, 2) NULL,
    [Mimush]          DECIMAL (10, 2) NULL,
    [Quantity]        DECIMAL (10, 2) NULL,
    [import_date]     DATETIME        NOT NULL
);

