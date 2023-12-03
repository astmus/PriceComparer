create proc TaskSchedulerDone(@ID int) as
begin

	update TaskScheduler
	set Done=1
	from TaskScheduler
	where ID=@ID

end
