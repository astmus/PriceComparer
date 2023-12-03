create proc ActionsProcessingQueueInProcessClear as
begin
	
	begin try

		-- Обновляем таблицу
		update 
			ActionsProcessingQueue
		set
			InProcess = 0
		where 
			InProcess = 1

		return 0

	end try 
	begin catch 
		return 1
	end catch

end
