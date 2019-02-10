CREATE TABLE [dbo].[PG_product_perc_max_week_quantity_update] (
    [yearweek_id]            BIGINT          NULL,
    [ProductNumber]          BIGINT          NULL,
    [Branch_name_EN]         VARCHAR (7)     NULL,
    [yearweek]               INT             NULL,
    [number_days]            INT             NULL,
    [week_quantity]          DECIMAL (15, 2) NULL,
    [max_week_quantity]      DECIMAL (15, 2) NULL,
    [perc_max_week_quantity] DECIMAL (5, 4)  NULL,
    [Ind_in_plan]            INT             NOT NULL
);

