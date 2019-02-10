CREATE TABLE [input].[promotion__transaction] (
    [meta_valid_from] DATETIME       NOT NULL,
    [meta_valid_to]   DATETIME       NOT NULL,
    [meta_id_update]  INT            NOT NULL,
    [meta_loaded]     DATETIME       NOT NULL,
    [meta_loaded_by]  NVARCHAR (255) NOT NULL,
    [promotion_id]    INT            NOT NULL,
    [transaction_id]  INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([promotion_id] ASC, [transaction_id] ASC)
);

