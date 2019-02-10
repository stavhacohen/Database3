CREATE TABLE [promotions].[dim_supplier] (
    [id_supplier]     INT              IDENTITY (1, 1) NOT NULL,
    [busines_id]      BIGINT           NOT NULL,
    [name]            NVARCHAR (255)   NOT NULL,
    [meta_valid_from] DATETIME         NOT NULL,
    [meta_valid_to]   DATETIME         NOT NULL,
    [meta_id_update]  UNIQUEIDENTIFIER NOT NULL,
    [meta_loaded]     DATETIME         NOT NULL,
    [meta_loaded_by]  NVARCHAR (255)   NOT NULL,
    CONSTRAINT [PK_dimsupplier_idsupplier] PRIMARY KEY CLUSTERED ([id_supplier] ASC),
    UNIQUE NONCLUSTERED ([id_supplier] ASC)
);

