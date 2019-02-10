CREATE TABLE [dbo].[HW_Catalog_Supplier_recent] (
    [ProductNumber]    BIGINT        NULL,
    [StartDate]        DATE          NULL,
    [EndDate]          DATE          NULL,
    [Format]           SMALLINT      NULL,
    [Supplier]         INT           NULL,
    [Catalog_Price]    NVARCHAR (50) NULL,
    [Irrelevant_Price] NVARCHAR (50) NULL
);

