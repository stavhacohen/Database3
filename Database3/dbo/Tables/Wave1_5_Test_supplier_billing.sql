CREATE TABLE [dbo].[Wave1_5_Test_supplier_billing] (
    [DISCOUNT_ID]            INT             NULL,
    [DISCOUNT_DESC]          NVARCHAR (255)  NULL,
    [DATE_FROM]              DATE            NULL,
    [DATE_TO]                DATE            NULL,
    [SUPPLIER_ID]            INT             NULL,
    [SUPPLIER_NAME]          NVARCHAR (50)   NULL,
    [MONTH]                  INT             NULL,
    [FORMAT_ID]              SMALLINT        NULL,
    [FORMAT_NAME]            NVARCHAR (50)   NULL,
    [TOTAL_SALES]            DECIMAL (10, 2) NULL,
    [SUPPLIER_PARTICIPATION] DECIMAL (10, 2) NULL,
    [import_date]            DATETIME        NOT NULL
);

