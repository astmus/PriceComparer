create proc QueueOutSave
(	
	@ClassId		int,				-- Класс сообщения
	@Receivers		varchar(500),		-- Получатели
	@Body			nvarchar(max)		-- Тело сообщения
) as
begin
	
	begin try

		insert SyncQueueOut (ClassId, Receivers, Body)
		values (@ClassId, @Receivers, @Body)

		return 0
	end try
	begin catch
		return 1
	end catch

end
