CREATE TABLE [dbo].[Staging_coupons_yr17] (
    [YearMonth_coupon] INT           NULL,
    [HouseHoldID]      INT           NULL,
    [Rank_qlf]         SMALLINT      NULL,
    [FullCouponNum]    VARCHAR (10)  NULL,
    [CouponNum]        INT           NULL,
    [RewardNr]         INT           NULL,
    [OfferCode1]       SMALLINT      NULL,
    [Offername]        NVARCHAR (22) NULL,
    [OfferDsc]         NVARCHAR (62) NULL,
    [CouponType]       SMALLINT      NULL,
    [CouponTypeDsc]    NVARCHAR (30) NULL,
    [CrossOrUpsale]    VARCHAR (9)   NULL,
    [IndNboLead]       SMALLINT      NULL,
    [CustGroupCode]    SMALLINT      NULL
);


GO
CREATE NONCLUSTERED INDEX [householdID_index]
    ON [dbo].[Staging_coupons_yr17]([HouseHoldID] ASC);


GO
CREATE NONCLUSTERED INDEX [rewardNR_index]
    ON [dbo].[Staging_coupons_yr17]([RewardNr] ASC);

