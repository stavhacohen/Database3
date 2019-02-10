CREATE TABLE [input].[transaction_detail] (
    [meta_valid_from]      DATETIME        NOT NULL,
    [meta_valid_to]        DATETIME        NOT NULL,
    [meta_id_update]       INT             NOT NULL,
    [meta_loaded]          DATETIME        NOT NULL,
    [meta_loaded_by]       NVARCHAR (255)  NOT NULL,
    [id]                   INT             NOT NULL,
    [bk]                   NVARCHAR (255)  NOT NULL,
    [number_of_sold_items] DECIMAL (19, 8) NULL,
    [revenue]              DECIMAL (19, 8) NULL,
    [margin]               DECIMAL (19, 8) NULL,
    [product_id]           INT             NULL,
    [transaction_id]       INT             NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

