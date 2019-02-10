CREATE TABLE [dbo].[Staging_coupons_control_group] (
    [YM]          INT NULL,
    [HouseholdID] INT NULL
);


GO
CREATE NONCLUSTERED INDEX [IND_householdID]
    ON [dbo].[Staging_coupons_control_group]([HouseholdID] ASC);


GO
CREATE NONCLUSTERED INDEX [IND_YM]
    ON [dbo].[Staging_coupons_control_group]([YM] ASC);

