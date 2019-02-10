CREATE TABLE [input].[product__customer_promotion] (
    [meta_valid_from]       DATETIME       NOT NULL,
    [meta_valid_to]         DATETIME       NOT NULL,
    [meta_id_update]        INT            NOT NULL,
    [meta_loaded]           DATETIME       NOT NULL,
    [meta_loaded_by]        NVARCHAR (255) NOT NULL,
    [product_id]            INT            NOT NULL,
    [customer_promotion_id] INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([product_id] ASC, [customer_promotion_id] ASC)
);

