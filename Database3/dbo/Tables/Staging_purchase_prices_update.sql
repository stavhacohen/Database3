CREATE TABLE [dbo].[Staging_purchase_prices_update] (
    [PRODUCT]       BIGINT        NULL,
    [NAME_PRODUCT]  NVARCHAR (50) NULL,
    [SUPPLIER]      BIGINT        NULL,
    [NAME_SUPPLIER] NVARCHAR (50) NULL,
    [GROUPING]      BIGINT        NULL,
    [GROUP]         BIGINT        NULL,
    [FROM_DATE]     BIGINT        NULL,
    [TO_DATE]       BIGINT        NULL,
    [SUB_CHAIN]     BIGINT        NULL,
    [CATALOG_PRICE] FLOAT (53)    NULL,
    [DISCOUNT_PERC] FLOAT (53)    NULL,
    [NET_PRICE]     FLOAT (53)    NULL
);

