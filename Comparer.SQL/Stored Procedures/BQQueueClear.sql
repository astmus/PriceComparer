create proc BQQueueClear
(
	@Id			bigint,					-- Идентификатор сообщения в BQ
		-- Out-параметры
	@ErrorMes		varchar(4000) out	-- Сообщение об ошибке
)
as
begin
	
	begin try
		if (@Id is not null) begin
			delete q
			from BQQueue q
			where
				q.Id = @Id 
			
		end

		return 0
	end try 
	begin catch 		
		set @ErrorMes = error_message()
		return 1
	end catch

end
