CREATE TABLE [dbo].[GN_PG_transactions_per_customer] (
    [HouseholdID]     BIGINT          NOT NULL,
    [TransactionDate] DATE            NOT NULL,
    [Total_revenue]   DECIMAL (10, 2) NULL,
    [Promo_revenue]   DECIMAL (10, 2) NULL,
    [Total_quantity]  DECIMAL (10, 2) NULL,
    [Promo_quantity]  DECIMAL (10, 2) NULL,
    [Total_margin]    DECIMAL (10, 2) NULL,
    [Promo_margin]    DECIMAL (10, 2) NULL,
    [Visit_index]     BIGINT          NOT NULL
);

