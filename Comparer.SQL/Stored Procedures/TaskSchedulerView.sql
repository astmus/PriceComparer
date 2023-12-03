create proc TaskSchedulerView (@ID int) as
begin

	if @ID is null
		select ID, RunTime, Path, Commentary, Done, Action, Params, TaskType, Counter
		from TaskScheduler
		order by RunTime desc, Commentary
	else
		select ID, RunTime, Path, Commentary, Done, Action, Params, TaskType, Counter
		from TaskScheduler
		where ID=@ID
		order by RunTime desc, Commentary

end
