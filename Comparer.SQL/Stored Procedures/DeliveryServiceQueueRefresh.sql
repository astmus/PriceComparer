create proc DeliveryServiceQueueRefresh (	
	@ErrorMes		nvarchar(255) out		-- Сообщение об ошибках
) as
begin
	
	set nocount on
	set @ErrorMes = ''

	-- Таблица для идентификаторов заказов, которые должны быть добавлены в очередь
	declare @added table(
		OrderId			uniqueidentifier	not null,
		primary key(OrderId)
	)
	-- Таблица для идентификаторов заказов, которые должны быть удалены из очереди
	declare @removed table(
		OrderId			uniqueidentifier	not null,
		primary key(OrderId)
	)
	-- Таблица для идентификаторов заказов, которые должны быть удалены из ЛК ТК
	declare @canceled table(
		OrderId			uniqueidentifier	not null,
		primary key(OrderId)
	)

	-- Проверка и подготовка данных
	begin try

		-- Получаем список идентификаторов способов доставки ТК
		create table #tkDeliveryKinds
		(	
			Id		smallint	not null,
			primary key (Id)
		)
		exec _loadTKDeliveryKinds
		
		-- Определяем заказы, которые необходимо добавить в очередь
		insert @added (OrderId)
		select o.ID
		from CLIENTORDERS o
			join #tkDeliveryKinds k on o.DELIVERYKIND = k.Id 
			left join ApiDeliveryServiceOrders do on o.ID = do.OuterId
		where o.PACKED = 0 and o.STATUS in (15) and do.OuterId is null

		-- Определяем заказы, которые необходимо удалить из очереди
		insert @removed (OrderId)
		-- Заказы, которые уже созданы в ЛК ТК, но попрежнему находятся в очереди
		select o.ID
		from ApiDeliveryServiceQueue q
			join CLIENTORDERS o on o.ID = q.OrderId
			left join ApiDeliveryServiceOrders do on o.ID = do.InnerId
		where do.InnerId is not null
		union
		-- Заказы, которые есть в очереди, но они отменены или изменили направление отгрузки
		select o.ID
		from ApiDeliveryServiceOrders do
			join CLIENTORDERS o on o.ID = do.OuterId
		where	o.PACKED = 1 or 
				o.STATUS in (3,5,6,9,12,13) and do.InnerId is null

		-- Определяем заказы, которые необходимо удалить из очереди и из ЛК ТК, если они там созданы
		insert @canceled (OrderId)
		select o.ID
		from ApiDeliveryServiceOrders do
			join CLIENTORDERS o on o.ID = do.OuterId
		where	o.STATUS = 3
		
	end try
	begin catch
		set @ErrorMes = 'Ошибка во время подготовки данных хранимой процедуры DeliveryServiceQueueRefresh!'		
		return 1
	end catch
	
	declare @trancount int
	select @trancount = @@TRANCOUNT

	-- Обновление очереди
	begin try

		if @trancount = 0
			begin transaction
		
		
		
		if @trancount = 0
			commit transaction
		return 0
	end try
	begin catch
		if @trancount = 0
			rollback transaction
		set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры DeliveryServiceQueueRefresh!'		
		return 1
	end catch

end
