CREATE TABLE [MICOMPANY\hagaiweiss].[HW_2017H1_SellOut_product_join_PG_ROI] (
    [ProductNumber]          BIGINT          NULL,
    [transactionDate]        DATE            NULL,
    [month0]                 INT             NULL,
    [Product_name_HE]        NVARCHAR (255)  NULL,
    [Branch_name_EN]         VARCHAR (7)     NULL,
    [sum_Real_quantity]      DECIMAL (38, 2) NULL,
    [DISCOUNT_ID]            INT             NULL,
    [DISCOUNT_DESC]          NVARCHAR (50)   NULL,
    [DATE_FROM]              DATE            NULL,
    [DATE_TO]                DATE            NULL,
    [PRODUCT_ID]             BIGINT          NULL,
    [SUPPLIER_ID]            INT             NULL,
    [SUPPLIER_NAME]          NVARCHAR (24)   NULL,
    [MONTH]                  INT             NULL,
    [format0]                VARCHAR (10)    NULL,
    [FORMAT_NAME]            NVARCHAR (50)   NULL,
    [format_id]              SMALLINT        NULL,
    [TOTAL_SALES]            FLOAT (53)      NULL,
    [SUPPLIER_PARTICIPATION] FLOAT (53)      NULL
);

