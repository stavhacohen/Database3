CREATE TABLE [dbo].[Staging_promotions_test] (
    [CampaignNumberPromo]          BIGINT         NULL,
    [CampaignDesc]                 NVARCHAR (255) NULL,
    [PromotionNumber]              INT            NULL,
    [PromotionNumberUnv]           INT            NULL,
    [PromotionCharacteristicsType] NVARCHAR (255) NULL,
    [PromotionDesc]                NVARCHAR (255) NULL,
    [PromotionStartDate]           DATE           NULL,
    [PromotionEndDate]             DATE           NULL,
    [ProductNumber]                BIGINT         NULL,
    [DiscountType]                 SMALLINT       NULL,
    [Multibuy]                     INT            NULL,
    [DisplayType]                  INT            NULL,
    [Folder]                       NVARCHAR (3)   NULL
);

