create proc DeliveryServiceOrdersDeleteFromGroup 
(
	@GroupId		int,					-- Внутренний идентификатор группы
	@AuthorId		uniqueidentifier,		-- Идентификатор автора
	-- Выходные параметры
	@ErrorMes		nvarchar(255) out		-- Сообщение об ошибках
)
as
begin

	set @ErrorMes = ''
	set nocount on

	-- Если список заказов пуст
	if not exists (select 1 from #tkOrderIds) 
		return 0
	
	declare @trancount int
	select @trancount = @@TRANCOUNT

	-- Идентификатор ТК
	declare @serviceId int = null
	
	begin try
				
		-- Получаем Идентификатор ТК
		select @serviceId = g.ServiceId from ApiDeliveryServiceGroups g where g.Id = @GroupId

		if @trancount = 0
			begin transaction

		-- Архивируем существующий заказ как удаленный из группы
		insert ApiDeliveryServiceOrdersArchive (InnerId, OuterId, ServiceId, StatusId, CreatedDate, ChangedDate, AuthorId)
		select o.InnerId, o.OuterId, o.ServiceId, 7, o.CreatedDate, getdate(), @AuthorId
		from ApiDeliveryServiceOrders o
			join #tkOrderIds e on e.OrderId = o.InnerId
		
		-- Удаляем заказы из группы
		delete l from ApiDeliveryServiceGroupOrderLinks l join #tkOrderIds e on e.OrderId = l.OrderId and l.GroupId = @GroupId

		if @trancount = 0
			commit transaction
		
	end try
	begin catch
		if @trancount = 0
			rollback transaction
		set @ErrorMes = 'Ошибка во время удаления заказа в ХП DeliveryServiceOrderDeleteFromGroup!'		
		return 1
	end catch

	-- Проверка на пустые группы
	begin try

		-- Если ТК не Почты России
		if @serviceId is null or (@serviceId is not null and @serviceId <> 4)
			return 0

		-- Если в партии есть заказы
		if exists (select 1 
						from ApiDeliveryServiceGroupOrderLinks l 
							join ApiDeliveryServiceOrders o on l.OrderId = o.InnerId and l.GroupId = @GroupId
					)
			return 0

		-- Если в партии не осталось заказов
		-- Архивируем группу
		update ApiDeliveryServiceGroups set StatusId = 3, ChangedDate = getdate() where Id = @GroupId

		return 0

	end try
	begin catch
		set @ErrorMes = 'Ошибка во время проверки на пустую группу в ХП DeliveryServiceOrderDeleteFromGroup!'		
		return 1
	end catch
	
end
