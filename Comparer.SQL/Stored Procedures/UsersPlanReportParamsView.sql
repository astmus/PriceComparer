create proc UsersPlanReportParamsView
(
	@Date	date
)
as
begin
	
	select 
		CallCount				as	'CallCount', 
		CallServicePercent		as	'CallServicePercent',
		CallPercent				as	'CallPercent', 
		Confirmed				as	'Confirmed', 
		CancellPercent			as	'CancellPercent', 
		TaskPercent				as	'TaskPercent', 
		AwardPrice				as  'AwardPrice', 
		BonusPercent			as	'BonusPercent',
		CallAnswerTime          as  'CallAnswerTime'
	from
		UsersPlanReportParams 
	where
		MONTH(Date) = MONTH(@Date) and YEAR(Date) = YEAR(@Date)

end
