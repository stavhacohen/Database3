CREATE TABLE [dbo].[TC_participation_in_promotions] (
    [PROMOTION_ID]                        INT           NULL,
    [DESC_PROMOTION]                      NVARCHAR (40) NULL,
    [DATE_FROM]                           INT           NULL,
    [DATE_TO]                             INT           NULL,
    [SUPPLIER_ID]                         INT           NULL,
    [DESC_SUPPLIER]                       NVARCHAR (24) NULL,
    [Perc_participation_purchase_price]   REAL          NULL,
    [Amount_participation_purchase_price] REAL          NULL
);

