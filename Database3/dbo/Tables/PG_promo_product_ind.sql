CREATE TABLE [dbo].[PG_promo_product_ind] (
    [ProductNumber]   BIGINT      NULL,
    [TransactionDate] DATE        NULL,
    [Branch_name_EN]  VARCHAR (7) NULL,
    [SourceInd]       SMALLINT    NULL,
    [Promo_ind]       SMALLINT    NULL,
    [Promotion_days]  INT         NULL
);


GO
CREATE CLUSTERED INDEX [cl_index_product]
    ON [dbo].[PG_promo_product_ind]([ProductNumber] ASC);


GO
CREATE NONCLUSTERED INDEX [index_date]
    ON [dbo].[PG_promo_product_ind]([TransactionDate] ASC);


GO
CREATE NONCLUSTERED INDEX [index_branch]
    ON [dbo].[PG_promo_product_ind]([Branch_name_EN] ASC);


GO
CREATE NONCLUSTERED INDEX [index_source]
    ON [dbo].[PG_promo_product_ind]([SourceInd] ASC);

