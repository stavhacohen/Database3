CREATE TABLE [dbo].[Staging_Products_TOT] (
    [PRODUCT_ID]             BIGINT         NULL,
    [Branch_name_EN]         NVARCHAR (255) NULL,
    [date0]                  DATE           NULL,
    [SUPPLIER_ID]            INT            NULL,
    [MONTH]                  INT            NULL,
    [SUPPLIER_NAME]          NVARCHAR (28)  NULL,
    [FORMAT_ID_Sarit]        INT            NULL,
    [TOTAL_SALES]            FLOAT (53)     NULL,
    [SUPPLIER_PARTICIPATION] FLOAT (53)     NULL,
    [avg_partic]             FLOAT (53)     NULL
);

