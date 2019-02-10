CREATE TABLE [dbo].[PG_product_week_quantities] (
    [ProductNumber]  BIGINT          NULL,
    [Branch_name_EN] VARCHAR (7)     NULL,
    [yearweek]       INT             NULL,
    [number_days]    INT             NULL,
    [week_quantity]  DECIMAL (15, 2) NULL
);

