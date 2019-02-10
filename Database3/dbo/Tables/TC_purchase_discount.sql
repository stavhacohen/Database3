CREATE TABLE [dbo].[TC_purchase_discount] (
    [PRODUCT]       BIGINT        NULL,
    [NAME_PRODUCT]  NVARCHAR (24) NULL,
    [SUPPLIER]      BIGINT        NULL,
    [NAME_SUPPLIER] NVARCHAR (24) NULL,
    [GROUPING]      BIGINT        NULL,
    [GROUP]         BIGINT        NULL,
    [FROM_DATE]     BIGINT        NULL,
    [TO_DATE]       BIGINT        NULL,
    [SUB_CHAIN]     BIGINT        NULL,
    [CATALOG_PRICE] FLOAT (53)    NULL,
    [DISCOUNT_PERC] FLOAT (53)    NULL,
    [NETO_PRICE]    FLOAT (53)    NULL
);

