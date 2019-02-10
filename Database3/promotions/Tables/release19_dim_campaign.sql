CREATE TABLE [promotions].[release19_dim_campaign] (
    [id_campaign]     INT              IDENTITY (1, 1) NOT NULL,
    [business_id]     INT              NOT NULL,
    [name]            NVARCHAR (255)   NOT NULL,
    [meta_valid_from] DATETIME         NOT NULL,
    [meta_valid_to]   DATETIME         NOT NULL,
    [meta_id_update]  UNIQUEIDENTIFIER NOT NULL,
    [meta_loaded]     DATETIME         NOT NULL,
    [meta_loaded_by]  NVARCHAR (255)   NOT NULL,
    CONSTRAINT [PK_release19_dimcampaign_idcampaign] PRIMARY KEY CLUSTERED ([id_campaign] ASC),
    UNIQUE NONCLUSTERED ([id_campaign] ASC)
);

