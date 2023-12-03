create proc CheckOrdersForWMSExport_v3 as
begin
	
	set nocount on

	-- Подготавливаем данные для вставки в таблицу ExportOrders
	begin try 
	
		-- Объявляем таблицу для полностью зарезервированных заказов
		create table #completeOrders
		(
			OrderId			uniqueidentifier		not null,		-- Идентификатор заказа			
			primary key (OrderId)
		)
				
		-- Заполняем таблицу полностью зарезервированными заказами,
		-- которых еще нет в WMS
		insert #completeOrders (OrderId)
		exec GetCompleteOrdersForWMSExport
							
		-- Объявляем таблицу для частично зарезервированных заказов (Escentric-и)
		/*declare @partialOrders table  (
			OrderId			uniqueidentifier		not null,		-- Идентификатор заказа			
			primary key (OrderId)
		)*/

		-- Заполняем таблицу частично зарезервированными заказами
		/*insert @partialOrders (OrderId)
		select o.ID
		from CLIENTORDERS o
			left join #completeOrders compl on o.ID = compl.OrderId
		where o.STATUS in (2, 4) 
			and o.PACKED = 0 
			and o.CLIENTID in 
			(
				'498EF36F-4211-4B72-8A40-BAE4175AEEA5','79CD61D2-988A-471E-B73F-71EBC63BB0AB','BA11349E-5EA0-465D-904A-61D6E381E6DC', -- Escentric 
				'5B0F388B-5131-4E50-99AB-EF643F0A8D90',	-- Новикова	Новикова Александровна
				'459723EB-F12A-44C6-85B0-BF0B7765AD21'	-- Тимошкова Тимошкова Александровна
			)
			and o.ID in (
				select o.ID
				from CLIENTORDERS o
					join CLIENTORDERSCONTENT c on c.CLIENTORDERID = o.ID and c.RETURNED = 0 
						and isnull(c.STOCK_QUANTITY,0) >= c.QUANTITY and c.QUANTITY > 0
				where o.STATUS in (2, 4) and o.PACKED = 0 and o.DELIVERYKIND > 0
					-- and o.ExpectedDate < cast(cast(DATEADD(day, 1, getdate()) as date) as datetime) -- Отгрузка день в день
			)
			and compl.OrderId is null
		*/

		-- Создаем временную таблицу для передачи идентификаторов заказов клиентов, которые будут экспортированы в WMS
		if (not object_id('tempdb..#orderIdsForExport') is null) drop table #orderIdsForExport
		create table #orderIdsForExport
		(	
			OrderId			uniqueidentifier	not null,				-- Идентификатор заказа клиента
			Operation		int					not null,				-- Операция
			IsPartial		bit					not null default(0),	-- Частичный
			OrderState		int					not null default(0)		-- Состояние заказа: 
																		-- 0 - Стандартное
																		-- 1 - Требуется отправка заказа после отгрузки в УТ
			Primary key (OrderId)
		)

		-- Объявляем переменную для указания, есть ли строки для вставки в таблицу ExportOrders
		declare @hasRows bit = 0

		-- Объявляем таблицу для заказов, которые необходимо будет обновить/добавить в таблицу ExportOrders
		create table #ordersForUpdate
		(
			OrderId			uniqueidentifier		not null		-- Идентификатор заказа
			primary key (OrderId)
		)
		
		-- Если имеются полностью закупленные и зарезервированные заказы
		if exists (select 1 from #completeOrders) begin
	
			-- Проверяем, есть ли выбранные заказы в списке Заказов на отгрузку (таблица WmsShipmentOrderDocuments),
			-- и если есть, то какие из них следует обновить/добавить
			insert #ordersForUpdate (OrderId)
			select distinct case when d.OrderId is null then c.OrderId else d.OrderId end
			from 
			(
				select d.PublicId as 'OrderId', i.ProductId as 'ProductId', i.Quantity as 'Quantity'
				from WmsShipmentOrderDocuments d 
					join WmsShipmentOrderDocumentsItems i on d.Id = i.DocId 
				where
					d.WarehouseId = 1	-- Розничный склад
					and 
					(
						d.DocStatus < 8  -- Ниже статуса "Готов к отгрузке"
						or 
						d.DocStatus = 9 or d.DocStatus = 11 -- Или "Заблокирован" или "Отменен"
					)
					and i.ProductId <> '1A36C1D1-E5BF-4D87-9035-1121E24810B1' -- Не является "Товар для блокировки Заказа на отгрузку в WMS" 
			) d
			full join 
			(
				select 
					c.CLIENTORDERID			as 'OrderId', 
					c.PRODUCTID				as 'ProductId', 
					sum(c.QUANTITY)			as 'Quantity'
				from 
					#completeOrders o
					join CLIENTORDERS ord on ord.ID = o.OrderId
					join CLIENTORDERSCONTENT c on o.OrderId = c.CLIENTORDERID
					join Products p on p.ID = c.ProductId
				group by 
					c.CLIENTORDERID, c.PRODUCTID, ord.DeliveryKind
			) c on c.OrderId = d.OrderId and c.ProductId = d.ProductId
			where 
				exists(select 1 from #completeOrders o where o.OrderId = d.OrderId or o.OrderId = c.OrderId) 
				and 
				(
					d.OrderId is null or 
					c.OrderId is null or 
					c.OrderId is not null and d.OrderId is not null and d.Quantity <> c.Quantity
				)
				-- Исключение на время акции для Aroma Box
				--and (c.IsAroma = 0 or (c.IsAroma = 1 and (c.DeliveryId not in (5,12,14,16,17,21,22,24,26) or c.CreatedDate < '20211126 00:00:00')))

			-- Если есть заказы, которые нужно обновить/добавить
			if exists (select 1 from #ordersForUpdate) begin
				-- Вставляем их во временную таблицу
				insert #orderIdsForExport (OrderId, IsPartial, Operation)
				select OrderId, 0, 2 from #ordersForUpdate

				set @hasRows = 1
			end
			
		end
		
		-- Если имеются частично закупленные и зарезервированные заказы для Escentric-ов
		/*if exists (select 1 from @partialOrders) begin

			-- Очищаем таблицу для заказов, которые необходимо будет обновить/добавить в таблицу ExportOrders
			delete #ordersForUpdate

			-- Проверяем, есть ли выбранные заказы в списке Заказов на отгрузку (таблица WmsShipmentOrderDocuments),
			-- и если есть, то какие из них следует обновить/добавить
			insert #ordersForUpdate (OrderId)
			select distinct case when d.OrderId is null then c.OrderId else d.OrderId end
			from (
				select d.PublicId as 'OrderId', i.ProductId as 'ProductId', i.Quantity as 'Quantity'
				from WmsShipmentOrderDocuments d 
					join WmsShipmentOrderDocumentsItems i on d.Id = i.DocId 
						and (d.DocStatus < 8						-- Ниже статуса "Готов к отгрузке"
							or d.DocStatus = 9 or d.DocStatus = 11	-- Или "Заблокирован" или "Отменен"
						)
						and i.ProductId <> '1A36C1D1-E5BF-4D87-9035-1121E24810B1' -- Не является "Товар для блокировки Заказа на отгрузку в WMS" 
			) d
			full join (
				select c.CLIENTORDERID as 'OrderId', c.PRODUCTID as 'ProductId', sum(c.QUANTITY) as 'Quantity'
				from @partialOrders o
					join CLIENTORDERSCONTENT c on o.OrderId = c.CLIENTORDERID and isnull(c.STOCK_QUANTITY,0) >= c.QUANTITY and c.QUANTITY > 0
				group by c.CLIENTORDERID, c.PRODUCTID
			) c on c.OrderId = d.OrderId and c.ProductId = d.ProductId
			where exists(select 1 from @partialOrders o where o.OrderId = d.OrderId or o.OrderId = c.OrderId) 
				and 
				(
					d.OrderId is null or 
					c.OrderId is null or 
					c.OrderId is not null and d.OrderId is not null and d.Quantity <> c.Quantity
				)

			-- Если есть заказы, которые нужно обновить/добавить
			if exists (select 1 from #ordersForUpdate) begin
				-- Вставляем их во временную таблицу
				insert #orderIdsForExport (OrderId, Operation, IsPartial)
				select u.OrderId, 2, case when p.OrderId is null then 0 else 1 end 
				from #ordersForUpdate u
					left join (
						select distinct o.OrderId
						from @partialOrders o
							join CLIENTORDERSCONTENT c on c.CLIENTORDERID = o.OrderId and c.RETURNED = 0 and c.QUANTITY > isnull(c.STOCK_QUANTITY,0) and c.QUANTITY > 0
					) p on u.OrderId = p.OrderId				
				
				set @hasRows = 1
			end

		end
		*/

		-- Объявляем таблицу для заказов, которые выгружены в WMS, но которые нужно удалить
		create table #deletedOrders
		(
			OrderId			uniqueidentifier		not null,				-- Идентификатор заказа			
			IsPartial		bit						not null default(0),	-- Частичный
			primary key (OrderId)
		)
				
		-- Заполняем таблицу заказами, которые Отменены, Возвращены или перешли в статус Ожидания
		insert #deletedOrders (OrderId, IsPartial)
		select 
			o.ID, d.IsPartial
		from 
			CLIENTORDERS o
			join WmsShipmentOrderDocuments d on d.PublicId = o.ID and d.DocStatus = 11
		where 
			d.WarehouseId = 1
			and
			(
				o.STATUS = 3 
				or 
				(o.STATUS = 6 and o.DELIVERYKIND = 20)
			)
		union
		select 
			o.ID, d.IsPartial
		from 
			CLIENTORDERS o
			join WmsShipmentOrderDocuments d on d.PublicId = o.ID 
		where 
			d.WarehouseId = 1
			and o.STATUS in (7, 8) 
			and d.DocStatus = 9 
			and not exists (select 1 from CLIENTORDERSCONTENT c where c.CLIENTORDERID = o.ID and c.RETURNED = 0 and isnull(c.STOCK_QUANTITY,0) > 0)

		-- Если есть заказы, которые необходимо удалить
		if exists (select 1 from #deletedOrders) begin

			-- Вставляем их во временную таблицу
			insert #orderIdsForExport (OrderId, Operation, IsPartial)
			select d.OrderId, 3, d.IsPartial 
			from #deletedOrders d
									
			set @hasRows = 1

		end

		-- Если есть строки для вставки
		declare @result int = 0
		if @hasRows = 1 begin
			-- Вызываем хранимую, которая сохраняет указанные во временной таблице заказы клиентов в таблицу ExportOrders
			-- для дальнейшей выгрузки в WMS/УТ
			exec @result = PutOrdersForWMS_v3
			if @result = 1 begin
				return 1
			end

		end

		return 0
		
	end try 
	begin catch 		
		return 1
	end catch

end
