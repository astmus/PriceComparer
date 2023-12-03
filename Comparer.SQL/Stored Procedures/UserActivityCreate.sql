create proc UserActivityCreate
(	
	@SourceId			int,					-- Идентификатор источника действия
	@EntityId			int,					-- Идентификатор сущности
	@ObjectId			varchar(128),			-- Идентификатор обьекта над которым совершалась активность

	@AuthorId			uniqueidentifier,		-- Идентификатор пользователя

	@ErrorMes			nvarchar(4000) out		-- Сообщение об ошибках
) as
begin

	set @ErrorMes = ''

	declare 
		@NewId	bigint	= -1

	declare @trancount int
	select @trancount = @@trancount

	begin try

		if @trancount = 0
			begin transaction

		-- Сохраняем пакет активности пользователя
		insert ActivityUserBatch(UserId, SourceId, EntityId, ObjectId)
		values (@AuthorId, @SourceId, @EntityId, @ObjectId)

		set @NewId = @@identity

		-- Сохраняем позиции активности пользователя
		insert ActivityBatchItems
			(BatchId, ActionId)
		select
			@NewId, a.ActionId
		from #Actions a
			
		if @trancount = 0
			commit transaction

	end try
	begin catch		
		if @trancount = 0
			rollback transaction
		set @ErrorMes = error_message()
		return 1
	end catch

end
