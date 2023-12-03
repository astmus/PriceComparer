create proc CurrencyExtraRangesView
(
	@CurrencyId			int = null			-- Идентификатор валюты
) as
begin
	
	select
		cast(c.CURRENCYID as int)		as 'Id',
		c.NAME							as 'Name',
		c.SHORTNAME						as 'Code',
		c.RETAILRANGES					as 'Ranges'
	from CURRENCIES c 
	where c.CurrencyId = iif(@CurrencyId is null, c.CurrencyId, @CurrencyId)

end
