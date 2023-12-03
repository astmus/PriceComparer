create proc QueueInMessageHandled
(
	@Id		bigint		-- Идентификатор сообщения
) as
begin

	begin try

		-- Архивируем
		insert SyncQueueInArchive (Id, PublicId, ClassId, TypeId, Sender, Body, CreatedDate, Error, ErrorStatus, TryCount)
		select Id, PublicId, ClassId, TypeId, Sender, Body, CreatedDate, Error, ErrorStatus, TryCount
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
