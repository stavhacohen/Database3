CREATE TABLE [dbo].[PG_coup_LP_loyalty_cust_information] (
    [householdID]         BIGINT       NULL,
    [CouponPeriod]        VARCHAR (30) NULL,
    [Cust_group]          VARCHAR (30) NULL,
    [Nr_coupons_received] INT          NULL,
    [Nr_coupons_used]     INT          NULL,
    [rev]                 FLOAT (53)   NULL,
    [mar]                 FLOAT (53)   NULL,
    [quan]                FLOAT (53)   NULL,
    [N_visits]            INT          NULL,
    [segment]             INT          NOT NULL
);

