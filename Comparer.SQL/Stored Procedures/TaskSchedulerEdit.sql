-- exec TaskSchedulerEdit 1, null, '20170601 17:10:12', 'C:', '12', '34', '56', 1
-- exec TaskSchedulerToRun
-- exec TaskSchedulerView null
-- exec TaskSchedulerEdit 4, 1, null, null, null, null, null, null
create proc TaskSchedulerEdit(@Operation int, @ID int, @RunTime datetime, @Path nvarchar(500), @Commentary nvarchar(500), @Action nvarchar(255), @Params nvarchar(500), @TaskType int) as
begin

	set nocount on

	declare @trancount int

	select @trancount = @@TRANCOUNT

	if @trancount = 0
		begin transaction

	begin try 
		
		if @Operation=1
			insert TaskScheduler (RunTime, Path, Commentary, Done, Action, Params, TaskType, Counter)
			values(@RunTime, @Path, @Commentary, 0, @Action, @Params, @TaskType, 0)
			
		if @Operation=2
			update TaskScheduler
			set RunTime=@RunTime, Path=@Path, Commentary=@Commentary, Action=@Action, Params=@Params
			from TaskScheduler
			where ID=@ID
			
		if @Operation=3
			update TaskScheduler
			set Done=3
			from TaskScheduler
			where ID=@ID
			
		if @Operation=4
		begin
			declare @TskType int
			select @TskType=TaskType from TaskScheduler where ID=@ID

			if (@TskType=1)
			begin
				
				declare @taskParams nvarchar(1000) = '{"discount_ids":[444],"period_type":2,"period_value":120}'
				--set @taskParams = (select Params from TaskScheduler where ID=@ID)

				declare @index1 int
				declare @index2 int

				declare @type int = -1
				declare @value int = -1

				-- Тип периода: 0 - день, 1 - час, 2 - минута
				declare @periodType nvarchar(500) = ''
				select @index1 = CHARINDEX('period_type', @taskParams)
				--select @index1 as '@index1'
				if @index1 > 0 begin
					
					select @periodType = substring(@taskParams, @index1 + len('period_type') + 2, len(@taskParams) - @index1 - len('period_type') - 1)
					select @index2 = CHARINDEX(',', @periodType)

					if @index2 > 0 begin

						select @periodType = substring(@periodType, 1, @index2 - 1)
						select @type = CAST(@periodType as int)

						-- Значение периода
						declare @periodValue nvarchar(500) = ''
						select @index1 = CHARINDEX('period_value', @taskParams)
						if @index1 > 0 begin
					
							select @periodValue = substring(@taskParams, @index1 + len('period_value') + 2, len(@taskParams) - @index1 - len('period_value') - 1)
							select @index2 = CHARINDEX(',', @periodValue)

							if @index2 > 0 begin

								select @periodValue = substring(@periodValue, 1, @index2 - 1)
								select @value = CAST(@periodValue as int)

							end else begin

								select @index2 = CHARINDEX('}', @periodValue)
								if @index2 > 0 begin

									select @periodValue = substring(@periodValue, 1, @index2 - 1)
									select @value = CAST(@periodValue as int)

								end

							end

						end

					end
					
				end

				--select @type as '@periodType', @value as '@periodValue'

				if @type <> -1 and @value <> -1 begin

					update TaskScheduler
					set RunTime=case @type
						when 0 then dateadd(dd, @value, RunTime)
						when 1 then dateadd(hh, @value, RunTime)
						when 2 then dateadd(mi, @value, RunTime)
						else
							dateadd(dd, 1, RunTime)
						end,
						Counter=Counter+1
					from TaskScheduler
					where ID=@ID

				end else begin

					update TaskScheduler
					set RunTime=dateadd(dd, 1, RunTime),
						Counter=Counter+1
					from TaskScheduler
					where ID=@ID

				end
			end
		end
			
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
