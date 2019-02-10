CREATE TABLE [dbo].[PG_new_customers_percentage] (
    [TransactionDate]      DATE           NULL,
    [Branch_name_EN]       VARCHAR (50)   NULL,
    [N_distinct_customers] INT            NULL,
    [N_new13weeks]         INT            NULL,
    [pct_new]              DECIMAL (7, 6) NULL
);

