CREATE TABLE [dbo].[PG_product_in_out_indicators_update] (
    [ProductNumber]          BIGINT          NULL,
    [Branch_name_EN]         VARCHAR (7)     NULL,
    [yearweek_id]            INT             NULL,
    [yearweek]               INT             NULL,
    [number_days]            INT             NULL,
    [week_quantity]          DECIMAL (15, 2) NULL,
    [max_week_quantity]      DECIMAL (15, 2) NULL,
    [perc_max_week_quantity] DECIMAL (5, 4)  NULL,
    [Ind_in_plan]            SMALLINT        NULL
);

