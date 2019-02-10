CREATE TABLE [promotions].[dim_Supplier_Matrix_segment_Wave1_5] (
    [id_supplier_matrix_segment] INT              IDENTITY (1, 1) NOT NULL,
    [name]                       NVARCHAR (255)   NOT NULL,
    [meta_valid_from]            DATETIME         NOT NULL,
    [meta_valid_to]              DATETIME         NOT NULL,
    [meta_id_update]             UNIQUEIDENTIFIER NOT NULL,
    [meta_loaded]                DATETIME         NOT NULL,
    [meta_loaded_by]             NVARCHAR (255)   NOT NULL
);

