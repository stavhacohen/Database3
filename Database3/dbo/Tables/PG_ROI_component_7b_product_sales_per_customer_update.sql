CREATE TABLE [dbo].[PG_ROI_component_7b_product_sales_per_customer_update] (
    [HouseholdID]               INT             NULL,
    [PromotionNumber]           BIGINT          NULL,
    [PromotionStartDate]        DATE            NULL,
    [PromotionEndDate]          DATE            NULL,
    [ProductNumber]             BIGINT          NULL,
    [Total_product_revenue]     DECIMAL (10, 2) NULL,
    [Quantity_before_promotion] DECIMAL (10, 2) NULL,
    [Quantity_after_promotion]  DECIMAL (10, 2) NULL,
    [Revenue_after_promotion]   DECIMAL (10, 2) NULL,
    [Margin_after_promotion]    DECIMAL (10, 2) NULL
);

