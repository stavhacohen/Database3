﻿CREATE TABLE [promotions].[dim_product_Wave1_5] (
    [id_product]      INT              IDENTITY (1, 1) NOT NULL,
    [business_id]     BIGINT           NOT NULL,
    [name]            NVARCHAR (255)   NOT NULL,
    [meta_valid_from] DATETIME         NOT NULL,
    [meta_valid_to]   DATETIME         NOT NULL,
    [meta_id_update]  UNIQUEIDENTIFIER NOT NULL,
    [meta_loaded]     DATETIME         NOT NULL,
    [meta_loaded_by]  NVARCHAR (255)   NOT NULL
);

