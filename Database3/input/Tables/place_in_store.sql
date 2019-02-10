CREATE TABLE [input].[place_in_store] (
    [meta_valid_from] DATETIME       NOT NULL,
    [meta_valid_to]   DATETIME       NOT NULL,
    [meta_id_update]  INT            NOT NULL,
    [meta_loaded]     DATETIME       NOT NULL,
    [meta_loaded_by]  NVARCHAR (255) NOT NULL,
    [id]              INT            NOT NULL,
    [bk]              NVARCHAR (255) NOT NULL,
    [display]         NVARCHAR (255) NOT NULL,
    [zone]            NVARCHAR (255) NOT NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

