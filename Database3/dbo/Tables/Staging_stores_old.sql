CREATE TABLE [dbo].[Staging_stores_old] (
    [Store_ID]          INT           NULL,
    [Store_name_HE]     NVARCHAR (50) NULL,
    [Format_name_HE]    NVARCHAR (25) NULL,
    [Format_name_EN]    VARCHAR (25)  NULL,
    [Property_type_HE]  NVARCHAR (7)  NULL,
    [Square_meters]     INT           NULL,
    [Selling_sq_meters] INT           NULL,
    [Address_HE]        NVARCHAR (50) NULL,
    [City_HE]           NVARCHAR (25) NULL,
    [City_EN]           VARCHAR (25)  NULL,
    [Open_date_int]     VARCHAR (8)   NULL
);

