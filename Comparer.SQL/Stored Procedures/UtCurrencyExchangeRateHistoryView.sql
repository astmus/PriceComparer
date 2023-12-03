create procedure UtCurrencyExchangeRateHistoryView
(	
	@DateFrom		date		= null,		-- Дата с
	@DateTo			date		= null,		-- Дата по
	@CurrencyId		int			= null		-- Валюта	
) as
begin	

	if @CurrencyId = 0
	begin
		set @CurrencyId= null
	end 

	select 
		a.Id			as 'Id',
		a.UtDate		as 'UtDate',
		a.CreatedDate	as 'CreatedDate',
		a.Rate			as 'CurrencyExchangeRates',
		b.[NAME]		as 'CurrencyName',
		a.CurrencyId	as 'CurrencyId'
	from 
		UtCurrencyExchangeRateHistory a
		join CURRENCIES b on a.CurrencyId = b.CURRENCYID
	where 
		(@DateFrom is null or (@DateFrom  is not null and a.UtDate >= @DateFrom)) and
		(@DateTo is null or (@DateTo  is not null and a.UtDate <= @DateTo)) and
		(@CurrencyId is null or (@CurrencyId is not null and a.CurrencyId = @CurrencyId))
	order by 
		a.UtDate desc
		
end
