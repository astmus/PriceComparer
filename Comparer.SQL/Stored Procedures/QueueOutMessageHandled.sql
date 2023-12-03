create proc QueueOutMessageHandled
(
	@Id		bigint		-- Идентификатор сообщения
) as
begin

	begin try

	
		-- Архивируем
		insert SyncQueueOutArchive (Id, PublicId, ClassId, Receivers, Body, CreatedDate, Error, ErrorStatus, ArchiveDate)
		select Id, PublicId, ClassId, Receivers, Body, CreatedDate, Error, ErrorStatus, GETDATE()
		from SyncQueueOut
		where Id = @Id


		delete SyncQueueOut where Id = @Id

		return 0
	end try
	begin catch
		return 1
	end catch

end
