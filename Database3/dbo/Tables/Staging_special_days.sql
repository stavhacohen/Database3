CREATE TABLE [dbo].[Staging_special_days] (
    [Date]               DATETIME       NULL,
    [Weekday]            INT            NULL,
    [Holiday]            NVARCHAR (255) NULL,
    [Situation]          NVARCHAR (255) NULL,
    [Quantity_corrected] FLOAT (53)     NULL
);

