create proc QueueOutSave_v2
(	
	@PublicId			nvarchar(50),		-- Идентификатор обмена (публичный)
	@ClassId			int,				-- Идентификатор класса
	@Receivers			nvarchar(255),		-- Получатель
	@Body				nvarchar(max)		-- Тело сообщения
)as
begin
	
	begin try 

		insert SyncQueueOut(PublicId, ClassId, Receivers, Body)
		values (@PublicId, @ClassId, @Receivers, @Body)

		return 0
	end try
	begin catch
		return 1
	end catch

end

-- Тестирование
-- exec QueueOutSave_v2 newid(), 16, 'Ozon', ''
