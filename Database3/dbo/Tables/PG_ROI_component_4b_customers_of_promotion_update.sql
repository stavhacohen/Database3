CREATE TABLE [dbo].[PG_ROI_component_4b_customers_of_promotion_update] (
    [HouseholdID]                BIGINT          NULL,
    [TransactionDate]            DATE            NULL,
    [ProductNumber]              BIGINT          NULL,
    [SourceInd]                  SMALLINT        NULL,
    [Branch_name_EN]             VARCHAR (7)     NULL,
    [PromotionNumber]            BIGINT          NULL,
    [PromotionStartDate]         DATE            NULL,
    [PromotionEndDate]           DATE            NULL,
    [new_promo_customer_ind]     INT             NOT NULL,
    [new_customer_ind]           INT             NOT NULL,
    [promo_ind]                  INT             NOT NULL,
    [Promo_quantity_at_date]     DECIMAL (15, 2) NULL,
    [Non_promo_quantity_at_date] DECIMAL (15, 2) NULL,
    [Promo_revenue_at_date]      DECIMAL (15, 2) NULL,
    [Non_promo_revenue_at_date]  DECIMAL (15, 2) NULL,
    [Promo_margin_at_date]       DECIMAL (15, 2) NULL,
    [Non_promo_margin_at_date]   DECIMAL (15, 2) NULL,
    [Revenue]                    DECIMAL (15, 2) NULL,
    [Traffic_generating_sales]   DECIMAL (15, 2) NULL
);

