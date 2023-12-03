create proc DeliveryServiceOrdersCreate (
	@AuthorId		uniqueidentifier,		-- Идентификатор автора
	-- Выходные параметры
	@ErrorMes		nvarchar(255) out		-- Сообщение об ошибках
) as
begin

	set @ErrorMes = ''
	set nocount on

	declare @trancount int
	select @trancount = @@TRANCOUNT

	begin try

		if @trancount = 0
			begin transaction

		-- Обновляем номера отправления у заказов
		update o
			set  o.DISPATCHNUMBER = e.DispatchNumber
			from #tkOrders e 
				 join CLIENTORDERS o on o.ID = e.InnerId 
			where isnull(e.DispatchNumber, '') <> ''

		-- Архивируем существующие заказы
		insert ApiDeliveryServiceOrdersArchive (InnerId, OuterId, ServiceId, StatusId, CreatedDate, ChangedDate, AuthorId)
			select o.InnerId, o.OuterId, o.ServiceId, o.StatusId, o.CreatedDate, o.ChangedDate, o.AuthorId
			from #tkOrders e join ApiDeliveryServiceOrders o on o.InnerId = e.InnerId

		-- Удаляем существующие заказы ТК
		delete o
		from #tkOrders e join ApiDeliveryServiceOrders o on o.InnerId = e.InnerId
		-- Удаляем доп. информацию существующих заказов ТК
		delete o
		from #tkOrders e join ApiDeliveryServiceOrdersInfo o on o.InnerId = e.InnerId
		-- Удаляем связи существующих заказов ТК с группами
		delete l
		from #tkOrders e join ApiDeliveryServiceGroupOrderLinks l on e.InnerId = l.OrderId
		-- Удаляем заказ из очереди, если он там есть
		delete l
		from #tkOrders e join ApiDeliveryServiceQueue l on e.InnerId = l.OrderId

		-- Вставляем новые заказы ТК
		insert ApiDeliveryServiceOrders (InnerId, OuterId, ServiceId, AuthorId, AccountId, IKNId)
			select o.InnerId, o.OuterId, o.ServiceId, @AuthorId, AccountId, IKNId
			from   #tkOrders o

		-- Вставляем доп. информацию новых заказов ТК
		insert ApiDeliveryServiceOrdersInfo (InnerId)
			select o.InnerId
			from   #tkOrders o
		
		if @trancount = 0
			commit transaction
		return 0

	end try
	begin catch

		if @trancount = 0
			rollback transaction

		set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры DeliveryServiceOrdersCreate!'		
		return 1

	end catch

end
