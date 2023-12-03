create proc DeliveryServicePutOrderToQueueAgain (	
	@OrderId		uniqueidentifier,		-- Идентификатор заказа
	@AuthorId		uniqueidentifier,		-- Идентификатор автора
	-- Out-параметры
	@ErrorMes		nvarchar(255) out		-- Сообщение об ошибках
) as
begin
	
	set nocount on
	set @ErrorMes = ''
		
	declare @trancount int
	select @trancount = @@TRANCOUNT

	-- Обновление очереди
	begin try

		if @trancount = 0
			begin transaction
		
		-- Сбрасываем номер отправления в заказе
		update CLIENTORDERS set DISPATCHNUMBER = '' where ID = @OrderId
		-- Записываем в действия пользователей
		insert USERACTIONS (USERID, OBJECTTYPE, ACTIONTYPE, PARAMS)
		select @AuthorId, 9, 2, 
			   'OrderID=' + lower(cast(o.ID as varchar(36))) + 
			   ';Номер заказа=' + case when o.PUBLICNUMBER = '' then cast(o.NUMBER as varchar(10)) else o.PUBLICNUMBER end + 
			   ';Номер отправления='
			   ';'
		from CLIENTORDERS o where o.ID = @OrderId
				
		-- Архивируем заказ
		insert ApiDeliveryServiceOrdersArchive (InnerId, OuterId, ServiceId, StatusId, AuthorId, CreatedDate, ChangedDate)
		select InnerId, OuterId, ServiceId, StatusId, AuthorId, CreatedDate, ChangedDate
		from ApiDeliveryServiceOrders
		where InnerId = @OrderId

		-- Удаляем заказ 
		delete ApiDeliveryServiceOrders where InnerId = @OrderId
		
		-- Добавляем заказ в очередь
		declare @result int
		declare @err nvarchar(255)
		exec @result = DeliveryServicePutOrderToQueue @OrderId, @AuthorId, @err out
		if @result = 1 begin
			if @trancount = 0
				rollback transaction
			set @ErrorMes = @err
			return 1
		end
				
		if @trancount = 0
			commit transaction
		return 0
	end try
	begin catch
		if @trancount = 0
			rollback transaction
		set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры DeliveryServicePutOrderToQueueAgain!'		
		return 1
	end catch

end
