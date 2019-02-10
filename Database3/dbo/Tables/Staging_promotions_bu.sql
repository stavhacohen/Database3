CREATE TABLE [dbo].[Staging_promotions_bu] (
    [CampaignNumberPromo]          BIGINT         NULL,
    [CampaignDesc]                 NVARCHAR (255) NULL,
    [PromotionNumber]              INT            NULL,
    [PromotionNumberUnv]           INT            NULL,
    [PromotionCharacteristicsType] INT            NULL,
    [PromotionDesc]                NVARCHAR (255) NULL,
    [PromotionStartDate]           DATE           NULL,
    [PromotionEndDate]             DATE           NULL,
    [SourceInd]                    INT            NULL,
    [ProductNumber]                BIGINT         NULL,
    [ProductDescription]           NVARCHAR (255) NULL,
    [DiscountType]                 SMALLINT       NULL,
    [Multibuy]                     INT            NULL,
    [DisplayType]                  INT            NULL,
    [Folder]                       NVARCHAR (3)   NULL
);

