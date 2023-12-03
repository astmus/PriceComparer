create proc ReceiptProductsByPriorityView
as
begin

	declare @now datetime;
    set @now = getdate()
	
	declare @currentDate date
    set @currentDate = cast(getdate() as date)

	declare @tomorrow date
    set @tomorrow = dateadd(day, 1, @currentDate)

	declare @dayAfterTomorrow date
	set @dayAfterTomorrow = dateadd(day, 1, @tomorrow)

    declare @LastYear date
	select @LastYear = dateadd(year, -1, getdate())

	-- Задания на закупку, по которым ожидаются поступления
	create table #tasks
	(
		Code						int						not null,
		DistributorId				uniqueidentifier		not null,
		AcceptedItemsCount			int						not null,						-- Кол-во всех принятых товарных позиций исходя из задания на закупку (склад)
		Score						float					not null default (0.0)			-- Вес
		primary key (Code)
	)

	insert #tasks (Code, DistributorId, AcceptedItemsCount)
	select
		t.CODE, t.DISTRIBUTORID, isnull(r.ItemsCount, 0)
	from
		PurchasesTasks t 
		left join
		(
			select 
				i.TaskId, count(i.Quantity) as 'ItemsCount'
			from
				WmsReceiptDocuments d
				join WmsReceiptDocumentsItems i on d.Id = i.DocId				
			group by	
				i.TaskId
		) r on r.TaskId = t.PublicGuid
	where
		t.TaskStatus = 2	-- Подтверждено

	-- Содержимое заданий на закупку
	create table #taskItems
	(
		Code						int						not null,
		Sku							int						not null,
		Quantity					int						not null,
		ReceiptQuantity				int						not null default (0),
		Score						float					not null default (0.0),				-- Вес
		PriorityReasonName			varchar(3000)			null 	 default('')

		primary key (Code, Sku)
	)

	insert #taskItems (Code, Sku, Quantity)
	select 
		t.Code, c.SKU, isnull(c.FACTQUANTITY, 0)
	from
		#tasks t
		join PurchasesTasksContent c on c.CODE = t.Code and c.ARCHIVE = 0
	where
		c.STATUS = 0
		or 
		(c.STATUS > 0 and isnull(c.FACTQUANTITY, 0) > 0)

	-- Содержимое заказов, под которые ожидаются поступления
	create table #orderItems
	(
		OrderId						uniqueidentifier		not null,
		ProductId					uniqueidentifier		not null,
		Code						int						not null,

		Number						int						not null,
		Sku							int						not null,
		
		DeliveryKindId				int						not null,
		DeliveryServiceId			int						not null,
		ExpectedDate				date					not null,

		ReceiptQuantity				int						not null default (0),				-- Кол-во принятого товара

		Score						float					not null default (0.0),				-- Вес
		PriorityReasonName			varchar(3000)			null 	 default('')
		
		primary key (OrderId, ProductId, Code)
	) 
		
	insert #orderItems (OrderId, ProductId, Code, Number, Sku, DeliveryKindId, DeliveryServiceId, ExpectedDate, ReceiptQuantity)
	select
		o.ID, p.ID, t.Code, o.NUMBER, p.SKU, o.DELIVERYKIND, d.DeliveryServiceId, cast(o.ExpectedDate as date), h.FactQuantity
	from
		#tasks t
		join PurchaseTasksContentDistributionHistory h on t.Code = h.Code
		join CLIENTORDERS o on h.Number = o.NUMBER
		join CLIENTORDERSCONTENT c on c.CLIENTORDERID = o.ID 
		join PRODUCTS p on p.ID = c.PRODUCTID and h.Sku = p.SKU
		join ClientOrdersDelivery d on d.OrderId = o.ID	
	where
		o.STATUS = 2

	-- Определяем дату планируемой отгрузки для заказов ТК (региональные)
	update i
	set
		i.ExpectedDate = cast(dateadd(day, 4, h.StatusDate) as date)
	from
		#orderItems i
		join
		(
			select 
				h.CLIENTORDER as 'OrderId', max(h.STATUSDATE) as 'StatusDate'
			from					
				ORDERSSTATUSHISTORY h
			where
				h.CLIENTORDER in (select i.OrderId from #orderItems i where dbo.fn_CourierDeliveryKinds(i.DeliveryKindId) <> 1)
				and h.STATUS = 2
			group by
				h.CLIENTORDER
		) h on h.OrderId = i.OrderId

	-- Определяем кол-во принятого товара
	update i
	set 
		i.ReceiptQuantity = r.ReceiptQuantity
	from
		#taskItems i
		join
		(
			select 
				i.Code, i.Sku, sum(i.ReceiptQuantity) as 'ReceiptQuantity'
			from 
				#orderItems i
			group by
				i.Code, i.Sku
		) r on r.Code = i.Code and r.Sku = i.Sku

	-- Рассчитываем вес товарной позиции заказа
	update i
	set	
		i.Score = 
			case 
				-- Если Самовывоз или Курьеры МСК с сервисом Randewoo
				when (i.DeliveryKindId = 20 or (dbo.MSCCourierDeliveryKinds(i.DeliveryKindId) = 1))
					then 
						-- Службы доставки
						case
							-- Randewoo
							when i.DeliveryServiceId = 1
								then 
									case
										when i.ExpectedDate <= @currentDate and datepart(hour, @now) < 12
											then 1.00
										when i.ExpectedDate <= @currentDate and datepart(hour, @now) >= 12
											then 0.50
										when i.ExpectedDate = @tomorrow and datepart(hour, @now) >= 16
											then 0.25
										else
											0.01
									end
							-- Прочее
							else
								0.01
						end					

				-- Курьеры СПб
				when dbo.SPBCourierDeliveryKinds(i.DeliveryKindId) = 1
					then 
						-- Службы доставки
						case
							-- Logsis (17:00) или Интеграл (17:00)
							when i.DeliveryServiceId = 13 or i.DeliveryServiceId = 14
								then 
									case										
										when i.ExpectedDate <= @tomorrow and datepart(hour, @now) < 17
											then 0.90
										when i.ExpectedDate <= @tomorrow and datepart(hour, @now) >= 17
											then 0.40
										else
											0.01
									end
							-- Прочее
							else
								0.01
						end					

				-- ТК (регионы)
				else
					case										
						when i.ExpectedDate <= @currentDate
							then 0.80
						else
							0.01
					end
			end,
		i.PriorityReasonName = case 
				-- Если Самовывоз или Курьеры МСК с сервисом Randewoo
				when (i.DeliveryKindId = 20 or (dbo.MSCCourierDeliveryKinds(i.DeliveryKindId) = 1))
					then 
						-- Службы доставки
						case
							-- Randewoo
							when i.DeliveryServiceId = 1
								then 
									case
										when i.ExpectedDate <= @currentDate and datepart(hour, @now) < 12
											then 'Самовывоз или Randewoo Курьеры МСК отгрузка сегодня до 12:00'
										when i.ExpectedDate <= @currentDate and datepart(hour, @now) >= 12
											then 'Самовывоз или Randewoo Курьеры МСК отгрузка сегодня после 12:00'
										when i.ExpectedDate = @tomorrow and datepart(hour, @now) >= 16
											then 'Самовывоз или Randewoo Курьеры МСК отгрузка завтра после 16:00'
										else
											'Самовывоз или Randewoo Курьеры МСК'
									end
							-- Прочее
							else
								'Прочее'
						end					

				-- Курьеры СПб
				when dbo.SPBCourierDeliveryKinds(i.DeliveryKindId) = 1
					then 
						-- Службы доставки
						case
							-- Logsis (17:00) или Интеграл (17:00)
							when i.DeliveryServiceId = 13 or i.DeliveryServiceId = 14
								then 
									case										
										when i.ExpectedDate <= @tomorrow and datepart(hour, @now) < 17
											then 'Logsis или Интеграл отгрузка сегодня или завтра до 17:00'
										when i.ExpectedDate <= @tomorrow and datepart(hour, @now) >= 17
											then 'Logsis или Интеграл отгрузка сегодня или завтра после 17:00'
										else
											'Logsis или Интеграл'
									end
							-- Прочее
							else
								'Прочее'
						end					

				-- ТК
				else
					case										
						when i.ExpectedDate <= @currentDate
							then 'ТК отгрузка сегодня'
						else
							'ТК'
					end
			end
	from
		#orderItems i

	-- Рассчитываем вес товарной позиции задания на закупку
	update i
	set
		i.Score = s.Score,
		i.PriorityReasonName = s.PriorityReasonName
	from
		#taskItems i
		join
		(
			select 
				i.Code, i.Sku, i.PriorityReasonName, max(i.Score) as 'Score'
			from
				#orderItems i
			group by
				i.Code, i.Sku, i.PriorityReasonName
		) s on s.Code = i.Code and s.Sku = i.Sku

	-- Рассчитываем вес задания на закупку
	update t
	set
		t.Score = s.Score
	from
		#tasks t
		join
		(
			select 
				i.Code, max(i.Score) as 'Score'
			from
				#taskItems i
			group by
				i.Code
		) s on s.Code = t.Code

	-- Удяляем товарные позиции заданий на закупку, для которых нет заказов (закупка впрок, заказ отменен и т.д.)
	delete #taskItems where Score = 0.0

	-- Выводим результаты
	select 
		t.Code					as 'PurchaseTaskNumber', -- Код задания на закупку
		d.NAME					as 'DistributorName',  -- Имя поставщика
		m.NAME + ' ' + p.FullName				
								as 'ProductName', -- Название товара
		i.Quantity - i.ReceiptQuantity as 'ProductsToBeReceiptQuantity', -- Количество товаров которые необходимо принять
		i.PriorityReasonName	as 'PriorityReasonName',

		t.Score					as 'PurchaseScore', -- Количество баллов которое набрало задание на закупку (для приоритета)
		i.Score					as 'ProductScore', -- Количество баллов которое набрал товар (для приоритета)

		p.ID					as 'ProductId',
		p.SKU					as 'ProductSku', -- Артикул товара

		i.ReceiptQuantity		as 'ReceiptQuantity', -- Количество, фактически принятое (после приемки)
		i.Quantity				as 'Quantity', -- Общее количество товара участвующие в приемке, принятые сюда тоже входят

		t.AcceptedItemsCount	as 'PurchaseAcceptedItemsCount' -- Общее количество принятых товаров по конкретному заданию на закупку
	from
		#tasks t
		join #taskItems i on i.Code = t.Code
		join DISTRIBUTORS d on d.ID = t.DistributorId
		join PRODUCTS p on p.SKU = i.Sku
		join MANUFACTURERS m on m.ID = p.MANID
	where
		i.Quantity > i.ReceiptQuantity
		and t.Score > 0.01
		and i.Score > 0.01
	order by
		i.Score desc, d.NAME, m.NAME, p.FullName

	-- Детали по товарной позиции задания на закупку в разрезе веса
	select 
		i.Code, i.Sku, i.Score, count(i.Number) as 'OrderNumber'
	from
		#orderItems i
	where
		i.Score > 0.01
	group by
		i.Code, i.Sku, i.Score

end
