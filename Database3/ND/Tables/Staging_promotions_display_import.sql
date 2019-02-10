CREATE TABLE [ND].[Staging_promotions_display_import] (
    [meta_valid_from]    DATETIME         NOT NULL,
    [meta_valid_to]      DATETIME         NOT NULL,
    [meta_id_update]     UNIQUEIDENTIFIER NULL,
    [meta_loaded]        DATETIME         NOT NULL,
    [meta_origin]        NVARCHAR (510)   NOT NULL,
    [meta_loaded_by]     [sysname]        NOT NULL,
    [Promotion_ID]       BIGINT           NOT NULL,
    [Date_from]          BIGINT           NULL,
    [Date_to]            BIGINT           NULL,
    [Display_ID]         INT              NULL,
    [Display_name_HE]    NVARCHAR (40)    NULL,
    [Display_name_EN]    VARCHAR (40)     NULL,
    [Display_number]     INT              NULL,
    [Media_ID]           INT              NULL,
    [Newspaper_chapter]  VARCHAR (10)     NULL,
    [Newspaper_page]     INT              NULL,
    [Newspaper_unit]     INT              NULL,
    [Newspaper_location] VARCHAR (10)     NULL,
    [Newspaper_nr_cubes] INT              NULL
);

