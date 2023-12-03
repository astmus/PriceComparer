create proc ShipOrdersInWMS as
begin

	set nocount on

	declare @trancount int
	select @trancount = @@TRANCOUNT
	
	-- Проверяем есть ли такие заказы
	if not exists (select 1 from #orderIdsForShipment s join CLIENTORDERS o on o.ID = s.OrderId) begin
		return 1
	end

	begin try

		if @trancount = 0
			begin transaction
	
		-- 1. Обновляем статус "Упакован" в заказах ---------------------------------------------------

		update o 
		set o.PACKED = 1, 
			o.PackedDate = getdate() 
		from #orderIdsForShipment e 
		join CLIENTORDERS o on o.ID = e.OrderId

		-- 1. -----------------------------------------------------------------------------------------

		-- 2. Изменяем признак "Отгружен" (IsShipped) в документах "Заказ на отгрузку" ----------------

		-- Архивируем устаревшие документы в таблице WmsShipmentOrderDocuments
		insert WmsShipmentOrderDocumentsArchive (Id, PublicId, ClientId, Number, DocStatus, WmsCreateDate, ShipmentDate, ShipmentDirection, RouteId, 
												 IsPartial, IsShipped, IsDeleted, Comments, Operation, AuthorId, CreateDate, ReportDate)	
		select d.Id, d.PublicId, d.ClientId, d.Number, d.DocStatus, d.WmsCreateDate, d.ShipmentDate, d.ShipmentDirection, d.RouteId, 
			   d.IsPartial, d.IsShipped, d.IsDeleted, d.Comments, d.Operation, d.AuthorId, d.CreateDate, d.ReportDate
		from #orderIdsForShipment o
			join WmsShipmentOrderDocuments d on d.PublicId = o.OrderId

		-- Обновляем признак "Отгружен"
		declare @now datetime = getdate()
		update d
		set d.Operation = 2,
			d.IsShipped = 1
		from #orderIdsForShipment e
			join WmsShipmentOrderDocuments d on d.PublicId = e.OrderId
						
		-- 2. -----------------------------------------------------------------------------------------
		
		-- 3. Добавляем заказы, которых еще нет в таблице ExportOrders --------------------------------

		-- Объявляем таблицу, в которую сохраним уже существующие в таблице ExportOrders идентификаторы заказов клиентов
		declare @existsIds table (
			OrderId			uniqueidentifier	not null,				-- Идентификатор заказа клиента
			Operation		int					not null,				-- Операция
			Primary key (OrderId)
		)
		
		-- "Захватываем" таблицу ExportOrders и запоминаем список заказов клиентов, которые уже есть в таблице
		insert @existsIds (OrderId, Operation)
		select e.OrderId, e.Operation
		from ExportOrders e
			join #orderIdsForShipment o on o.OrderId = e.OrderId

		-- Если в таблице уже есть чать заказов клиентов
		if exists(select 1 from @existsIds) begin
							
			-- Архивируем существующие заказы клиентов (идентификатор сессии равен нулю: SessionId = 0)
			insert ExportOrdersSessionItemsArchive (SessionId, Id, OrderId, Operation, ReportDate)
			select 0, i.Id, i.OrderId, i.Operation, i.ReportDate
			from ExportOrders i
				join @existsIds e on e.OrderId = i.OrderId
			
			-- Удаляем существующие заказы клиентов
			delete i 			
			from ExportOrders i
				join @existsIds e on e.OrderId = i.OrderId

		end 
		
		-- Вставляем новые записи в таблицу ExportOrders
		insert ExportOrders (OrderId, Operation, IsPartial)
		select OrderId, 2, 0
		from #orderIdsForShipment
		
		-- 3. -----------------------------------------------------------------------------------------

		----Синхронизации собранных озоновских заказов
		--exec AddOzonShipedOrderInQueue
		
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
