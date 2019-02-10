CREATE TABLE [MICOMPANY\hagaiweiss].[HW_Staging_participation_purchase_discount_withoutSubchain] (
    [product]       FLOAT (53)     NULL,
    [name]          NVARCHAR (255) NULL,
    [supplier]      FLOAT (53)     NULL,
    [name1]         NVARCHAR (255) NULL,
    [grouping]      FLOAT (53)     NULL,
    [group]         FLOAT (53)     NULL,
    [from date]     FLOAT (53)     NULL,
    [to date]       FLOAT (53)     NULL,
    [sub chain]     INT            NOT NULL,
    [catalog price] FLOAT (53)     NULL,
    [discount%]     FLOAT (53)     NULL,
    [neto price]    FLOAT (53)     NULL
);

