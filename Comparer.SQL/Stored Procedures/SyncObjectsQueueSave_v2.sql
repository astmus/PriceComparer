create proc SyncObjectsQueueSave_v2
(	
	@ClassId		int,				-- Класс сообщения
	@ObjectId		varchar(50),		-- Идентификатор объекта
	@Method			int,				-- Метод
	@Data			nvarchar(max)		-- Данные
) as
begin
	
	begin try
		
		if not exists (select 1 from SyncObjectsQueue where ClassId = @ClassId and ObjectId = @ObjectId and Method = @Method and Data = @Data) begin
			
			insert SyncObjectsQueue (ClassId, ObjectId, Method, Data)
			values (@ClassId, @ObjectId, @Method, @Data)
		
		end

		return 0
	end try
	begin catch
		return 1
	end catch

end
