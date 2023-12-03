create procedure ActionProcessingArchive
(
	@ActionId			bigint						-- Идентификатор действия
) as
begin

	begin try

		-- Удаляем запись из таблицы ActionsProcessingQueue
		-- Тригер вставит эту запись в таблицу ActionsProcessingQueueArchive
		delete ActionsProcessingQueue where Id = @ActionId

		return 0
	end try
	begin catch
		return 1
	end catch

end
