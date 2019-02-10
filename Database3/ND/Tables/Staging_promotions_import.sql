CREATE TABLE [ND].[Staging_promotions_import] (
    [meta_valid_from]              DATETIME         NOT NULL,
    [meta_valid_to]                DATETIME         NOT NULL,
    [meta_id_update]               UNIQUEIDENTIFIER NULL,
    [meta_loaded]                  DATETIME         NOT NULL,
    [meta_origin]                  NVARCHAR (510)   NOT NULL,
    [meta_loaded_by]               [sysname]        NOT NULL,
    [CampaignNumberPromo]          INT              NULL,
    [CampaignDesc]                 NVARCHAR (255)   NULL,
    [PromotionNumber]              INT              NULL,
    [PromotionNumberUnv]           INT              NULL,
    [PromotionDesc]                NVARCHAR (255)   NULL,
    [PromotionStartDate]           NVARCHAR (8)     NULL,
    [PromotionEndDate]             NVARCHAR (8)     NULL,
    [ProductNumber]                BIGINT           NULL,
    [DiscountType]                 SMALLINT         NULL,
    [Multibuy]                     SMALLINT         NULL,
    [DisplayType]                  SMALLINT         NULL,
    [Folder]                       NVARCHAR (3)     NULL,
    [PromotionCharacteristicsType] INT              NULL
);

