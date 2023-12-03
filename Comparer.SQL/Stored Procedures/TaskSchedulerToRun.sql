create proc TaskSchedulerToRun as
begin

	declare @runTime datetime
	
	select @runTime = getdate()

	select ID, RunTime, Path, Commentary, Done, Action, Params, TaskType, Counter
	from TaskScheduler
	where RunTime<=@runTime and Done=0
	
end
