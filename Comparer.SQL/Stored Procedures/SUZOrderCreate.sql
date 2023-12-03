create proc SUZOrderCreate 
(
	@PublicId		nvarchar(64),			-- Идентификатор заказа в СУЗ
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

	select @ActiveCount = count(1) from SUZOrders where IsActive = 1 and StatusId = 1
	if @ActiveCount >= 100 begin
		set @ErrorMes = 'Превышен допустимый лимит по активным заказам!'
		return 1
	end

	declare @trancount int
	select @trancount = @@trancount

	begin try

		if @trancount = 0
			begin transaction

		-- Заказ
		insert SUZOrders (PublicId) values (@PublicId)
		set @NewId = @@identity

		-- Позиции
		insert SUZOrderItems (OrderId, GTIN, Quantity, ProductId)
		select @NewId, i.GTIN, i.Quantity, i.ProductId
		from #SUZOrderItems i

		-- Маркировки
		/*
		insert SUZOrderItemDataMatrixes (ItemId, DataMatrix)
		select i.Id, dm.DataMatrix
		from SUZOrderItems i
			join #SUZOrderItems dm on dm.GTIN = i.GTIN
		where 
			i.OrderId = @NewId
			and dm.DataMatrix is not null
		*/

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
