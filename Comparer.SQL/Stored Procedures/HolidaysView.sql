create proc HolidaysView
(
	@StartDate		date		= null,		-- Начало периода
	@EndDate		date		= null		-- Конец периода
) as
begin
	select 
		Date as 'Date'
	from Holidays 
	where 
			 (@StartDate is null or (@StartDate is not null and Date >= @StartDate)) 
		 and (@EndDate is null or (@EndDate is not null and Date <= @EndDate)) 
end
