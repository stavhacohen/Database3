CREATE TABLE [promotions].[dim_supplier_Wave1_5] (
    [meta_valid_from]      DATETIME         NULL,
    [meta_valid_to]        DATETIME         NULL,
    [meta_id_update]       UNIQUEIDENTIFIER NULL,
    [meta_loaded]          DATETIME         NULL,
    [meta_loaded_by]       NVARCHAR (100)   NULL,
    [id_supplier]          INT              IDENTITY (1, 1) NOT NULL,
    [NAME]                 NVARCHAR (100)   NULL,
    [business_supplier_id] BIGINT           NULL
);

