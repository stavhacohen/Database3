CREATE TABLE [dbo].[MM_Staging_promotions_fix2] (
    [CampaignNumberPromo]          INT            NULL,
    [CampaignDesc]                 NVARCHAR (255) NULL,
    [PromotionNumber]              INT            NULL,
    [PromotionNumberUnv]           INT            NULL,
    [PromotionDesc]                NVARCHAR (255) NULL,
    [PromotionStartDate]           NVARCHAR (8)   NULL,
    [PromotionEndDate]             NVARCHAR (8)   NULL,
    [ProductNumber]                BIGINT         NULL,
    [DiscountType]                 SMALLINT       NULL,
    [Multibuy]                     SMALLINT       NULL,
    [DisplayType]                  SMALLINT       NULL,
    [Folder]                       NVARCHAR (3)   NULL,
    [PromotionCharacteristicsType] INT            NULL
);

