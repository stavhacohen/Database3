CREATE TABLE [promotions].[dim_product_category] (
    [id_product_category]      INT              IDENTITY (1, 1) NOT NULL,
    [name_EN]                  NVARCHAR (255)   NOT NULL,
    [name_HE]                  NVARCHAR (255)   NOT NULL,
    [product_category_type_id] INT              NOT NULL,
    [parent_id]                INT              NOT NULL,
    [meta_valid_from]          DATETIME         NOT NULL,
    [meta_valid_to]            DATETIME         NOT NULL,
    [meta_id_update]           UNIQUEIDENTIFIER NOT NULL,
    [meta_loaded]              DATETIME         NOT NULL,
    [meta_loaded_by]           NVARCHAR (255)   NOT NULL,
    CONSTRAINT [PK_dimproduct_category_idproduct_category] PRIMARY KEY CLUSTERED ([id_product_category] ASC),
    UNIQUE NONCLUSTERED ([id_product_category] ASC)
);

