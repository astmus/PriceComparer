create proc DeliveryServiceOrderDeleteFromGroup 
(
	@InnerId		uniqueidentifier,		-- Внутренний идентификатор заказа
	@AuthorId		uniqueidentifier,		-- Идентификатор автора
	-- Выходные параметры
	@ErrorMes		nvarchar(255) out		-- Сообщение об ошибках
) as
begin

	set @ErrorMes = ''
	set nocount on

	declare @trancount int
	select @trancount = @@TRANCOUNT

	if not exists(select 1 from ApiDeliveryServiceGroupOrderLinks where OrderId = @InnerId)
	begin
		set @ErrorMes = 'Ошибка во время удаления заказа из группы! Заказ не принадлежит ни одной из групп.'
		return 1
	end

	-- Получаем Идентификатор группы и ТК
	declare @serviceId int = null
	declare @groupId int = null

	begin try
				
		select	@serviceId = g.ServiceId,
				@groupId = g.Id
		from ApiDeliveryServiceGroupOrderLinks l 
			join ApiDeliveryServiceGroups g on g.Id = l.GroupId and l.OrderId = @InnerId

		if @trancount = 0
			begin transaction

		-- Архивируем существующий заказ как удаленный из группы
		insert ApiDeliveryServiceOrdersArchive (InnerId, OuterId, ServiceId, StatusId, CreatedDate, ChangedDate, AuthorId)
		select o.InnerId, o.OuterId, o.ServiceId, 7, o.CreatedDate, getdate(), @AuthorId
		from ApiDeliveryServiceOrders o
		where o.InnerId = @InnerId

		-- Удаляем существующий заказ из группы
		delete ApiDeliveryServiceGroupOrderLinks where OrderId = @InnerId

		if @trancount = 0
			commit transaction
		--return 0
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
							join ApiDeliveryServiceOrders o on l.OrderId = o.InnerId and l.GroupId = @groupId
					)
			return 0

		-- Если в партии не осталось заказов
		-- Архивируем группу
		update ApiDeliveryServiceGroups set StatusId = 3, ChangedDate = getdate() where Id = @groupId

		return 0

	end try
	begin catch
		set @ErrorMes = 'Ошибка во время проверки на пустую группу в ХП DeliveryServiceOrderDeleteFromGroup!'		
		return 1
	end catch

end
