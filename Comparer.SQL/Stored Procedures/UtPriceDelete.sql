create proc UtPriceDelete
(
	@Id					int,							--
	-- Out-параметры
	@ErrorMes			nvarchar(255) out				-- Сообщение об ошибках
) as
begin
	
	set nocount on
	set @ErrorMes = ''
		
	begin try

		-- Создаем запись
		delete UtPrices where Id = @Id

		return 0
	end try
	begin catch		
		set @ErrorMes = 'Ошибка хранимой процедуры UtPriceDelete!'
		return 1
	end catch

end
