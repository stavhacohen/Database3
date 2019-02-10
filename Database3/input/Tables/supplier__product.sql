CREATE TABLE [input].[supplier__product] (
    [meta_valid_from] DATETIME       NOT NULL,
    [meta_valid_to]   DATETIME       NOT NULL,
    [meta_id_update]  INT            NOT NULL,
    [meta_loaded]     DATETIME       NOT NULL,
    [meta_loaded_by]  NVARCHAR (255) NOT NULL,
    [supplier_id]     INT            NOT NULL,
    [product_id]      INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([supplier_id] ASC, [product_id] ASC)
);

