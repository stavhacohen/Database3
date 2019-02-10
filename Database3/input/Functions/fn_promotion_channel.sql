-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION [input].[fn_promotion_channel] ()
RETURNS 
@result TABLE 
(
	bk nvarchar(255) not null,
	name nvarchar(255) not null
)
AS
BEGIN
	insert into @result (bk, name)
	SELECT 'newspaper' as bk
       ,'newspaper' as name
	
	RETURN 
END
