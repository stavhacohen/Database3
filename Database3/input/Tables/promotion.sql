﻿CREATE TABLE [input].[promotion] (
    [meta_valid_from]   DATETIME       NOT NULL,
    [meta_valid_to]     DATETIME       NOT NULL,
    [meta_id_update]    INT            NOT NULL,
    [meta_loaded]       DATETIME       NOT NULL,
    [meta_loaded_by]    NVARCHAR (255) NOT NULL,
    [id]                INT            NOT NULL,
    [bk]                NVARCHAR (255) NOT NULL,
    [name]              NVARCHAR (255) NOT NULL,
    [start_date]        DATETIME       NULL,
    [end_date]          DATETIME       NULL,
    [place_in_store_id] INT            NULL,
    [campaign_id]       INT            NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [NonClusteredIndex_20170902_195238]
    ON [input].[promotion]([bk] ASC);

