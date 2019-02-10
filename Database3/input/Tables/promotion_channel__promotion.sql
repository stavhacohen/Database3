CREATE TABLE [input].[promotion_channel__promotion] (
    [meta_valid_from]      DATETIME       NOT NULL,
    [meta_valid_to]        DATETIME       NOT NULL,
    [meta_id_update]       INT            NOT NULL,
    [meta_loaded]          DATETIME       NOT NULL,
    [meta_loaded_by]       NVARCHAR (255) NOT NULL,
    [promotion_channel_id] INT            NOT NULL,
    [promotion_id]         INT            NOT NULL,
    PRIMARY KEY CLUSTERED ([promotion_channel_id] ASC, [promotion_id] ASC)
);

