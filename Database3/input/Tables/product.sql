CREATE TABLE [input].[product] (
    [meta_valid_from]     DATETIME        NOT NULL,
    [meta_valid_to]       DATETIME        NOT NULL,
    [meta_id_update]      INT             NOT NULL,
    [meta_loaded]         DATETIME        NOT NULL,
    [meta_loaded_by]      NVARCHAR (255)  NOT NULL,
    [id]                  INT             NOT NULL,
    [bk]                  NVARCHAR (255)  NOT NULL,
    [name]                NVARCHAR (255)  NULL,
    [description]         NVARCHAR (2000) NULL,
    [weight]              DECIMAL (19, 8) NULL,
    [volume]              DECIMAL (19, 8) NULL,
    [product_category_id] INT             NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

