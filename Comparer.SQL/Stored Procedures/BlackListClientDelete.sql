create proc BlackListClientDelete 
(
	@ClientId			uniqueidentifier,		-- Идентификатор клиента
	-- Выходные параметры
	@ErrorMes			nvarchar(4000) out		-- Сообщение об ошибках
)as
begin

	set @ErrorMes = ''
	set nocount on
	
	begin try
			
		delete ClientsBlackList where ClientId = @ClientId

		return 0

	end try 
	begin catch 
		set @ErrorMes = error_message() 
		return 1
	end catch

end
