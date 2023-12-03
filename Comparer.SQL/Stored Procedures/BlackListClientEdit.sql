create proc BlackListClientEdit 
(
	@ClientId			uniqueidentifier,		-- Идентификатор клиента
	@StatusId			int,					-- Идентификатор статуса
	-- Выходные параметры
	@ErrorMes			nvarchar(4000) out		-- Сообщение об ошибках
)as
begin

	set @ErrorMes = ''
	set nocount on
	
	begin try
	
		-- Если клиента еще нет в списке
		if not exists (select 1 from ClientsBlackList where ClientId = @ClientId)
		begin

			insert ClientsBlackList (ClientId, StatusId)
			values (@ClientId, @StatusId)

		end
		/*else if @BlackListStatusId is null
		begin

			delete ClientsBlackList
			where ClientId = @ClientId

		end else*/
		begin

			update 
				ClientsBlackList
			set 
				StatusId = @StatusId
			where 
				ClientId = @ClientId

		end 

		return 0

	end try 
	begin catch 
		set @ErrorMes = error_message() 
		return 1
	end catch

end
