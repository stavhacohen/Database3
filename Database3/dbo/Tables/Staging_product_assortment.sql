CREATE TABLE [dbo].[Staging_product_assortment] (
    [Department_ID]         INT           NULL,
    [Department_name_HE]    NVARCHAR (50) NULL,
    [Department_name_EN]    VARCHAR (50)  NULL,
    [Subdepartment_ID]      INT           NULL,
    [Subdepartment_name_HE] NVARCHAR (50) NULL,
    [Subdepartment_name_EN] VARCHAR (50)  NULL,
    [Category_ID]           INT           NULL,
    [Category_name_HE]      NVARCHAR (50) NULL,
    [Category_name_EN]      VARCHAR (75)  NULL,
    [Group_ID]              INT           NULL,
    [Group_name_HE]         NVARCHAR (50) NULL,
    [Group_name_EN]         VARCHAR (50)  NULL,
    [Subgroup_ID]           INT           NULL,
    [Subgroup_name_HE]      NVARCHAR (50) NULL,
    [Product_ID]            BIGINT        NOT NULL,
    [Product_name_HE]       NVARCHAR (50) NULL,
    [Supplier_ID]           BIGINT        NULL,
    [Selfsupply]            INT           NULL,
    [Brand_HE]              NVARCHAR (25) NULL
);

