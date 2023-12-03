create proc QueueInMessageErrorHandled
(
	@Id			bigint,					-- Идентификатор сообщения
	@Error		nvarchar(4000)			-- Сообщение об ошибке
) as
begin

	begin try

		-- Архивируем
		insert SyncQueueInArchive (Id, PublicId, ClassId, TypeId, Sender, Body, CreatedDate, Error)
		select Id, PublicId, ClassId, TypeId, Sender, Body, CreatedDate, @Error
		from SyncQueueIn
		where Id = @Id

		-- Удаляем из очереди
		delete SyncQueueIn where Id = @Id
		
		return 0
	end try
	begin catch
		return 1
	end catch

end
