CREATE TABLE [dbo].[Wave1_5_Test_Supplier_list] (
    [ProductNumber]     BIGINT         NULL,
    [ProductDesc]       NVARCHAR (50)  NULL,
    [SupplierNumber]    INT            NULL,
    [SupplierDesc]      NVARCHAR (255) NULL,
    [Grouping]          INT            NULL,
    [Group]             INT            NULL,
    [StartDate]         DATE           NULL,
    [Sub_chain]         INT            NULL,
    [Catalog_Price]     DECIMAL (9, 2) NULL,
    [Discount]          DECIMAL (9, 2) NULL,
    [Net_Catalog_Price] DECIMAL (9, 2) NULL,
    [rnum]              BIGINT         NULL
);

