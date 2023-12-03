create proc ActionsProcessingQueueTakeInProcess as
begin
	
	begin try

		-- Обновляем таблицу
		update q 
		set 
			q.InProcess = 1
		from 
			ActionsProcessingQueue q
		where
			q.Id in (select i.Id from #tmp_IdActions i)

		return 0
	end try 
	begin catch 
		return 1
	end catch

end
