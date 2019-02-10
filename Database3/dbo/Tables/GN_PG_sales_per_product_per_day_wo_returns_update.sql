CREATE TABLE [dbo].[GN_PG_sales_per_product_per_day_wo_returns_update] (
    [ProductNumber]   BIGINT          NULL,
    [TransactionDate] DATE            NULL,
    [SourceInd]       SMALLINT        NULL,
    [Branch_name_EN]  VARCHAR (7)     NULL,
    [Quantity]        DECIMAL (10, 2) NULL,
    [Revenue]         DECIMAL (10, 2) NULL,
    [CatalogPrice]    DECIMAL (38, 6) NULL,
    [CatalogRevenue]  DECIMAL (38, 6) NULL,
    [Supplier_ID]     INT             NULL,
    [cnt_suppliers]   INT             NULL,
    [StartDate]       DATE            NULL,
    [rownum]          BIGINT          NULL
);

