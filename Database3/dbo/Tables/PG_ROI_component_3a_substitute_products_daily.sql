CREATE TABLE [dbo].[PG_ROI_component_3a_substitute_products_daily] (
    [PromotionNumber]    BIGINT       NULL,
    [PromotionStartDate] DATE         NULL,
    [PromotionEndDate]   DATE         NULL,
    [Branch_name_EN]     VARCHAR (7)  NULL,
    [SourceInd]          TINYINT      NULL,
    [Level]              VARCHAR (17) NULL,
    [Level_ID]           INT          NULL,
    [TransactionDate]    DATE         NULL,
    [ProductNumber]      BIGINT       NULL
);


GO
CREATE CLUSTERED INDEX [cl_index_date]
    ON [dbo].[PG_ROI_component_3a_substitute_products_daily]([TransactionDate] ASC);

