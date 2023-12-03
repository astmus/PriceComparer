create proc DailyCurrenciesView (@Mode int, @CharCode nvarchar(5)) as
begin

	if @Mode=0
		select CharCode, CBRDate, ReadDate, RateValue from DailyCurrencies
	else
		select CharCode, CBRDate, ReadDate, RateValue from DailyCurrencies where CharCode=@CharCode
	
end
