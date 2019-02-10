CREATE TABLE [dbo].[GN_PG_ROI_component_6b_new_customer_sales_update] (
    [HouseholdID]                  BIGINT          NULL,
    [TransactionDate]              DATE            NULL,
    [PromotionNumber]              BIGINT          NULL,
    [PromotionStartDate]           DATE            NULL,
    [PromotionEndDate]             DATE            NULL,
    [ProductNumber]                BIGINT          NULL,
    [Branch_name_EN]               VARCHAR (7)     NULL,
    [SourceInd]                    SMALLINT        NULL,
    [Revenue]                      DECIMAL (15, 2) NULL,
    [new_traffic_generating_sales] DECIMAL (15, 2) NULL,
    [Promo_after_quantity]         DECIMAL (15, 2) NULL,
    [Non_promo_quantity]           DECIMAL (15, 2) NULL,
    [Promo_after_revenue]          DECIMAL (15, 2) NULL,
    [Non_promo_revenue]            DECIMAL (15, 2) NULL,
    [Promo_after_margin]           DECIMAL (15, 2) NULL,
    [Non_promo_margin]             DECIMAL (15, 2) NULL
);

