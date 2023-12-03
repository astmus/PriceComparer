create proc QueueInMessageErrorHandled_v2
(
	@Id					bigint,					-- Идентификатор сообщения
	@ErrorStatus		int,			-- Идентификатор статуса ошибки
	@Error				nvarchar(4000)			-- Сообщение об ошибке
) as
begin

	begin try
	
		update SyncQueueIn
		set ErrorStatus = @ErrorStatus,
			Error = @Error,
			TryCount = TryCount + 1,
			NextTryDate = dateadd(MINUTE, cast((TryCount + 1) * (1 + (TryCount + 1)) as int), getdate())							
		where Id = @Id
		
		return 0
	end try
	begin catch
		return 1
	end catch

end

-- Тестирование
-- select * from SyncQueueIn
-- select * from SyncQueueInArchive
-- exec QueueInMessageErrorHandled 15
