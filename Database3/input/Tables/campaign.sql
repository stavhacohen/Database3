﻿CREATE TABLE [input].[campaign] (
    [meta_valid_from] DATETIME        NOT NULL,
    [meta_valid_to]   DATETIME        NOT NULL,
    [meta_id_update]  INT             NOT NULL,
    [meta_loaded]     DATETIME        NOT NULL,
    [meta_loaded_by]  NVARCHAR (255)  NOT NULL,
    [id]              INT             NOT NULL,
    [bk]              NVARCHAR (255)  NOT NULL,
    [name]            NVARCHAR (255)  NOT NULL,
    [cost]            DECIMAL (19, 8) NULL,
    PRIMARY KEY CLUSTERED ([id] ASC)
);

