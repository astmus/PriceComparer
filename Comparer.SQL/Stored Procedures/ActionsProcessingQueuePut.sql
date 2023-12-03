create procedure ActionsProcessingQueuePut
(
	@ObjectId			nvarchar(50),		-- Идентификатор объекта
	@OperationId		int,				-- Идентификатор операции
	@ObjectTypeId		int,				-- Идентификатор типа объекта
	@ActionObject		nvarchar(max),		-- Объект действия
	@PriorityLevel		int,				-- Приоритет
	@AuthorId			uniqueidentifier	-- Идентификатор автора
) as
begin

	set nocount on
	
	begin try

		insert ActionsProcessingQueue (ObjectId, ObjectTypeId, OperationId, ActionObject, PriorityLevel, AuthorId)
			values (@ObjectId, @ObjectTypeId, @OperationId, @ActionObject, @PriorityLevel, @AuthorId)

		return 0
	end try
	begin catch
		return 1
	end catch

end
