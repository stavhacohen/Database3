CREATE TABLE [promotions].[dim_promotion_segment] (
    [id_promotion_segment] INT              IDENTITY (1, 1) NOT NULL,
    [name]                 NVARCHAR (255)   NOT NULL,
    [meta_valid_from]      DATETIME         NOT NULL,
    [meta_valid_to]        DATETIME         NOT NULL,
    [meta_id_update]       UNIQUEIDENTIFIER NOT NULL,
    [meta_loaded]          DATETIME         NOT NULL,
    [meta_loaded_by]       NVARCHAR (255)   NOT NULL,
    CONSTRAINT [PK_dimpromotion_segment_idpromotion_segment] PRIMARY KEY CLUSTERED ([id_promotion_segment] ASC),
    UNIQUE NONCLUSTERED ([id_promotion_segment] ASC)
);

