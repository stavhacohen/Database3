CREATE TABLE [dbo].[MM_PG_baseline_validation_weekly] (
    [yearweek]       INT        NULL,
    [Nr_products]    INT        NULL,
    [Customers_MPE]  FLOAT (53) NULL,
    [Customers_MAPE] FLOAT (53) NULL,
    [Quantity_MPE]   FLOAT (53) NULL,
    [Quantity_MAPE]  FLOAT (53) NULL,
    [Revenue_MPE]    FLOAT (53) NULL,
    [Revenue_MAPE]   FLOAT (53) NULL,
    [Margin_MPE]     FLOAT (53) NULL,
    [Margin_MAPE]    FLOAT (53) NULL
);

