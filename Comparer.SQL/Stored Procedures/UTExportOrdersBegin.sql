create proc UTExportOrdersBegin (@SessionId bigint out) as
begin

	set nocount on
	set @SessionId = 0

	-- return 0

	declare @trancount int
	select @trancount = @@trancount
	
	-- Таблица для сохранения изменившихся и созданных объектов
	create table #objTable 
	(
		Id				bigint					not null,
		OrderId			uniqueidentifier		not null,
		Operation		int						not null,
		OrderState		int						not null default(0)		-- Состояние заказа: 
																		-- 0 - Стандартное
																		-- 1 - Требуется отправка заказа после отгрузки в УТ
		primary key(Id)
	)

	begin try

		if @trancount = 0
			begin transaction
		
		-- "Захватываем" таблицу UTExportOrders и запоминаем список товарных позиций
		insert #objTable (Id, OrderId, Operation, OrderState)
		select 
			top 10
			Id, OrderId, Operation, OrderState
		from 
			UTExportOrders
		order by
			Id

		-- Если изменившиеся или созданные объекты есть
		if exists (select 1 from #objTable) begin
									
			-- Создаем новую сессию		
			insert UTExportOrdersSessions(CreatedDate) values(getdate())

			-- Запоминаем идентификатор сессии
			set @SessionId = @@identity

			-- Сохраняем записи
			insert UTExportOrdersSessionItems (SessionId, Id)
			select @SessionId, Id from #objTable

			-- Выгружаем Заказы на отгрузку клиентам
			select	
				d.PublicId					as 'Id', 
				case 
					when d.ShipmentDirection = 5 then isnull(e.OuterId, d.ClientId)
					else d.ClientId
				end							as 'ClientId', 
				d.Number					as 'PublicNumber', 
				d.CreateDate				as 'CreateDate', 
				d.ShipmentDate				as 'ShipmentDate',
				d.Comments					as 'Comment', 
				isnull(d.DeliveryAddress, '') 
											as 'DeliveryAddress',
				case 
					when d.ClientId in 
					(
						'498EF36F-4211-4B72-8A40-BAE4175AEEA5','79CD61D2-988A-471E-B73F-71EBC63BB0AB','BA11349E-5EA0-465D-904A-61D6E381E6DC', -- Escentric 
						'5B0F388B-5131-4E50-99AB-EF643F0A8D90',	-- Новикова	Новикова Александровна
						'459723EB-F12A-44C6-85B0-BF0B7765AD21'	-- Тимошкова Тимошкова Александровна
					) 
						then 'Отгрузка в оптовую точку' 
					else
						case d.ShipmentDirection
							when 1 then 'Курьерская доставка'
							when 2 then 'Доставка транспортной компанией'						
							when 3 then 'Самовывоз'
							when 5 then 'Возврат поставщику'
							when 6 then 'Ozon'
							else '?'
						end 
				end							as 'ShipmentDirection', 
				case when d.OrderSource is null then '00000000-0000-0000-0000-000000000000' else d.OrderSource end as 'OrderSource',
				d.RouteId					as 'RouteId',
				d.IsDeleted					as 'IsDeleted',
				d.IsShipped					as 'IsPrinted',
				case d.ImportanceLevel 
					when 1 then 'Высокая'
					when 2 then 'Обычная'
					when 3 then 'Низкая'
					else 'Обычная'
				end							as 'Priority',
				case 
					when d.ShipmentDirection = 5 then cast(1 as bit)
					else case when isnull(c.IsEmployee,0) = 0 then cast(0 as bit) else cast(1 as bit) end
				end									as 'IsEmployee',
				d.ReportDate						as 'ChangedDate',
				isnull(od.DeliveryKindId, 0)		as 'DeliveryKindId',
				isnull(od.DeliveryServiceId, 0)		as 'DeliveryServiceId',
				convert(int, isnull(o.PAYMENTKIND, 0))	as 'PaymentKindId',
				o.FROZENSUM - o.DELIVERY - o.FEE	as 'ProductsSum',
				o.DELIVERY							as 'DeliveryCost',
				o.FEE								as 'Fee',
				o.FROZENSUM							as 'Sum'
			from #objTable chg 
				join WmsShipmentOrderDocuments d with (nolock) on d.PublicId = chg.OrderId 
				join ClientOrders o with (nolock) on o.ID = chg.OrderId
				left join ClientOrdersDelivery od with (nolock) on od.OrderId = chg.OrderId
				left join CLIENTS c with (nolock) on c.ID = d.ClientId and c.IsEmployee = 1
				left join ExportDistributorsExchangeIds e with (nolock) on d.ClientId = e.InnerId
			--where
				--chg.OrderId = 'A2737AEB-17FC-447E-8C32-001D62126323'	-- ДЛЯ ТЕСТИРОВАНИЯ
			order by 
				d.CreateDate
				
			-- Выгружаем позиции заказов
			select 
				i.ProductId					as 'ProductId', 
				max(i.Quantity)				as 'Quantity', 
				max(i.Price)				as 'Price',
				d.PublicId					as 'OrderId'
			from #objTable chg 
				join WmsShipmentOrderDocuments d  with (nolock) on d.PublicId = chg.OrderId
				join WmsShipmentOrderDocumentsItems i  with (nolock) on i.DocId = d.Id
			--where
				--chg.OrderId = 'A2737AEB-17FC-447E-8C32-001D62126323'	-- ДЛЯ ТЕСТИРОВАНИЯ
			group by 
				i.ProductId, d.PublicId
						
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
