CREATE TABLE [dbo].[TC_participation_in_sales_products] (
    [Participation_ID]                    BIGINT         NULL,
    [Participation_name_HE]               NVARCHAR (100) NULL,
    [DATE_FROM]                           BIGINT         NULL,
    [DATE_TO]                             BIGINT         NULL,
    [SUPPLIER_ID]                         BIGINT         NULL,
    [DESC_SUPPLIER]                       NVARCHAR (50)  NULL,
    [Amount_participation_purchase_price] FLOAT (53)     NULL,
    [Perc_participation_purchase_price]   FLOAT (53)     NULL,
    [Product_ID]                          BIGINT         NULL,
    [DESC_PRODUCT]                        NVARCHAR (100) NULL,
    [Without_grouping]                    BIGINT         NULL,
    [Exclude]                             NVARCHAR (50)  NULL
);

