CREATE TABLE [promotions].[dim_suppliermatrix_segment] (
    [id_suppliermatrix_segment] INT              IDENTITY (1, 1) NOT NULL,
    [name]                      NVARCHAR (255)   NOT NULL,
    [meta_valid_from]           DATETIME         NOT NULL,
    [meta_valid_to]             DATETIME         NOT NULL,
    [meta_id_update]            UNIQUEIDENTIFIER NOT NULL,
    [meta_loaded]               DATETIME         NOT NULL,
    [meta_loaded_by]            NVARCHAR (255)   NOT NULL,
    CONSTRAINT [PK_dimsuppliermatrix_segment_idsuppliermatrix_segment] PRIMARY KEY CLUSTERED ([id_suppliermatrix_segment] ASC),
    UNIQUE NONCLUSTERED ([id_suppliermatrix_segment] ASC)
);

