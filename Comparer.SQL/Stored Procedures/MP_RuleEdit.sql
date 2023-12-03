create proc MP_RuleEdit (
	@RuleId				int,					-- Идентификатор правила
	@Caption			varchar(255),			-- Описание	
	@IsActive			bit,					-- Активный
	@Args				varchar(max),			-- Аогументы
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
				
		-- Создаем правило
		update SiteProductsRules
		set
			Caption		= @Caption,
			Args		= @Args, 
			IsActive	= @IsActive
		where
			Id = @RuleId 

		-- Товары
		delete SiteProductsRulesProductLinks where RuleId = @RuleId
		insert SiteProductsRulesProductLinks (RuleId, ProductId, Inversion)
		select @RuleId, p.Id, p.Inversion
		from #ruleProducts p

		-- Бренды
		delete SiteProductsRulesBrandLinks where RuleId = @RuleId
		insert SiteProductsRulesBrandLinks (RuleId, BrandId, Inversion)
		select @RuleId, b.Id, b.Inversion
		from #ruleBrands b

		-- Поставщики
		delete SiteProductsRulesDistributorLinks where RuleId = @RuleId
		insert SiteProductsRulesDistributorLinks (RuleId, DistributorId, Inversion)
		select @RuleId, d.Id, d.Inversion
		from #ruleDistributors d

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
