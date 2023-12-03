create proc SyncProtocolDelete
(
	@Id			bigint,				-- Идентификатор строки протокола		
	-- Выходные параметры
	@ErrorMes	nvarchar(255) out	-- Сообщение об ошибках
) as
begin

	set @ErrorMes = ''

	begin try

		delete SyncProtocol where Id = @Id

		return 0
	end try
	begin catch
		set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры SyncProtocolDelete!'		
		return 1
	end catch

end
