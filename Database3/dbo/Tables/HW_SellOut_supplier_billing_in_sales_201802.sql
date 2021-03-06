﻿CREATE TABLE [dbo].[HW_SellOut_supplier_billing_in_sales_201802] (
    [DISCOUNT_ID]            INT           NULL,
    [DISCOUNT_DESC]          NVARCHAR (40) NULL,
    [DATE_FROM]              INT           NULL,
    [DATE_TO]                INT           NULL,
    [SUPPLIER_ID]            INT           NULL,
    [SUPPLIER_NAME]          NVARCHAR (24) NULL,
    [MONTH]                  INT           NULL,
    [FORMAT_ID]              SMALLINT      NULL,
    [FORMAT_NAME]            NVARCHAR (16) NULL,
    [PRODUCT_ID]             BIGINT        NULL,
    [PRODUCT_DESC]           NVARCHAR (24) NULL,
    [TOTAL_SALES]            REAL          NULL,
    [SUPPLIER_PARTICIPATION] REAL          NULL
);

