create proc QueueInSave
(	
	@PublicId		nvarchar(50),		-- Идентификатор обмена (публичный)
	@ClassId		int,				-- Класс сообщения
	@TypeId			int,				-- Тип сообщения
	@Sender			varchar(50),		-- Отправитель
	@Body			nvarchar(max)		-- Тело сообщения
) as
begin

	begin try

		insert SyncQueueIn (PublicId, ClassId, TypeId, Sender, Body)
		values (@PublicId, @ClassId, @TypeId, @Sender, @Body)

		return 0
	end try
	begin catch
		return 1
	end catch

end
