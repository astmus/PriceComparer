create proc BQQueueHistoryClear
(
	-- Out-параметры
	@ErrorMes			nvarchar(4000) out				-- Сообщение об ошибках
)
as
begin
	begin try

		delete h
		from #historyIds i
			join BQQueueHistory h on h.Id = i.Id

		return 0
	
	end try 
	begin catch 		
		set @ErrorMes = error_message()
		return 1
	end catch
end
