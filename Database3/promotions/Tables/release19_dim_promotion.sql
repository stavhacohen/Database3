CREATE TABLE [promotions].[release19_dim_promotion] (
    [id_promotion]    INT              IDENTITY (1, 1) NOT NULL,
    [business_id]     BIGINT           NOT NULL,
    [universal_id]    BIGINT           NULL,
    [promotion_start] DATE             NOT NULL,
    [name]            NVARCHAR (255)   NOT NULL,
    [folder]          BIT              NOT NULL,
    [meta_valid_from] DATETIME         NOT NULL,
    [meta_valid_to]   DATETIME         NOT NULL,
    [meta_id_update]  UNIQUEIDENTIFIER NOT NULL,
    [meta_loaded]     DATETIME         NOT NULL,
    [meta_loaded_by]  NVARCHAR (255)   NOT NULL,
    CONSTRAINT [PK_dimpromotion_release19_idpromotion] PRIMARY KEY CLUSTERED ([id_promotion] ASC),
    UNIQUE NONCLUSTERED ([id_promotion] ASC)
);

