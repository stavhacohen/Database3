CREATE TABLE [dbo].[GN_PG_sales_per_product_per_day_wo_returns] (
    [Branch_name_EN]  VARCHAR (7)     NULL,
    [ProductNumber]   BIGINT          NULL,
    [Quantity]        DECIMAL (10, 2) NULL,
    [Revenue]         DECIMAL (10, 2) NULL,
    [rownum]          BIGINT          NULL,
    [SourceInd]       SMALLINT        NULL,
    [TransactionDate] DATE            NULL,
    [cnt_suppliers]   INT             NOT NULL,
    [Supplier_ID]     INT             NULL,
    [CatalogPrice]    NUMERIC (38, 6) NULL,
    [CatalogRevenue]  NUMERIC (38, 6) NULL
);

