create proc SyncObjectsQueueDelete
(	
	@QueueId		bigint				-- Идентификатор в очереди
) as
begin
	
	begin try
	 
		-- Архивируем
		insert SyncObjectsQueueArchive (Id, ObjectId, ClassId, Method, Data, CreatedDate, Error, ErrorStatus, ArchiveDate)
		select Id, ObjectId, ClassId, Method, Data, CreatedDate, Error, ErrorStatus,  getdate()
		from SyncObjectsQueue 
		where Id = @QueueId

		delete SyncObjectsQueue where Id = @QueueId

		return 0
	end try
	begin catch
		return 1
	end catch

end
