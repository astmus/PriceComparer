create proc ShipOrderInWMS (
	@OrderId			uniqueidentifier	-- Идентификатор заказа клиента
) as
begin

	set nocount on

	begin try

		-- Временная таблица для передачи идентификаторов заказов клиентов, которые будут отгружены со склада
		if (not object_id('tempdb..#orderIdsForShipment') is null) drop table #orderIdsForShipment
		create table #orderIdsForShipment
		(	
			OrderId			uniqueidentifier	not null,				-- Идентификатор заказа клиента	
			Primary key (OrderId)
		)
		-- Заполянем таблицу
		insert #orderIdsForShipment (OrderId) values (@OrderId)

		-- Вызывваем хранимую для отгрузки заказов
		declare @resValue int
		exec @resValue = ShipOrdersInWMS
		if @resValue = 1
			return 1
			
		return 0

	end try 
	begin catch 		
		return 1
	end catch
	
end
