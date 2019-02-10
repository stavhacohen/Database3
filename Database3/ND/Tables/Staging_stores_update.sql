CREATE TABLE [ND].[Staging_stores_update] (
    [meta_valid_from] DATETIME         NOT NULL,
    [meta_valid_to]   DATETIME         NOT NULL,
    [meta_id_update]  UNIQUEIDENTIFIER NULL,
    [meta_loaded]     DATETIME         NOT NULL,
    [meta_origin]     NVARCHAR (510)   NOT NULL,
    [meta_loaded_by]  [sysname]        NOT NULL,
    [#LocationID]     SMALLINT         NULL,
    [StoreName]       NVARCHAR (25)    NULL,
    [StoreFormatCode] SMALLINT         NULL
);

