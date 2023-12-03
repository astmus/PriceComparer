create procedure ActionProcessingArchive_v2
(
	@ActionId			bigint,						-- Идентификатор действия
	-- Выходные параметры
	@ErrorMes			nvarchar(4000) out			-- Сообщение об ошибках
) as
begin

	set @ErrorMes = ''
	set nocount on

	begin try

		-- Удаляем запись из таблицы ActionsProcessingQueue
		-- Тригер вставит эту запись в таблицу ActionsProcessingQueueArchive
		delete ActionsProcessingQueue 
		where Id = @ActionId

		return 0
	end try
	begin catch
		set @ErrorMes = error_message();
		return 1
	end catch

end
