CREATE TABLE [dbo].[PG_ROI_component_2c_continuous_promotions_update] (
    [PromotionNumber]         BIGINT          NULL,
    [PromotionStartDate]      DATE            NULL,
    [PromotionEndDate]        DATE            NULL,
    [ProductNumber]           BIGINT          NULL,
    [Branch_name_EN]          VARCHAR (7)     NULL,
    [SourceInd]               INT             NULL,
    [Avg_promotion_price]     DECIMAL (10, 2) NULL,
    [Avg_price_before]        DECIMAL (10, 2) NULL,
    [Ind_sufficient_discount] INT             NOT NULL
);

