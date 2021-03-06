﻿CREATE TABLE [dbo].[PG_promotions_update] (
    [CampaignNumberPromo]          BIGINT           NULL,
    [CampaignDesc]                 NVARCHAR (255)   NULL,
    [PromotionNumber]              BIGINT           NULL,
    [PromotionCharacteristicsType] INT              NULL,
    [PromotionNumberUnv]           INT              NULL,
    [PromotionDesc]                NVARCHAR (255)   NULL,
    [PromotionStartDate]           DATE             NULL,
    [PromotionEndDate]             DATE             NULL,
    [SourceInd]                    INT              NULL,
    [Branch_name_EN]               VARCHAR (7)      NULL,
    [ProductNumber]                BIGINT           NULL,
    [DiscountType]                 SMALLINT         NULL,
    [Place_in_store]               VARCHAR (53)     NOT NULL,
    [Folder]                       INT              NOT NULL,
    [Multibuy_quantity]            INT              NULL,
    [Promotion_perc_running_year]  NUMERIC (24, 12) NULL
);

