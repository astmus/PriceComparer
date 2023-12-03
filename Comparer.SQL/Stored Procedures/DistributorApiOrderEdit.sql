create proc DistributorApiOrderEdit (
	@Operation			int,					-- Операция: 1 - создать, 2 - изменить, 3 - закрыть, 4 - удалить	
	@Id					int,					-- Иденттфткатор заказа	на доставку
	@OrderId			uniqueidentifier,		-- Иденттфткатор заказа	клиента
	@DistributorId		uniqueidentifier,		-- Иденттфткатор поставщика	
	@ApiOrderId			nvarchar(50),			-- Идентификатор заявки поставщику на API-сервисе	
	@Status				int,					-- Статус заявки: 0 - не определен, 1 - создана, 2 - в работе, 3 - закрыта, 4 - отменена
	@ApiStatus			nvarchar(255),			-- Статус заявки на API-сервисе	
	@NewId				int out					-- Идентификатор созданного заказа поставщику в базе данных ShopBase
) as
begin

	set nocount on

	declare @trancount int
	select @trancount = @@TRANCOUNT
	
	select @NewId = 0
	
	begin try 
		if @trancount = 0
			begin transaction

		-- Создает новый заказ поставщику
		if @Operation = 1 begin
		
			insert DistributorsApiOrders(DistributorId, OrderId, ApiOrderId, Status, ApiStatus, CreatedDate)
			values(@DistributorId, @OrderId, @ApiOrderId, @Status, @ApiStatus, getdate())
			
			select @NewId = SCOPE_IDENTITY()
		
			if exists(select 1 from #ProductList)
				insert DistributorsApiOrdersContent (OrderId, ProductId, PriceListId, OutSku, Quantity, Price, Done, ReportDate, Comment)
				select @NewId, A.ProductId, C.PRICEID, C.OUTSKU, D.QUANTITY, C.PRICE, 0, getdate(), ''
				from #ProductList A
				join LINKS B on B.CATALOGPRODUCTID = A.ProductId
				join PRICESRECORDS C on C.RECORDINDEX = B.PRICERECORDINDEX and C.DELETED = 0 and C.USED = 1
				join CLIENTORDERSCONTENT D on D.CLIENTORDERID = @OrderId and D.PRODUCTID = A.ProductId
			
		end else
		-- Изменяет существующий заказ поставщику
		if @Operation = 2 begin
		
			-- Архивируем заказ
			insert DistributorsApiOrdersArchive(OrderId, PurchaseCode, DistributorId, CreatedDate, Status, CloseDate, IsArchive, ArchiveDate)
			select OrderId, PurchaseCode, DistributorId, CreatedDate, Status, CloseDate, 1, getdate()
			from DistributorsApiOrders where Id = @Id
			
			-- Обновляем поля
			update DistributorsApiOrders set Status = @Status, ApiStatus = @ApiStatus where Id = @Id
			
		end else
		-- Удаляет существующий заказ поставщику
		if @Operation = 3 begin
		
			-- Архивируем заказ
			insert DistributorsApiOrdersArchive(OrderId, PurchaseCode, DistributorId, CreatedDate, Status, CloseDate, IsArchive, ArchiveDate)
			select OrderId, PurchaseCode, DistributorId, CreatedDate, Status, CloseDate, 1, getdate()
			from DistributorsApiOrders where Id = @Id
			-- Архивируем заказ как удаленный
			insert DistributorsApiOrdersArchive(OrderId, PurchaseCode, DistributorId, CreatedDate, Status, CloseDate, IsArchive, ArchiveDate)
			select OrderId, PurchaseCode, DistributorId, CreatedDate, 4, CloseDate, 0, getdate()
			from DistributorsApiOrders where Id = @Id
			-- Архивируем товарные позиции
			insert DistributorsApiOrdersContentArchive(OrderId, ProductId, PriceListId, OutSku, Quantity, Price, Done, ReportDate, IsArchive, ArchivDate, Comment)
			select OrderId, ProductId, PriceListId, OutSku, Quantity, Price, Done, ReportDate, 0, getdate(), Comment
			from DistributorsApiOrdersContent where OrderId = @Id
		
			-- Удаляем товарные позиции
			delete DistributorsApiOrdersContent where OrderId = @Id
			-- Удаляем заказ
			delete DistributorsApiOrders where Id = @Id
		
		end else
		-- Закрываем существующий заказ поставщику
		if @Operation = 4 begin
		
			-- Архивируем заказ
			insert DistributorsApiOrdersArchive(OrderId, PurchaseCode, DistributorId, CreatedDate, Status, CloseDate, IsArchive, ArchiveDate)
			select OrderId, PurchaseCode, DistributorId, CreatedDate, Status, CloseDate, 1, getdate()
			from DistributorsApiOrders where Id = @Id
			-- Архивируем заказ как закрытый
			insert DistributorsApiOrdersArchive(OrderId, PurchaseCode, DistributorId, CreatedDate, Status, CloseDate, IsArchive, ArchiveDate)
			select OrderId, PurchaseCode, DistributorId, CreatedDate, 3, getdate(), 0, getdate()
			from DistributorsApiOrders where Id = @Id
			-- Архивируем товарные позиции
			insert DistributorsApiOrdersContentArchive(OrderId, ProductId, PriceListId, OutSku, Quantity, Price, Done, ReportDate, IsArchive, ArchivDate, Comment)
			select OrderId, ProductId, PriceListId, OutSku, Quantity, Price, Done, ReportDate, 0, getdate(), Comment
			from DistributorsApiOrdersContent where OrderId = @Id
		
			-- Удаляем товарные позиции
			delete DistributorsApiOrdersContent where OrderId = @Id
			-- Удаляем заказ
			delete DistributorsApiOrders where Id = @Id
		
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
