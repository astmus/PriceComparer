create proc DailyCurrenciesLoad as
begin

	declare @trancount int
	select @trancount = @@TRANCOUNT

	begin try 

		if @trancount = 0
			begin transaction

		delete DailyCurrencies 
		from #DailyCurrenciesLoad A
		join DailyCurrencies B on B.CharCode=A.CharCode
		
		insert DailyCurrencies (CharCode, CBRDate, ReadDate, RateValue) 
		select CharCode, CBRDate, ReadDate, RateValue
		from #DailyCurrenciesLoad

		if @trancount = 0
			commit transaction
		return 0
	end try 
	begin catch 
		if @trancount = 0
			rollback transaction
		return 1
	end catch 
	
end
