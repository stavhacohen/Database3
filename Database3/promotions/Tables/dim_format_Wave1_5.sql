CREATE TABLE [promotions].[dim_format_Wave1_5] (
    [id_format]       INT              IDENTITY (1, 1) NOT NULL,
    [name_EN]         NVARCHAR (255)   NOT NULL,
    [name_HE]         NVARCHAR (255)   NOT NULL,
    [meta_valid_from] DATETIME         NOT NULL,
    [meta_valid_to]   DATETIME         NOT NULL,
    [meta_id_update]  UNIQUEIDENTIFIER NOT NULL,
    [meta_loaded]     DATETIME         NOT NULL,
    [meta_loaded_by]  NVARCHAR (255)   NOT NULL
);

