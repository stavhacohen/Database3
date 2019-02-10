CREATE TABLE [dbo].[GN_PG_ROI_component_6a_new_customer_multipliers_update] (
    [PromotionNumber]           BIGINT          NULL,
    [PromotionStartDate]        DATE            NULL,
    [PromotionEndDate]          DATE            NULL,
    [TransactionDate]           DATE            NULL,
    [Branch_name_EN]            VARCHAR (7)     NULL,
    [new_loyalty_customers]     INT             NULL,
    [baseline_customers]        DECIMAL (15, 2) NULL,
    [baseline_new_customers]    DECIMAL (15, 2) NULL,
    [extra_new_customers]       DECIMAL (15, 2) NULL,
    [new_traffic_generator_ind] INT             NOT NULL,
    [new_customers_multiplier]  DECIMAL (5, 4)  NULL
);

