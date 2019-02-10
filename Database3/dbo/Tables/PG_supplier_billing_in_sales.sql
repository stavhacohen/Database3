﻿CREATE TABLE [dbo].[PG_supplier_billing_in_sales] (
    [PRODUCT_ID]             BIGINT           NULL,
    [Branch_name_EN]         NVARCHAR (255)   NULL,
    [date0]                  DATE             NULL,
    [SUPPLIER_ID]            INT              NULL,
    [MONTH]                  INT              NULL,
    [SUPPLIER_NAME]          NVARCHAR (28)    NULL,
    [FORMAT_ID_Sarit]        INT              NULL,
    [TOTAL_SALES]            DECIMAL (38, 2)  NULL,
    [SUPPLIER_PARTICIPATION] DECIMAL (38, 2)  NULL,
    [avg_partic]             DECIMAL (38, 13) NULL,
    [import_date]            DATETIME         NOT NULL
);

