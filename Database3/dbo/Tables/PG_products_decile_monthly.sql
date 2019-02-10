CREATE TABLE [dbo].[PG_products_decile_monthly] (
    [ProductNumber]        FLOAT (53)       NULL,
    [nr_promotions]        INT              NULL,
    [Real_quantity]        FLOAT (53)       NULL,
    [Baseline_quantity]    FLOAT (53)       NULL,
    [Revenue_1_promotion]  FLOAT (53)       NULL,
    [Revenue_value_effect] FLOAT (53)       NULL,
    [Margin_1_promotion]   FLOAT (53)       NULL,
    [Margin_value_effect]  FLOAT (53)       NULL,
    [Perc_winner]          NUMERIC (25, 14) NULL,
    [Perc_margin_killer]   NUMERIC (25, 14) NULL,
    [Product_name_HE]      NVARCHAR (255)   NULL,
    [Department_name_EN]   NVARCHAR (200)   NULL,
    [Category_name_EN]     NVARCHAR (200)   NULL,
    [Group_name_EN]        NVARCHAR (200)   NULL,
    [Rank]                 BIGINT           NULL,
    [Decile]               BIGINT           NULL
);

