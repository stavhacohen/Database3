CREATE TABLE [dbo].[PG_supplier_product_date_participation] (
    [supplier_name_EN]                    VARCHAR (50)   NULL,
    [Supplier_ID]                         INT            NULL,
    [promotion_ID]                        BIGINT         NULL,
    [Date_from]                           BIGINT         NULL,
    [Date_to]                             BIGINT         NULL,
    [Perc_participation_purchase_price]   FLOAT (53)     NULL,
    [Amount_participation_purchase_price] FLOAT (53)     NULL,
    [Product_ID]                          BIGINT         NULL,
    [Grouping]                            INT            NULL,
    [group_ID]                            INT            NULL,
    [Branch_ID]                           INT            NULL,
    [Catalog_price]                       FLOAT (53)     NULL,
    [Perc_discount]                       FLOAT (53)     NULL,
    [Netto_price]                         FLOAT (53)     NULL,
    [Branch_name_EN]                      NVARCHAR (255) NULL
);

