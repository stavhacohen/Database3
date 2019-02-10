-- =============================================
-- Author:		Jesper de Groot
-- Create date:	2017-10-23
-- Description:	Creates update tables
-- =============================================
CREATE PROCEDURE [dbo].[update_0d_create_update_tables]
    @run_nr INT = 1,
    @step INT = 1,
    @run_date DATE = '2017-10-10',
    @start_date DATE = '2017-07-01',
    @end_date DATE = '2017-09-30'
AS
BEGIN

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'Start of [update_0d_create_update_tables]',
			SYSDATETIME()
		)

-- Selects promotions vs. branches that are valid between start and end date
TRUNCATE TABLE PG_promotions_stores_update
INSERT INTO PG_promotions_stores_update
SELECT	  *
FROM		  PG_promotions_stores
WHERE	  PromotionStartDate <= @end_date
	   AND PromotionEndDate >= @start_date

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'Promotions vs. branches that are valid between start and end date selected',
			SYSDATETIME()
		)

SET @step = @step + 1;
INSERT INTO PG_update_log
	VALUES(	@run_nr,
			@run_date,
			0,
			@step,
			'End of [update_0d_create_update_tables]',
			SYSDATETIME()
		)

END
