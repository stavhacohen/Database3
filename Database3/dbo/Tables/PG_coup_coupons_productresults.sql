CREATE TABLE [dbo].[PG_coup_coupons_productresults] (
    [CouponPeriod]    NVARCHAR (255) NULL,
    [promotionnumber] FLOAT (53)     NULL,
    [CrossOrUpsale]   VARCHAR (9)    NULL,
    [segment]         INT            NOT NULL,
    [products]        INT            NULL,
    [quantity]        FLOAT (53)     NULL,
    [revenue]         FLOAT (53)     NULL,
    [margin]          FLOAT (53)     NULL
);

