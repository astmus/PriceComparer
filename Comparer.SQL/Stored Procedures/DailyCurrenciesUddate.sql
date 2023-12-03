create proc DailyCurrenciesUddate (@CharCode nvarchar(5), @CBRDate datetime, @ReadDate datetime, @RateValue decimal(10,5)) as
begin

	declare @trancount int
	select @trancount = @@TRANCOUNT

	begin try 

		if @trancount = 0
			begin transaction

		delete DailyCurrencies from DailyCurrencies where CharCode=@CharCode
		
		insert DailyCurrencies (CharCode, CBRDate, ReadDate, RateValue) values (@CharCode, @CBRDate, @ReadDate, @RateValue)

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
