CREATE TABLE [dbo].[GN_PG_ROI_component_4_5_update] (
    [TransactionDate]                DATE            NULL,
    [ProductNumber]                  BIGINT          NULL,
    [SourceInd]                      SMALLINT        NULL,
    [Branch_name_EN]                 VARCHAR (7)     NULL,
    [PromotionNumber]                BIGINT          NULL,
    [PromotionStartDate]             DATE            NULL,
    [PromotionEndDate]               DATE            NULL,
    [Quantity_4_promobuyer_existing] DECIMAL (15, 2) NULL,
    [Quantity_5_promobuyer_new]      DECIMAL (15, 2) NULL,
    [Revenue_4_promobuyer_existing]  DECIMAL (15, 2) NULL,
    [Revenue_5_promobuyer_new]       DECIMAL (15, 2) NULL,
    [Margin_4_promobuyer_existing]   DECIMAL (15, 2) NULL,
    [Margin_5_promobuyer_new]        DECIMAL (15, 2) NULL
);

