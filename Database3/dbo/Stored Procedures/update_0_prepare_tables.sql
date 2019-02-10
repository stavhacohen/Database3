
-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-31
-- Description:	Prepares tables for the update
-- =============================================
CREATE PROCEDURE [dbo].[update_0_prepare_tables]
    @run_nr INT = 126,
    @run_date DATE = '2018-08-08',
    @start_date DATE = '2018-07-31',
    @end_date DATE = '2018-08-06',
    @source_data VARCHAR(100) = 'dbo.Staging_transactions_import'
AS
BEGIN

DECLARE @step INT = 1;
SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'Start of [update_0_prepare_tables]',
			SYSDATETIME()
		)

--EXEC update_00a_transform_data
--    @run_nr, @step, @run_date, @source_data
--SET @step = (SELECT MAX(step) FROM PG_update_log WHERE run_nr = @run_nr AND run_date = @run_date AND part = 0)

--EXEC update_0a_transform_transactions
--    @run_nr, @step, @run_date, @source_data
--SET @step = (SELECT MAX(step) FROM PG_update_log WHERE run_nr = @run_nr AND run_date = @run_date AND part = 0)

--EXEC update_0b_transform_assortments
--    @run_nr, @step, @run_date
--SET @step = (SELECT MAX(step) FROM PG_update_log WHERE run_nr = @run_nr AND run_date = @run_date AND part = 0)

--EXEC update_0c_transform_promotions
--    @run_nr, @step, @run_date
--SET @step = (SELECT MAX(step) FROM PG_update_log WHERE run_nr = @run_nr AND run_date = @run_date AND part = 0)

EXEC update_0d_create_update_tables
    @run_nr, @step, @run_date, @start_date, @end_date
SET @step = (SELECT MAX(step) FROM PG_update_log WHERE run_nr = @run_nr AND run_date = @run_date AND part = 0)

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'End of [update_0_prepare_tables]',
			SYSDATETIME()
		)

END

