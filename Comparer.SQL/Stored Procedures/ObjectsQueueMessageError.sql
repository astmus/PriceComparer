create proc ObjectsQueueMessageError
(
	@Id				bigint,				-- Идентификатор сообщения
	@ErrorMessage	nvarchar(4000)		-- Сообщение об ошибке
) as
begin

	begin try

		update q
		set 
			q.Error = @ErrorMessage,
			q.ErrorStatus = 1
			--,
			--q.TryCount = q.TryCount + 1,
			--q.NextTryDate = dateadd(MINUTE, cast((q.TryCount + 1) * (1 + (q.TryCount + 1)) as int), getdate())							
		from SyncObjectsQueue q
		where q.Id = @Id

		return 0
	end try
	begin catch
		return 1
	end catch

end
