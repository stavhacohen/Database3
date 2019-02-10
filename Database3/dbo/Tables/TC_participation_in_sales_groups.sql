CREATE TABLE [dbo].[TC_participation_in_sales_groups] (
    [Participation_ID]                    INT           NULL,
    [Participation_name_HE]               NVARCHAR (50) NULL,
    [DATE_FROM]                           INT           NULL,
    [DATE_TO]                             INT           NULL,
    [SUPPLIER_ID]                         INT           NULL,
    [DESC_SUPPLIER]                       NVARCHAR (24) NULL,
    [Amount_participation_purchase_price] REAL          NULL,
    [Perc_participation_purchase_price]   REAL          NULL,
    [Group_ID]                            SMALLINT      NULL,
    [Subgroup_ID]                         SMALLINT      NULL,
    [Exclude]                             NVARCHAR (1)  NULL
);

