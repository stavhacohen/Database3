CREATE TABLE [input].[transaction] (
    [meta_valid_from] DATETIME       NOT NULL,
    [meta_valid_to]   DATETIME       NOT NULL,
    [meta_id_update]  INT            NOT NULL,
    [meta_loaded]     DATETIME       NOT NULL,
    [meta_loaded_by]  NVARCHAR (255) NOT NULL,
    [id]              INT            NOT NULL,
    [bk]              NVARCHAR (255) NOT NULL,
    [time]            DATETIME       NULL,
    [store_id]        INT            NULL,
    [calendar_id]     INT            NULL,
    [customer_id]     INT            NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_transaction_bk]
    ON [input].[transaction]([bk] ASC);

