CREATE TABLE [dbo].[PG_transactions_per_customer_update] (
    [HouseholdID]     BIGINT          NOT NULL,
    [TransactionDate] DATE            NOT NULL,
    [Total_revenue]   DECIMAL (10, 2) NOT NULL,
    [Promo_revenue]   DECIMAL (10, 2) NOT NULL,
    [Total_quantity]  DECIMAL (10, 2) NOT NULL,
    [Promo_quantity]  DECIMAL (10, 2) NOT NULL,
    [Total_margin]    DECIMAL (10, 2) NOT NULL,
    [Promo_margin]    DECIMAL (10, 2) NOT NULL,
    [Visit_index]     BIGINT          NOT NULL
);


GO
CREATE CLUSTERED INDEX [cl_index_householdID]
    ON [dbo].[PG_transactions_per_customer_update]([HouseholdID] ASC);


GO
CREATE NONCLUSTERED INDEX [index_date]
    ON [dbo].[PG_transactions_per_customer_update]([TransactionDate] ASC);

