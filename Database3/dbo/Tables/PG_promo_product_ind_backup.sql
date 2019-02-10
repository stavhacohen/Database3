CREATE TABLE [dbo].[PG_promo_product_ind_backup] (
    [ProductNumber]   BIGINT      NULL,
    [TransactionDate] DATE        NULL,
    [Branch_name_EN]  VARCHAR (7) NULL,
    [SourceInd]       SMALLINT    NULL,
    [Promo_ind]       SMALLINT    NULL,
    [Promotion_days]  INT         NULL
);


GO
CREATE CLUSTERED INDEX [cl_index_product]
    ON [dbo].[PG_promo_product_ind_backup]([ProductNumber] ASC);


GO
CREATE NONCLUSTERED INDEX [index_date]
    ON [dbo].[PG_promo_product_ind_backup]([TransactionDate] ASC);


GO
CREATE NONCLUSTERED INDEX [index_branch]
    ON [dbo].[PG_promo_product_ind_backup]([Branch_name_EN] ASC);


GO
CREATE NONCLUSTERED INDEX [index_source]
    ON [dbo].[PG_promo_product_ind_backup]([SourceInd] ASC);

