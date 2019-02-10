CREATE TABLE [dbo].[HW_SellOut_Promotions_2017H1_day_level] (
    [DISCOUNT_ID]            INT            NULL,
    [DISCOUNT_DESC]          NVARCHAR (50)  NULL,
    [DATE_FROM]              INT            NULL,
    [DATE_TO]                INT            NULL,
    [SUPPLIER_ID]            INT            NULL,
    [SUPPLIER_NAME]          NVARCHAR (24)  NULL,
    [MONTH]                  INT            NULL,
    [FORMAT_ID]              SMALLINT       NULL,
    [FORMAT_NAME]            NVARCHAR (20)  NULL,
    [TOTAL_SALES]            REAL           NULL,
    [SUPPLIER_PARTICIPATION] REAL           NULL,
    [Branch_name_EN]         NVARCHAR (255) NULL,
    [avg_Partic]             REAL           NULL,
    [date0]                  DATE           NULL
);

