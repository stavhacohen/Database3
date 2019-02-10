CREATE TABLE [input].[store__promotion] (
    [meta_valid_from] DATETIME       NOT NULL,
    [meta_valid_to]   DATETIME       NOT NULL,
    [meta_id_update]  INT            NOT NULL,
    [meta_loaded]     DATETIME       NOT NULL,
    [meta_loaded_by]  NVARCHAR (255) NOT NULL,
    [store_id]        INT            NOT NULL,
    [promotion_id]    INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([store_id] ASC, [promotion_id] ASC)
);

