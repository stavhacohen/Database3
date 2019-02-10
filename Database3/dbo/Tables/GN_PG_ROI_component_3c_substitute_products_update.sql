CREATE TABLE [dbo].[GN_PG_ROI_component_3c_substitute_products_update] (
    [PromotionNumber]    BIGINT       NULL,
    [PromotionStartDate] DATE         NULL,
    [PromotionEndDate]   DATE         NULL,
    [Branch_name_EN]     VARCHAR (7)  NULL,
    [SourceInd]          TINYINT      NULL,
    [Level]              VARCHAR (17) NULL,
    [Level_ID]           INT          NULL,
    [ProductNumber]      BIGINT       NULL
);


GO
CREATE CLUSTERED INDEX [GN_cl_index_product]
    ON [dbo].[GN_PG_ROI_component_3c_substitute_products_update]([ProductNumber] ASC);

