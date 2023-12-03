create proc DistributorFreeDaysSet (@DistributorID uniqueidentifier, @minDate date, @maxDate date) as
begin

--delete _Calendar
--delete _Param
--insert _Calendar (FreeDay) select FreeDay from #Calendar
--insert _Param (DistributorID, minDate, maxDate) select @DistributorID, @minDate, @maxDate

	set nocount on
	declare @trancount int

	begin try
		if @trancount = 0
			begin transaction

		delete DistributorFreeDays from DistributorFreeDays where DISTRIBUTORID=@DistributorID and FREEDAY>=@minDate and FREEDAY<=@maxDate

		insert DistributorFreeDays (DISTRIBUTORID, FREEDAY)
		select distinct @DistributorID, FreeDay
		from #Calendar A
		where not exists(select 1 from DistributorFreeDays B where B.DISTRIBUTORID=@DistributorID and B.FREEDAY=A.FreeDay)

		if @trancount = 0
			commit transaction
			
		return 0
	end try 
	begin catch 
		if @trancount = 0
			rollback transaction

		return 1
	end catch 

end
