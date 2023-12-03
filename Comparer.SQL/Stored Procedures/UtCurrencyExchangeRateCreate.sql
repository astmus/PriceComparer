create proc UtCurrencyExchangeRateCreate
(
	@CurrencyId			int,				-- ИД Валюты
	@UtDate				date,				-- Дата установки курса
	@Rate				decimal(10, 4),		-- Курс
	-- Out-параметры
	@ErrorMes	nvarchar(4000) out		-- Сообщение об ошибках
) as
begin
	set nocount on
	set @ErrorMes = ''
		
	begin try
	
		-- Если курс валюты на эту дату установлен - выходим
		if exists (select 1 from UtCurrencyExchangeRateHistory where UtDate = @UtDate and CurrencyId = @CurrencyId)
		begin
			set @ErrorMes = 'Курс валют на текущую дату установлен!'
			return 1
		end

		-- Создаем запись
		insert UtCurrencyExchangeRateHistory
			(CurrencyId, UtDate, Rate)
		values 
			(@CurrencyId, @UtDate, @Rate)

		return 0
	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

end
