﻿CREATE TABLE [dbo].[Staging_supplier_billing_in_sales_TOT] (
    [DISCOUNT_ID]            INT           NULL,
    [DISCOUNT_DESC]          NVARCHAR (50) NULL,
    [DATE_FROM]              INT           NULL,
    [DATE_TO]                INT           NULL,
    [SUPPLIER_ID]            INT           NULL,
    [SUPPLIER_NAME]          NVARCHAR (28) NULL,
    [MONTH]                  INT           NULL,
    [FORMAT_ID]              SMALLINT      NULL,
    [FORMAT_NAME]            NVARCHAR (50) NULL,
    [PRODUCT_ID]             BIGINT        NULL,
    [PRODUCT_DESC]           NVARCHAR (29) NULL,
    [TOTAL_SALES]            REAL          NULL,
    [SUPPLIER_PARTICIPATION] REAL          NULL
);

