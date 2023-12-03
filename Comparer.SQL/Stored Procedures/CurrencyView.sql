create proc CurrencyView
(
	@CurrencyId			int			-- Идентификатор валюты
) as
begin
	
	select * from CURRENCIES c where c.CurrencyId = @CurrencyId

end
