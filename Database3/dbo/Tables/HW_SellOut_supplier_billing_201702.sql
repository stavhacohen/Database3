﻿CREATE TABLE [dbo].[HW_SellOut_supplier_billing_201702] (
    [DISCOUNT_ID]            INT           NULL,
    [DISCOUNT_DESC]          NVARCHAR (50) NULL,
    [DATE_FROM]              INT           NULL,
    [DATE_TO]                INT           NULL,
    [SUPPLIER_ID]            INT           NULL,
    [SUPPLIER_NAME]          NVARCHAR (24) NULL,
    [MONTH]                  INT           NULL,
    [FORMAT_ID]              SMALLINT      NULL,
    [FORMAT_NAME]            NVARCHAR (20) NULL,
    [TOTAL_SALES]            REAL          NULL,
    [SUPPLIER_PARTICIPATION] REAL          NULL
);

