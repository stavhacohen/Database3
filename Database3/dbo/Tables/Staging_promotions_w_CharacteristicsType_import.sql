CREATE TABLE [dbo].[Staging_promotions_w_CharacteristicsType_import] (
    [CampaignNumberPromo]          INT            NULL,
    [CampaignDesc]                 NVARCHAR (255) NULL,
    [PromotionNumber]              INT            NULL,
    [PromotionNumberUnv]           INT            NULL,
    [PromotionDesc]                NVARCHAR (255) NULL,
    [PromotionStartDate]           DATE           NULL,
    [PromotionEndDate]             DATE           NULL,
    [ProductNumber]                BIGINT         NULL,
    [DiscountType]                 SMALLINT       NULL,
    [Multibuy]                     SMALLINT       NULL,
    [DisplayType]                  SMALLINT       NULL,
    [Folder]                       NVARCHAR (3)   NULL,
    [PromotionCharacteristicsType] NVARCHAR (255) NULL
);

