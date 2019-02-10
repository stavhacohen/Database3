CREATE TABLE [dbo].[GN_PG_customer_information_table] (
    [HouseholdID]                BIGINT          NOT NULL,
    [TransactionDate]            DATE            NOT NULL,
    [Visit_index]                BIGINT          NOT NULL,
    [PreviousTransactionDate]    DATE            NULL,
    [new_promo_customer_ind]     INT             NOT NULL,
    [new_customer_ind]           INT             NOT NULL,
    [Promo_revenue_at_date]      DECIMAL (10, 2) NOT NULL,
    [Non_promo_revenue_at_date]  DECIMAL (10, 2) NOT NULL,
    [Promo_margin_at_date]       DECIMAL (10, 2) NOT NULL,
    [Non_promo_margin_at_date]   DECIMAL (10, 2) NOT NULL,
    [Promo_quantity_at_date]     DECIMAL (10, 2) NOT NULL,
    [Non_promo_quantity_at_date] DECIMAL (10, 2) NOT NULL,
    [Perc_promo]                 DECIMAL (3, 2)  NOT NULL,
    [promo_ind]                  INT             NOT NULL
);

