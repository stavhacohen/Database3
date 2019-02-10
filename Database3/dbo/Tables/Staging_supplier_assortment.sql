CREATE TABLE [dbo].[Staging_supplier_assortment] (
    [Product_ID]        BIGINT        NULL,
    [Branch_ID]         INT           NULL,
    [Supplier_ID]       BIGINT        NULL,
    [Supplier_name_HE]  NVARCHAR (50) NULL,
    [Date_activation]   BIGINT        NULL,
    [Date_reactivation] BIGINT        NULL,
    [Date_canceled]     BIGINT        NULL,
    [Date_deleted]      BIGINT        NULL
);

