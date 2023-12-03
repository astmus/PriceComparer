create proc SUZOrderCreate_v2
(
	@PublicId		nvarchar(64),			-- Идентификатор заказа в СУЗ
	@SourceId		int,					-- Идентификатор источника
											-- 1 - Инвентаризация
											-- 2 - Задания на закупку
											-- 3 - Задания на закупку (бот)
	@AuthorId		uniqueidentifier,		-- Идентификатор автора
	-- Out-параметры
	@NewId			int out,				-- Идентификатор созданного заказа
	@ErrorMes		nvarchar(4000) out		-- Сообщение об ошибках
)
as
begin

	set nocount on;

	set @NewId = -1
	set @ErrorMes = ''

	declare
		@ActiveCount int = 0

	begin try

		-- 1. Проверяем общий лимит
		select @ActiveCount = count(1) from SUZOrders where IsActive = 1 and StatusId <> 4
		if @ActiveCount >= 100 begin
			set @ErrorMes = 'Превышен допустимый лимит по активным заказам!'
			return 1
		end

		-- 2. Проверяем лимиты по источникам
		if @SourceId = 1 begin
			
			-- 2.1 Инвентаризация
			select @ActiveCount = count(1) from SUZOrders where IsActive = 1 and StatusId <> 4 and SourceId = @SourceId
			if @ActiveCount >= 10 begin
				set @ErrorMes = 'Превышен допустимый лимит по активным заказам для инвентаризации!'
				return 1
			end
			
		end else
		if @SourceId = 2 begin
			
			-- 2.2 Задания на закупку
			select @ActiveCount = count(1) from SUZOrders where IsActive = 1 and StatusId <> 4 and SourceId = @SourceId
			if @ActiveCount >= 90 begin
				set @ErrorMes = 'Превышен допустимый лимит по активным заказам для заданий на закупку!'
				return 1
			end

		end else
		if @SourceId = 3 begin
			
			-- 2.3 Задания на закупку (бот)
			select @ActiveCount = count(1) from SUZOrders where IsActive = 1 and StatusId <> 4 and SourceId = @SourceId
			if @ActiveCount >= 80 begin
				set @ErrorMes = 'Превышен допустимый лимит по активным заказам для заданий на закупку (бот)!'
				return 1
			end

		end

	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

	declare @trancount int
	select @trancount = @@trancount

	begin try

		if @trancount = 0
			begin transaction

		-- Заказ
		insert SUZOrders (PublicId, SourceId) values (@PublicId, @SourceId)
		set @NewId = @@identity

		-- Позиции
		insert SUZOrderItems (OrderId, GTIN, Quantity, ProductId)
		select @NewId, i.GTIN, i.Quantity, i.ProductId
		from #SUZOrderItems i

		if @trancount = 0
			commit transaction

		return 0

	end try
	begin catch		
		if @trancount = 0
			rollback transaction
		set @ErrorMes = error_message()
		return 1
	end catch

end
