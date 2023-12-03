create proc BQQueueUpdate
(
	@Id			bigint,					-- Идентификатор сообщения в BQ
	@Error		nvarchar(4000),			-- Идентификатор сообщения в BQ
		-- Out-параметры
	@ErrorMes		varchar(4000) out	-- Сообщение об ошибке
)
as
begin
	
	begin try
	
		update q
		set
			q.Error = @Error,
			q.TryCount = q.TryCount + 1,
			q.NextTryDate = dateadd(minute, cast((q.TryCount + 1) * (1 + (q.TryCount + 1)) as int), getdate())
		from BQQueue q
		where
			q.Id = @Id 
		
		return 0
	
	end try 
	begin catch 		
		set @ErrorMes = error_message()
		return 1
	end catch

end
