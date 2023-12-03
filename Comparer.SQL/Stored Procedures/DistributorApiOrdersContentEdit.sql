create proc DistributorApiOrdersContentEdit (
	@Operation			int,					-- Операция: 1 - создать, 2 - изменить, 3 - удалить	
	@OrderId			int,					-- Иденттфткатор заказа
	@ProductId			uniqueidentifier,		-- Иденттфткатор товара
	@Done				bit						-- Выполнено	
) as
begin

	set nocount on

	declare @trancount int
	select @trancount = @@TRANCOUNT
	
	begin try 
		if @trancount = 0
			begin transaction

		-- Создает новую позицию в заказ поставщику
		if @Operation = 1 begin
		
			/*insert DistributorsApiOrders(DistributorId, ApiOrderId, Status, ApiStatus)
			values(@DistributorId, @ApiOrderId, @Status, @ApiStatus)*/
			
			select 1
		
		end else
		-- Изменяет существующий заказ поставщику
		if @Operation = 2 begin
		
			-- Архивируем заказ
			insert DistributorsApiOrdersContentArchive(OrderId, ProductId, PriceListId, OutSku, Quantity, Price, Done, ReportDate, IsArchive, ArchivDate, Comment)
			select OrderId, ProductId, PriceListId, OutSku, Quantity, Price, Done, ReportDate, 1, getdate(), Comment
			from DistributorsApiOrdersContent where OrderId = @OrderId and ProductId = @ProductId
			
			-- Обновляем поля
			update DistributorsApiOrdersContent set Done = @Done where OrderId = @OrderId and ProductId = @ProductId
			
		end else
		-- Удаляет существующую позицию из заказа поставщику
		if @Operation = 3 begin
		
			-- Архивируем заказ
			insert DistributorsApiOrdersContentArchive(OrderId, ProductId, PriceListId, OutSku, Quantity, Price, Done, ReportDate, IsArchive, ArchivDate, Comment)
			select OrderId, ProductId, PriceListId, OutSku, Quantity, Price, Done, ReportDate, 1, getdate(), Comment
			from DistributorsApiOrdersContent where OrderId = @OrderId and ProductId = @ProductId
			
			-- Обновляем поля
			update DistributorsApiOrdersContent set Done = @Done where OrderId = @OrderId and ProductId = @ProductId
		
			-- Удаляем товарные позиции
			delete DistributorsApiOrdersContent where OrderId = @OrderId
			-- Удаляем заказ
			delete DistributorsApiOrders where Id = @OrderId
		
		end
		
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
