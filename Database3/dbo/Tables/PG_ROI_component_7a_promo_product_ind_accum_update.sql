CREATE TABLE [dbo].[PG_ROI_component_7a_promo_product_ind_accum_update] (
    [PromotionNumber]      BIGINT      NULL,
    [PromotionStartDate]   DATE        NULL,
    [PromotionEndDate]     DATE        NULL,
    [ProductNumber]        BIGINT      NULL,
    [Branch_name_EN]       VARCHAR (7) NULL,
    [SourceInd]            SMALLINT    NULL,
    [TransactionDate]      DATE        NULL,
    [Days_after_promotion] INT         NOT NULL,
    [Promo_accum_ind]      INT         NOT NULL
);

