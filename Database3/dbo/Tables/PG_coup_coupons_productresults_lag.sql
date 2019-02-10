CREATE TABLE [dbo].[PG_coup_coupons_productresults_lag] (
    [CouponPeriod]     NVARCHAR (255) NULL,
    [CouponPeriod_Lag] NVARCHAR (255) NULL,
    [promotionnumber]  FLOAT (53)     NULL,
    [CrossOrUpsale]    VARCHAR (9)    NULL,
    [segment_noLag]    INT            NOT NULL,
    [Nproducts_lag]    INT            NULL,
    [quantity_lag]     FLOAT (53)     NULL,
    [revenue_lag]      FLOAT (53)     NULL,
    [margin_lag]       FLOAT (53)     NULL
);

