create proc ShipOrdersInWMS_v2
(
	@AuthorId			uniqueidentifier,		-- Идентификатор автора
	@ErrorMes			varchar(4000) out		-- Сообщение об ошибке
) as
begin

	set nocount on
	set @ErrorMes = '' 

	declare 
		@AuthorName	varchar(255)

	select @AuthorName = u.NAME from USERS u where u.ID = @AuthorId

	if @AuthorName is null
		select @AuthorName = '?'

	-- Заказы, для которых нужно будет обновить статус
	create table #ordersForStatusUpdate
	(
		OrderId			uniqueidentifier	not null				-- Идентификатор заказа клиента			
		Primary key (OrderId)
	)

	insert #ordersForStatusUpdate (OrderId)
	select
		o.ID
	from 
		#orderIdsForShipment e 
		join CLIENTORDERS o with (nolock) on o.ID = e.OrderId
	where 
		o.DELIVERYKIND <> 20 
		and o.[STATUS] not in (3, 5, 6, 16)

	declare @trancount int
	select @trancount = @@trancount
	
	begin try

		if @trancount = 0
			begin transaction
	
		print 'Tran begin'

		-- 1. Обновляем статус "Упакован" в заказах  ---------------------------------------------------

		print 'Update pack state...'

		update o 
		set 
			o.PACKED		= 1, 
			o.PackedDate	= getdate()
		from 
			#orderIdsForShipment e 
			join CLIENTORDERS o on o.ID = e.OrderId

		print 'OK'
		
		-- Если есть заказы, для которых нужно обновить статусы
		if exists (select 1 from #ordersForStatusUpdate) begin

			print 'Update status...'

			-- 2. Обновляем статус и сохраняем в историю
			update o 
			set 
				o.STATUS		= 17,
				o.CHANGEDATE	= getdate()
			from 
				#ordersForStatusUpdate e 
				join CLIENTORDERS o on o.ID = e.OrderId			

			print 'OK'
			print 'Insert status history...'

			-- Сохраняем в историю
			insert ORDERSSTATUSHISTORY (CLIENTORDER, STATUS, STATUSDATE, EMAIL, AUTHOR)
			select 
				e.OrderId, 17, getdate(), null, @AuthorName
			from 
				#ordersForStatusUpdate e 
				join CLIENTORDERS o on o.ID = e.OrderId

			print 'OK'			

		end

		if @trancount = 0
			commit transaction

	end try 
	begin catch 
		if @trancount = 0
			rollback transaction
		set @ErrorMes = error_message()
		return 1
	end catch

	begin try

		print 'insert user history...'

		-- Длелаем запись в таблице действий пользователя
		insert USERACTIONS 
		(
			USERID, 
			OBJECTTYPE, 
			ObjectId, 
			ACTIONTYPE, 
			PARAMS, 
			ActionInfo
		)
		select 
			@AuthorId, 
			9, 
			lower(cast(o.ID as varchar(36))),
			2,  
			'OrderID=' + lower(cast(o.ID as varchar(36))) + 
				';Номер заказа=' + case when o.PUBLICNUMBER = '' then cast(o.NUMBER as varchar(10)) else o.PUBLICNUMBER end +
				';Упакован=Да' +
			iif(s.OrderId is null, ';', ';Статус=Отгружен;'),
			null
		from 
			#orderIdsForShipment e 
			join CLIENTORDERS o on o.ID = e.OrderId
			left join #ordersForStatusUpdate s on s.OrderId = e.OrderId
				
		-- Изменяем признак "Отгружен" (IsShipped) в документах "Заказ на отгрузку"

		-- Архивируем устаревшие документы в таблице WmsShipmentOrderDocuments
		insert WmsShipmentOrderDocumentsArchive 
		(
			Id, WarehouseId, PublicId, ClientId, Number, DocStatus, WmsCreateDate, ShipmentDate, ShipmentDirection, RouteId, 
			IsPartial, IsShipped, IsDeleted, Comments, Operation, AuthorId, CreateDate, ReportDate
		)	
		select 
			d.Id, d.WarehouseId, d.PublicId, d.ClientId, d.Number, d.DocStatus, d.WmsCreateDate, d.ShipmentDate, d.ShipmentDirection, d.RouteId, 
			d.IsPartial, d.IsShipped, d.IsDeleted, d.Comments, d.Operation, d.AuthorId, d.CreateDate, d.ReportDate
		from 
			#orderIdsForShipment o
			join WmsShipmentOrderDocuments d on d.PublicId = o.OrderId

		-- Обновляем признак "Отгружен"
		update d
		set 
			d.Operation = 2,
			d.IsShipped = 1
		from 
			#orderIdsForShipment e
			join WmsShipmentOrderDocuments d on d.PublicId = e.OrderId
						
		-- 2. -----------------------------------------------------------------------------------------

		-- Вставляем новые записи в таблицу ExportOrders
		insert ExportOrders (OrderId, Operation, IsPartial)
		select s.OrderId, 2, 0
		from #orderIdsForShipment s
			left join ExportOrders e on s.OrderId = e.OrderId
		where
			e.OrderId is null

		print 'OK'

		return 0
	end try 
	begin catch 
		set @ErrorMes = error_message()
		return 1
	end catch
	
end
