CREATE TABLE [dbo].[MM_fix_PG_correction_factors] (
    [ProductNumber]      BIGINT         NULL,
    [TransactionDate]    DATE           NULL,
    [correction_holiday] DECIMAL (7, 6) NULL,
    [correction_season]  DECIMAL (7, 6) NULL,
    [correction_factor]  DECIMAL (7, 6) NULL
);

