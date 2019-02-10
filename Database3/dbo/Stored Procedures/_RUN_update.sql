-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-31
-- Description:	Execute the weekly update
-- =============================================
CREATE PROCEDURE [dbo].[_RUN_update]

    -- Standard input
    @run_nr INT = 181,
    @run_date DATE = '2019-02-10',
    @start_date DATE = '2018-11-16',
    @end_date DATE = '2018-11-30',

    -- Update part 0
    @source_data VARCHAR(100) = 'dbo.Staging_transactions_import',

    -- Update part 3
    @customer_days INT = 42,
    @new_customer_days INT = 91,
    @promo_perc FLOAT = 0.6,
    @customer_batch INT = 500000,
    @nr_weeks INT = 13,

    -- Update part 4
    @baseline_days INT = 28,

    -- Update part 6
    @start_date_hist DATE = '2015-01-01',
    @min_perc FLOAT = 0.05,
    @min_amount INT = 10,

    -- Update part 7
    @after_days INT = 28,
    @min_uplift FLOAT = 0.95,
    @max_uplift FLOAT = 100.0,
    @min_discount FLOAT = 0.05,
    @level_batch INT = 100000,
    @day_batch INT = 30,
    @bound_revenue FLOAT = 50000,
    @upper_bound_margin FLOAT = 15000,
    @lower_bound_margin FLOAT = 0,
    @start_date_promo_expl DATE = NULL,
    @end_date_promo_expl DATE = NULL,

    -- Update part 8
    @min_quantity INT = 2500

AS
BEGIN

IF @run_nr IS NULL
BEGIN
    SET @run_nr = (SELECT MAX(run_nr)+1 FROM PG_update_log)
    SET @run_date = CONVERT(date,GETDATE())
    SET @start_date = (SELECT DATEADD(day,1,MAX(TransactionDate)) FROM PG_sales_per_product_per_day_wo_returns)
    SET @end_date = (SELECT DATEADD(day,7,MAX(TransactionDate)) FROM PG_sales_per_product_per_day_wo_returns)
END


INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			1,
			'Start of the update',
			SYSDATETIME()
		)

IF @start_date_promo_expl IS NULL
BEGIN
    SET @start_date_promo_expl = DATEADD(yy, DATEDIFF(yy, 0, @end_date), 0) --DATEADD(year,-1,@end_date)
    SET @end_date_promo_expl = @end_date
END

EXEC	update_0_prepare_tables
    @run_nr, @run_date, @start_date, @end_date, @source_data

EXEC	update_1_promo_product_ind
    @run_nr, @run_date, @start_date, @end_date

EXEC	update_2_sales_per_product_per_day_wo_returns
    @run_nr, @run_date, @start_date, @end_date

EXEC update_3_customer_information
    @run_nr, @run_date, @start_date, @end_date, @customer_days, @new_customer_days, @promo_perc, @customer_batch, @nr_weeks

EXEC update_4_correction_factors
    @run_nr, @run_date, @start_date, @end_date, @baseline_days

EXEC update_5_transactions_promotions
    @run_nr, @run_date, @start_date, @end_date

EXEC update_6a_new_customer_percentage
    @run_nr, @run_date, @start_date, @end_date

EXEC update_6b_in_out_indicators
    @run_nr, @run_date, @start_date, @end_date, 101, @start_date_hist, @min_perc, @min_amount

EXEC update_7_ROI_promotions
    @run_nr, @run_date, @start_date, @end_date, @baseline_days, @after_days, @customer_days,
    @min_uplift, @max_uplift, @min_discount, @level_batch, @day_batch, @customer_batch,
    @bound_revenue, @upper_bound_margin, @lower_bound_margin, @start_date_promo_expl, @end_date_promo_expl

--EXEC update_8_validation_baseline
--    @run_nr, @run_date, @start_date, @baseline_days, @min_quantity

--EXEC update_9_create_fact_performance
--    @run_nr, @run_date


INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			10,
			0,
			'End of the update',
			SYSDATETIME()
		)

END
