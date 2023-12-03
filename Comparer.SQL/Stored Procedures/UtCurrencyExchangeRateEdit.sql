create proc UtCurrencyExchangeRateEdit
(
	@Id				int,				-- Идентификатор записи
	@Rate			decimal(10, 4),		-- Курс
	-- Out-параметры
	@ErrorMes		nvarchar(4000) out	-- Сообщение об ошибках
) as
begin
	
	set nocount on
	set @ErrorMes = ''
		
	begin try
	
		update h
		set 
			h.Rate = @Rate
		from
			UtCurrencyExchangeRateHistory h
		where 
			h.Id = @Id

		return 0
	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

end
