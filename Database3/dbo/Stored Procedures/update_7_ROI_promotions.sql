-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-18
-- Description:	Calculates ROI of promotions
-- =============================================
CREATE PROCEDURE [dbo].[update_7_ROI_promotions]
    @run_nr INT = 177,
    @run_date DATE = '2019-02-05',
    @start_date DATE = '2018-10-01',
    @end_date DATE = '2018-10-15',
	@baseline_days INT = 28,
	@after_days INT = 28,
	@customer_days INT = 42,
	@min_uplift FLOAT = 0.95,
	@max_uplift FLOAT = 100.0,
	@min_discount FLOAT = 0.05,
	@level_batch INT = 100000,
	@day_batch INT = 30,
	@customer_batch INT = 500000,
	@bound_revenue FLOAT = 50000,
	@upper_bound_margin FLOAT = 15000,
	@lower_bound_margin FLOAT = 0,
	@start_date_promo_expl DATE = NULL,
	@end_date_promo_expl DATE = NULL
AS
BEGIN

DECLARE @step INT = 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'Start of [update_7_ROI_promotions]',
			SYSDATETIME()
		)


----Prepares promotion tables
EXEC dbo.update_7a_ROI_promotions_prepare
	   @run_nr,
	   @run_date,
	   @step,
	   @start_date,
	   @end_date,
	   @after_days
SET @step = (SELECT MAX(step) FROM PG_update_log WHERE run_nr = @run_nr AND run_date = @run_date AND part = 7)

-- Calculates all components of the waterfall
EXEC dbo.update_7b_ROI_promotions_component_1
	   @run_nr,
	   @run_date,
	   @step,
	   @start_date,
	   @end_date
SET @step = (SELECT MAX(step) FROM PG_update_log WHERE run_nr = @run_nr AND run_date = @run_date AND part = 7)

EXEC dbo.update_7c_ROI_promotions_component_2
	   @run_nr,
	   @run_date,
	   @step,
	   @start_date,
	   @end_date,
	   @baseline_days,
	   @min_uplift,
	   @max_uplift,
	   @min_discount
SET @step = (SELECT MAX(step) FROM PG_update_log WHERE run_nr = @run_nr AND run_date = @run_date AND part = 7)

EXEC dbo.update_7d_ROI_promotions_component_3
	   @run_nr,
	   @run_date,
	   @step,
	   @start_date,
	   @end_date,
	   @level_batch,
	   @day_batch,
	   @baseline_days
SET @step = (SELECT MAX(step) FROM PG_update_log WHERE run_nr = @run_nr AND run_date = @run_date AND part = 7)

EXEC dbo.update_7e_ROI_promotions_components_4_5
	   @run_nr,
	   @run_date,
	   @step,
	   @start_date,
	   @end_date
SET @step = (SELECT MAX(step) FROM PG_update_log WHERE run_nr = @run_nr AND run_date = @run_date AND part = 7)

EXEC dbo.update_7f_ROI_promotions_component_6
	   @run_nr,
	   @run_date,
	   @step,
	   @start_date,
	   @end_date,
	   @after_days
SET @step = (SELECT MAX(step) FROM PG_update_log WHERE run_nr = @run_nr AND run_date = @run_date AND part = 7)

EXEC dbo.update_7g_ROI_promotions_component_7
	   @run_nr,
	   @run_date,
	   @step,
	   @start_date,
	   @end_date,
	   @after_days,
	   @customer_days,
	   @customer_batch
SET @step = (SELECT MAX(step) FROM PG_update_log WHERE run_nr = @run_nr AND run_date = @run_date AND part = 7)

EXEC dbo.update_7h_ROI_promotions_component_8
	   @run_nr,
	   @run_date,
	   @step,
	   @start_date,
	   @end_date,
	   @after_days
SET @step = (SELECT MAX(step) FROM PG_update_log WHERE run_nr = @run_nr AND run_date = @run_date AND part = 7)


EXEC dbo.update_7i_ROI_promotions_generate_output
	   @run_nr,
	   @run_date,
	   @step,
	   @start_date,
	   @end_date,
	   @bound_revenue,
	   @upper_bound_margin,
	   @lower_bound_margin
SET @step = (SELECT MAX(step) FROM PG_update_log WHERE run_nr = @run_nr AND run_date = @run_date AND part = 7)

EXEC dbo.update_7j_ROI_promotions_input_RAS
	   @run_nr,
	   @run_date,
	   @step
SET @step = (SELECT MAX(step) FROM PG_update_log WHERE run_nr = @run_nr AND run_date = @run_date AND part = 7)

EXEC dbo.update_7k_ROI_promotions_input_ROI_explorer
	   @run_nr,
	   @run_date,
	   @step,
	   @start_date_promo_expl,
	   @end_date_promo_expl
SET @step = (SELECT MAX(step) FROM PG_update_log WHERE run_nr = @run_nr AND run_date = @run_date AND part = 7)

EXEC dbo.update_7l_create_Promotion_Score_Card
	    @end_date,
		@run_nr,
		@run_date,
		@step
SET @step = (SELECT MAX(step) FROM PG_update_log WHERE run_nr = @run_nr AND run_date = @run_date AND part = 7)

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			7,
			@step,
			'End of [update_7_ROI_promotions]',
			SYSDATETIME()
		)

END
