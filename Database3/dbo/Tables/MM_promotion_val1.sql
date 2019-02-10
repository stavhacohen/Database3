CREATE TABLE [dbo].[MM_promotion_val1] (
    [CampaignNumberPromo] INT            NULL,
    [CampaignDesc]        NVARCHAR (255) NULL,
    [PromotionNumber]     INT            NULL,
    [PromotionNumberUnv]  INT            NULL,
    [PromotionDesc]       NVARCHAR (255) NULL,
    [PromotionStartDate]  DATE           NULL,
    [PromotionEndDate]    DATE           NULL,
    [ProductNumber]       BIGINT         NULL,
    [DiscountType]        SMALLINT       NULL,
    [Multibuy]            SMALLINT       NULL,
    [DisplayType]         SMALLINT       NULL,
    [Folder]              NVARCHAR (3)   NULL
);

