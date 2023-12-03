create proc SyncObjectsQueueSave
(	
	@ClassId		int,				-- Класс сообщения
	@ObjectId		varchar(50),		-- Идентификатор объекта
	@Method			int					-- Метод
) as
begin
	
	begin try
		
		if not exists (select 1 from SyncObjectsQueue where ClassId = @ClassId and ObjectId = @ObjectId and Method = @Method) begin
			
			insert SyncObjectsQueue (ClassId, ObjectId, Method)
			values (@ClassId, @ObjectId, @Method)
		
		end

		return 0
	end try
	begin catch
		return 1
	end catch

end
