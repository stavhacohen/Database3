CREATE TABLE [dbo].[PG_promotions_dates] (
    [PromotionNumber] BIGINT      NULL,
    [ProductNumber]   BIGINT      NULL,
    [Branch_name_EN]  VARCHAR (7) NULL,
    [SourceInd]       INT         NULL,
    [Date]            DATE        NULL,
    [Valid_ind]       INT         NOT NULL
);

