create proc BQQueueHistorySave
(
	--@Type				int,							-- Тип сообщений
	--@Message			nvarchar(max),					-- Данные для отправки в BQ
		-- Out-параметры
	@ErrorMes			nvarchar(4000) out				-- Сообщение об ошибках
)
as
begin
	
	begin try
	
		insert 
			BQQueueHistory ([Type], [Data])
		select 
			h.[Type], h.[Message]
		from
			#historyOrders h
		--values 
		--	(@Type, @Message)
		
		return 0
	
	end try 
	begin catch 		
		set @ErrorMes = error_message()
		return 1
	end catch

end
