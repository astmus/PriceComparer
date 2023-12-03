create proc MP_RuleCreate (
	@SiteId				uniqueidentifier,		-- Идентификатор сайта
	@Caption			varchar(255),			-- Описание
	@RuleTypeId			int,					-- Идентификатор типа правила
	@IsActive			bit,					-- Активный
	@Args				varchar(max),			-- Аогументы
	@AuthorId			uniqueidentifier,		-- Идентификатор автора
	-- Выходные параметры
	@NewId				int out,				-- Идентификатор созданного правила
	@ErrorMes			nvarchar(4000) out		-- Сообщение об ошибках
) as
begin

	set nocount on

	select @NewId = -1
	select @ErrorMes = ''

	declare @trancount int
	select @trancount = @@trancount

	declare @orderNum int = 0

	begin try 
	
		if @trancount = 0
			begin transaction
		
		-- Получаем текущий максимальный номер по порядку
		select @orderNum = max(sr.OrderNum) from SiteProductsRules sr with(updlock) where sr.SiteId = @SiteId
		if @orderNum is null
			select @orderNum = 1
		else
			select @orderNum = @orderNum + 1
		
		-- Создаем правило
		insert SiteProductsRules(SiteId, RuleTypeId, Caption, Args, IsActive, OrderNum)
		values (@SiteId, @RuleTypeId, @Caption, @Args, @IsActive, @orderNum)

		-- Идентификатор созданного правила
		select @NewId = @@identity

		-- Товары
		insert SiteProductsRulesProductLinks (RuleId, ProductId, Inversion)
		select @NewId, p.Id, p.Inversion
		from #ruleProducts p

		-- Бренды
		insert SiteProductsRulesBrandLinks (RuleId, BrandId, Inversion)
		select @NewId, b.Id, b.Inversion
		from #ruleBrands b

		-- Поставщики
		insert SiteProductsRulesDistributorLinks (RuleId, DistributorId, Inversion)
		select @NewId, d.Id, d.Inversion
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
