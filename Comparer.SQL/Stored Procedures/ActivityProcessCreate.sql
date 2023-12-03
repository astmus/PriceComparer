create proc ActivityProcessCreate
(	
	@TypeId				int,					-- ИД типа процесса
	@SourceId			int,					-- Идентификатор источника действия
	@UserId				uniqueidentifier,		-- ИД пользователя
	@EntityTypeId		int,					-- ИД сущности
	@EntityId			varchar(36),			-- ИД обьекта активности
	@StartTime			datetime,				-- время начала
	@FinishTime			datetime,				-- время окончания
	@ErrorMes			varchar(4000) out
) as
begin

	set @ErrorMes = ''

	begin try

		insert ActivityProcesses
			(TypeId, SourceId, UserId, EntityTypeId, EntityId, StartTime, FinishTime)
		values
			(@TypeId, @SourceId, @UserId, @EntityTypeId, @EntityId, @StartTime, @FinishTime)

	end try
	begin catch

		set @ErrorMes = error_message()
		return 1

	end catch

end
