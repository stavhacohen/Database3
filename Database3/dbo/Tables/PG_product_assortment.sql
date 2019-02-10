CREATE TABLE [dbo].[PG_product_assortment] (
    [Department_ID]            INT            NULL,
    [Subdepartment_ID]         INT            NULL,
    [Category_ID]              INT            NULL,
    [Group_ID]                 INT            NULL,
    [Subgroup_ID]              INT            NULL,
    [Cluster_ID]               INT            NULL,
    [Product_ID]               BIGINT         NULL,
    [Product_name_HE]          NVARCHAR (255) NULL,
    [Brand_ID]                 INT            NULL,
    [Brand_name_HE]            NVARCHAR (255) NULL,
    [Category_manager]         INT            NULL,
    [Category_manager_name_HE] NVARCHAR (255) NULL,
    [Private_label]            INT            NOT NULL
);

