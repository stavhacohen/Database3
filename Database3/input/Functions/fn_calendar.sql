-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [input].[fn_calendar] ()
RETURNS 
@result TABLE 
(
	bk nvarchar(255) not null,
	[date] nvarchar(255) not null
)
AS
BEGIN
	insert into @result (bk, [date])
	SELECT top 20000
		convert(nvarchar(10),dateadd(day,d.addition,'2000-01-01'),112)
		,dateadd(day,d.addition,'2000-01-01')
	FROM (
		select row_number() over (order by (select 1)) as addition
		from sys.objects, sys.objects a, sys.objects b
	) d
	RETURN 
END
