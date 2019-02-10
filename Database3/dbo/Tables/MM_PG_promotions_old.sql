CREATE TABLE [dbo].[MM_PG_promotions_old] (
    [CampaignNumberPromo]         BIGINT           NULL,
    [CampaignDesc]                NVARCHAR (255)   NULL,
    [PromotionNumber]             BIGINT           NULL,
    [PromotionNumberUnv]          INT              NULL,
    [PromotionDesc]               NVARCHAR (255)   NULL,
    [PromotionStartDate]          DATE             NULL,
    [PromotionEndDate]            DATE             NULL,
    [SourceInd]                   INT              NULL,
    [Branch_name_EN]              VARCHAR (7)      NULL,
    [ProductNumber]               BIGINT           NULL,
    [DiscountType]                INT              NULL,
    [Place_in_store]              VARCHAR (60)     NULL,
    [Folder]                      INT              NULL,
    [Multibuy_quantity]           INT              NULL,
    [Promotion_perc_running_year] NUMERIC (24, 12) NULL
);

