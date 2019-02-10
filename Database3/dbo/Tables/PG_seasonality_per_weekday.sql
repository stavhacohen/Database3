CREATE TABLE [dbo].[PG_seasonality_per_weekday] (
    [branch_name_EN]               NVARCHAR (255) NULL,
    [weekday]                      INT            NULL,
    [quantity]                     FLOAT (53)     NULL,
    [correlation_weekday]          FLOAT (53)     NULL,
    [relative_correlation_weekday] FLOAT (53)     NULL
);

