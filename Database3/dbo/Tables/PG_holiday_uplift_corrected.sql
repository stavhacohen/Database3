CREATE TABLE [dbo].[PG_holiday_uplift_corrected] (
    [holiday]                VARCHAR (25) NULL,
    [Level]                  VARCHAR (13) NOT NULL,
    [Level_ID]               INT          NULL,
    [weeks_before_holiday]   INT          NULL,
    [period_start_date]      DATE         NULL,
    [period_end_date]        DATE         NULL,
    [total_quantity]         FLOAT (53)   NULL,
    [total_quantity_corr]    FLOAT (53)   NULL,
    [baseline_quantity_corr] FLOAT (53)   NOT NULL,
    [holiday_uplift]         FLOAT (53)   NULL,
    [correction_holiday]     FLOAT (53)   NULL,
    [uplift_ind]             INT          NOT NULL
);

