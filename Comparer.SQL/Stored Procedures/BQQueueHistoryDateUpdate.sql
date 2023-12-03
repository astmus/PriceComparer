create proc BQQueueHistoryDateUpdate
(
	@Date			datetime,					-- Дата последней выгруженной истории
		-- Out-параметры
	@ErrorMes		varchar(4000) out	-- Сообщение об ошибке
)
as
begin
	
	begin try
	
		update d
		set
			d.HistoryDate = @Date
		from BQQueueHistoryDate d
		
		return 0
	
	end try 
	begin catch 		
		set @ErrorMes = error_message()
		return 1
	end catch

end
