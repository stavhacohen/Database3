CREATE TABLE [dbo].[Staging_assortment_supplier] (
    [Product_ID]        BIGINT         NULL,
    [Branch_ID]         INT            NULL,
    [Supplier_ID]       INT            NULL,
    [Supplier_name_HE]  NVARCHAR (255) NULL,
    [Date_activation]   INT            NULL,
    [Date_reactivation] INT            NULL,
    [Date_canceled]     INT            NULL,
    [Date_deleted]      INT            NULL,
    [run_date]          VARCHAR (10)   NOT NULL
);

