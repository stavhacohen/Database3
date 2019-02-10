CREATE TABLE [dbo].[Staging_assortment_product] (
    [Department]               INT            NULL,
    [Department_name_HE]       NVARCHAR (255) NULL,
    [Subdepartment]            INT            NULL,
    [Subdepartment_name_HE]    NVARCHAR (255) NULL,
    [Category]                 INT            NULL,
    [Category_name_HE]         NVARCHAR (255) NULL,
    [Group]                    INT            NULL,
    [Group_name_HE]            NVARCHAR (255) NULL,
    [Subgroup]                 INT            NULL,
    [Subgroup_name_HE]         NVARCHAR (255) NULL,
    [Product_ID]               BIGINT         NULL,
    [Product_name_HE]          NVARCHAR (255) NULL,
    [Grouping]                 INT            NULL,
    [Brand]                    INT            NULL,
    [Brand_HE]                 NVARCHAR (255) NULL,
    [Category_Manager]         INT            NULL,
    [Category_Manager_name_HE] NVARCHAR (255) NULL,
    [run_date]                 VARCHAR (10)   NOT NULL
);

