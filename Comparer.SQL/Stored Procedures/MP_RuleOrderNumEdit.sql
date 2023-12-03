create proc MP_RuleOrderNumEdit (
	@RuleId				int,					-- Идентификатор правила
	@SiteId				uniqueidentifier,		-- Идентификатор сайта
	@ChangeType			int,					-- Тип изменения приоритета
	@AuthorId			uniqueidentifier,		-- Идентификатор автора
	-- Выходные параметры
	@ErrorMes			nvarchar(4000) out		-- Сообщение об ошибках
) as
begin

	set nocount on

	select @ErrorMes = ''

	declare
		@CurrentNum		int,
		@NewNum			int,
		@MaxNum			int

	-- Предварительный анализ
	begin try 

		select @CurrentNum = OrderNum from SiteProductsRules where Id = @RuleId 

		select @MaxNum = max(OrderNum) from SiteProductsRules where SiteId = @SiteId
		if @MaxNum is null
			select @MaxNum = 0
			
		select @NewNum = case @ChangeType 
			when 1 then 1
			when 2 then @CurrentNum - 1
			when 3 then @CurrentNum + 1
			when 4 then @MaxNum
			else 0
		end

		if @NewNum < 1
			return 0

		if @NewNum > @MaxNum
			return 0

		if @NewNum = @CurrentNum
			return 0
			
	end try 
	begin catch 
		select @ErrorMes = error_message()
		return 1
	end catch

	-- Непосредственно перемещение
	declare @trancount int
	select @trancount = @@trancount
	
	begin try 
	
		if @trancount = 0
			begin transaction
				
		select @CurrentNum, @NewNum, @MaxNum

		-- Обновляем приоритеты других правил
		if @NewNum < @CurrentNum begin
			
			update SiteProductsRules 
			set OrderNum = OrderNum + 1 
			where SiteId = @SiteId 
				and OrderNum >= @NewNum 
				and OrderNum < @CurrentNum

		end else begin
			
			update SiteProductsRules 
			set OrderNum = OrderNum - 1 
			where SiteId = @SiteId 
				and OrderNum > @CurrentNum
				and OrderNum <= @NewNum

		end

		-- Обновляем приоритет правила
		update SiteProductsRules set OrderNum = @NewNum where Id = @RuleId 

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
