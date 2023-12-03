create proc MP_RuleDelete (
	@RuleId				int,					-- Идентификатор правила	
	@AuthorId			uniqueidentifier,		-- Идентификатор автора
	-- Выходные параметры
	@ErrorMes			nvarchar(4000) out		-- Сообщение об ошибках
) as
begin

	set nocount on

	select @ErrorMes = ''

	declare @trancount int
	select @trancount = @@trancount
	
	begin try 
	
		if @trancount = 0
			begin transaction
				
		-- Правило
		delete SiteProductsRules where Id = @RuleId 

		-- Товары
		delete SiteProductsRulesProductLinks where RuleId = @RuleId
		
		-- Бренды
		delete SiteProductsRulesBrandLinks where RuleId = @RuleId
		
		-- Поставщики
		delete SiteProductsRulesDistributorLinks where RuleId = @RuleId
		
		-- Цены
		update SyncPrevCalcPrices set RuleId = null where RuleId = @RuleId

		if @trancount = 0
			commit transaction

		return 0
	end try 
	begin catch 
		if @trancount = 0
			rollback transaction
		select @ErrorMes = error_message()
		return 1
	end catch

end
