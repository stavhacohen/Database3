CREATE TABLE [dbo].[PG_ROI_component_3g_substitution_suppliers_update] (
    [PromotionNumber]       BIGINT          NULL,
    [PromotionStartDate]    DATE            NULL,
    [PromotionEndDate]      DATE            NULL,
    [ProductNumber]         BIGINT          NULL,
    [Supplier_ID]           INT             NULL,
    [Branch_name_EN]        VARCHAR (7)     NULL,
    [SourceInd]             SMALLINT        NULL,
    [TransactionDate]       DATE            NULL,
    [Quantity_3_subs_group] DECIMAL (15, 2) NULL,
    [Revenue_3_subs_group]  DECIMAL (15, 2) NULL,
    [Margin_3_subs_group]   DECIMAL (15, 2) NULL,
    [Ind_positive_subs]     TINYINT         NULL,
    [Ind_high_subs]         TINYINT         NULL
);

