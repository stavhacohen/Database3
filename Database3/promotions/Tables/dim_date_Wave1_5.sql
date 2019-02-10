CREATE TABLE [promotions].[dim_date_Wave1_5] (
    [id_date]         INT              IDENTITY (1, 1) NOT NULL,
    [date]            DATE             NOT NULL,
    [month]           INT              NOT NULL,
    [quarter]         INT              NOT NULL,
    [week]            INT              NOT NULL,
    [year]            INT              NOT NULL,
    [meta_valid_from] DATETIME         NOT NULL,
    [meta_valid_to]   DATETIME         NOT NULL,
    [meta_id_update]  UNIQUEIDENTIFIER NOT NULL,
    [meta_loaded]     DATETIME         NOT NULL,
    [meta_loaded_by]  NVARCHAR (255)   NOT NULL
);

