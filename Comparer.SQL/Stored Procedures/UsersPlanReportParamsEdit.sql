create proc UsersPlanReportParamsEdit
(
	@CallCount			int,
	@CallServicePercent	int,
	@CallPercent		int,
	@Confirmed			int,
	@CancellPercent		int,
	@TaskPercent		int,
	@AwardPrice			int,
	@BonusPercent		int,
	@CallAnswerTime		int,
	@Date				date
)
as
begin
	if not exists (select 1 from UsersPlanReportParams where MONTH(Date) = MONTH(@Date) and YEAR(Date) = YEAR(@Date))
		begin
			insert UsersPlanReportParams (CallCount, CallServicePercent, CallPercent, Confirmed, CancellPercent, TaskPercent, AwardPrice, BonusPercent,CallAnswerTime, Date)
			values (@CallCount, @CallServicePercent, @CallPercent, @Confirmed, @CancellPercent, @TaskPercent, @AwardPrice, @BonusPercent,@CallAnswerTime, @Date)
		end
		else
		begin 
			
			update UsersPlanReportParams
			set 
				CallCount			= IsNull(@CallCount, CallCount),
				CallServicePercent	= IsNull(@CallServicePercent, CallServicePercent),
				CallPercent			= IsNull(@CallPercent, CallPercent),
				Confirmed			= IsNull(@Confirmed, Confirmed),
				CancellPercent		= IsNull(@CancellPercent, CancellPercent),
				TaskPercent			= IsNull(@TaskPercent, TaskPercent),
				AwardPrice			= IsNull(@AwardPrice, AwardPrice),
				BonusPercent		= IsNull(@BonusPercent, BonusPercent),
				CallAnswerTime		= ISNULL(@CallAnswerTime, CallAnswerTime),
				Date				= @Date
			where MONTH(Date) = MONTH(@Date) and YEAR(Date) = YEAR(@Date)
		end
end
