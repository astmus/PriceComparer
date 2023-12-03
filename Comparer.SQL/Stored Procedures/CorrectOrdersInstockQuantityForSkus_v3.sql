create proc CorrectOrdersInstockQuantityForSkus_v3 
(
	@DocKind		int,	-- Источник поступления: 
								-- 1 - Приемка от поставщиков, 
								-- 2 - Приемка возвратов от клиентов
								-- 3 - Перемещение из оптовой точки,
								-- 4 - Приемка парфюмерных пробников в зоне розлива
								-- 5 - Попытка зарезервировать остатки, которые остались после выполнения одной 
								--		из предыдущих операций или вследствии отмены заказа, перехода в статус ожидания (внутренняя операция)
								-- 6 - Попытка зарезервировать остатки под конкретный заказ (внутренняя операция)
								-- 7 Корректировка согласно Акта сверки
							-- Направление отгрузки:
								-- 11 - Курьерская доставка,
								-- 12 - Доставка транспортной компанией,
								-- 13 - Самовывоз,
								-- 14 - Отгрузка на розлив											
								-- 15 - Корректировка согласно Акта сверки
	@ErrorMes		nvarchar(4000) out	-- Сообщение об ошибках
) as
begin
	
	-- Вер. 2. Не выполняем перестроение плана на закупку
	--		   Теперь за это отвечают ХП AutoCorrectPurchasePlan.

	set @ErrorMes = ''
	set nocount on

	declare @resValue int, @err nvarchar(255)
	
	-- Режим "перерезервирования"
	declare @Mode int = 0		
	-- 1 - Для указанных товарных позиций (вр. табл. #skuForCorrectOrdersInstocQuantity) 
	--		и указанных Заданий на закупку (вр. табл. #purchaseTaskCodesForCorrectOrdersInstocQuantity)
	-- 2 - Для указанных товарных позиций (вр. табл. #skuForCorrectOrdersInstocQuantity)
	-- 3 - Для указанных товарных позиций (вр. табл. #skuForCorrectOrdersInstocQuantity) 
	--		за исключением указанных заказов (вр. табл. #orderNumbersForCorrectOrdersInstocQuantity)
	-- 4 - Для указанных товарных позиций (вр. табл. #skuForCorrectOrdersInstocQuantity) 
	--		и указанных заказов (вр. табл. #orderNumbersForCorrectOrdersInstocQuantity)
	-- 9 - "Перерезервирования" не выполняем
	-- 99 - Режим "перерезервирования" не определен!!!

	-- Определяем нужный режим по Виду документа прихода/реализации
	set @Mode = case @DocKind 
		when 1 then 1
		when 2 then 2
		when 3 then 2
		when 4 then 2
		when 5 then 2
		when 6 then 4
		when 7 then 2
		when 11 then 3
		when 12 then 3
		when 13 then 3
		when 14 then 2
		when 15 then 2		
		else 99
	end

	if @Mode = 9 
		return 0;


	if @Mode = 99 begin
		set @ErrorMes = '@Mode is undefined!'
		return 1;
	end

	if @Mode = 1 begin
		if not exists (select 1 from #purchaseTaskCodesForCorrectOrdersInstocQuantity) 
		begin
			set @ErrorMes = 'Receipt document is undefined!'
			print('Receipt document is undefined!')
			return 1
		end
	end
	
	print 'Mode = ' + cast(@Mode as varchar(100))

	-- Таблица идентификаторов заказов, 
	-- для которых необходимо будет перестроить план на закупку
	create table #idsForRebuildPurchasePlan
	(
		Id		uniqueidentifier	not null		
	)

	begin try 

		-- ===============================================================================================================
		-- Создаем все необходимые временные таблицы --------------------------------------------------------------------

		-- Временная таблица для фактических остатков товаров
		if (not object_id('tempdb..#productInstock') is null) drop table #productInstock
		create table #productInstock 
		(
			Id						uniqueidentifier		not null,			-- Идентификатор товара
			Stock					int						not null,			-- Фактический остаток товара на складе (Розничном) в качестве "Кондиция"
			ReserveStock			int						not null,			-- Количество зарезервированных под заказы остатков
			PassiveReserveStock		int						not null,			-- Количество пассивных резервов
			primary key (Id)
		)

		-- Создаем таблицу для заказов, которые находятся в работе, и в которых есть указанные артикулы
		if (not object_id('tempdb..#ordersItemsForCorrectInstockQuantity') is null) drop table #ordersItemsForCorrectInstockQuantity
		create table #ordersItemsForCorrectInstockQuantity 
		(
			OrderId				uniqueidentifier	not null,					-- Идентификатор заказа
			Number				int					not null,					-- Номер заказа
			ProductId			uniqueidentifier	not null,					-- Идентификатор товара
			Sku					int					not null,					-- Артикул товара
			IsGift				bit					not null,					-- Подарок
			Quantity			int					not null,					-- Количество товарных позиций по заказу
			CreatedDate			datetime			not null,					-- Дата создания заказа
			OrderPriority		varchar(50)			not null,					-- Приоритет по заказу в целом
			StatusPriority		tinyint				not null,					-- Приоритет по статусу заказа (2 или 4 = 1, 7 или 8 = 2)
			PurchaseQuantity	int					not null,					-- Количество товарных позиций, закупленных под заказ позиций
			InstockQuantity		int					not null,					-- Количество товарных позиций, обеспеченное складом (общее)
			DopInstockQuantity	int					not null default (0),		-- Количество товарных позиций, обеспеченное складом (в рамках текущего распределения)
			primary key (OrderId, ProductId, IsGift)
		)

		-- Создаем временную таблицу для артикулов, по которым необходимо выполнить корректировку резервов
		if (not object_id('tempdb..#productsForCorrectOrdersInstockQuantity') is null) drop table #productsForCorrectOrdersInstockQuantity
		create table #productsForCorrectOrdersInstockQuantity 
		(
			ProductId		uniqueidentifier	not null,		-- Идентификатор товара
			Quantity		int					not null		-- Количество, на которое требуется скорректировать резервы
			primary key (ProductId)
		)

		-- Создаем все необходимые временные таблицы --------------------------------------------------------------------
		-- ===============================================================================================================

		-- Заполняем таблицу с фактическими остатками товаров
		insert #productInstock (Id, Stock, ReserveStock, PassiveReserveStock)
		select 
			c.Id, isnull(s.ConditionStock, 0), isnull(r.ReserveStock, 0), isnull(r.PassiveReserveStock, 0)
		from 
			#productsForCorrectOrdersReserves c 
			left join WarehousesStock s on s.ProductId = c.Id and s.WarehouseId = 1
			left join WarehouseProductReserves r on r.ProductId = c.Id and s.WarehouseId = 1

		-- DEBUG
		-- select * from #productInstock p where p.Id in ('2E7E87D5-191A-4F71-B44E-2AFC706AA2C1','B7BDF276-AB63-45A5-A907-2F41DD52AE34','2FD9349D-1819-4DB0-B8E9-51E65A1AD07E')
		-- DEBUG

		-- Если для указанных товарных позиций (вр. табл. #skuForCorrectOrdersInstocQuantity) 
		-- и указанных Заданий на закупку (вр. табл. #purchaseTaskCodesForCorrectOrdersInstocQuantity)
		if @Mode = 1 begin

			-- Заполняем таблицу заказов, которые находятся в работе,
			-- и в которых есть указанные артикулы, и которые закупались в указанном Задании на закупку
			insert #ordersItemsForCorrectInstockQuantity 
			(
				OrderId, CreatedDate, OrderPriority, Number, ProductId, Sku, Quantity, IsGift, PurchaseQuantity, InstockQuantity, StatusPriority
			)
			select 
				o.ID, o.[DATE], o.PRIORITY, o.NUMBER, c.PRODUCTID, p.SKU, c.QUANTITY, c.IS_GIFT, isnull(c.PURCHASE_QUANTITY, 0), isnull(c.STOCK_QUANTITY, 0), 1
			from 
				CLIENTORDERS o
				join CLIENTORDERSCONTENT c on o.ID = c.CLIENTORDERID
				join #productsForCorrectOrdersReserves r on r.Id = c.PRODUCTID
				join PRODUCTS p on p.ID = c.PRODUCTID
				left join WmsShipmentDocuments d on d.PublicId = o.ID and d.DocStatus = 10 and d.WarehouseId = 1
			where 
				o.STATUS = 2 and
				o.PACKED = 0 and 
				o.NotUseInReserveProc = 0 and
				d.DocStatus is null 
				and 
				(
					exists 
					(
						select 1 
						from 
							OrdersPlans op 
								join #purchaseTaskCodesForCorrectOrdersInstocQuantity t on op.PURCHASESCODE = t.Code
							where  
								op.NUMBER = o.NUMBER and 
								op.SKU = p.SKU and 
								op.ARCHIVE = 0					
					)
					or
					exists 
					(
						select 1 
						from 
							OrdersPlansArchive op 
							join #purchaseTaskCodesForCorrectOrdersInstocQuantity t on op.PURCHASESCODE = t.Code
						where  
							op.NUMBER = o.NUMBER and 
							op.SKU = p.SKU and 
							op.ARCHIVE = 0
					)
				)

			-- Если приемка не связана ни с одним из заданий на закупку,
			-- выходим без каких-либо действий
			if not exists (select 1 from #ordersItemsForCorrectInstockQuantity)
				return 0
							
		end else

		-- Если для указанных товарных позиций
		if @Mode = 2 begin
						
			-- Заполняем таблицу заказов, которые находятся в работе,
			-- и в которых есть указанные артикулы
			insert #ordersItemsForCorrectInstockQuantity 
			(
				OrderId, CreatedDate, OrderPriority, Number, ProductId, Sku, Quantity, IsGift, 
				PurchaseQuantity, InstockQuantity, StatusPriority
			)
			select 
				i.OrderId, i.CreatedDate, i.OrderPriority, i.Number, i.ProductId, i.Sku, i.Quantity, i.IsGift, 
				i.PurchaseQuantity, i.InstockQuantity, i.StatusPriority
			from
			(
				select 
					o.ID as 'OrderId', o.[DATE] as 'CreatedDate', o.PRIORITY as 'OrderPriority', o.NUMBER as 'Number', 
					c.PRODUCTID as 'ProductId', p.SKU as 'Sku', c.QUANTITY as 'Quantity', c.IS_GIFT as 'IsGift', 
					isnull(c.PURCHASE_QUANTITY, 0) as 'PurchaseQuantity', isnull(c.STOCK_QUANTITY, 0) as 'InstockQuantity', 1 as 'StatusPriority',
					row_number() over (partition by o.ID, c.PRODUCTID, c.IS_GIFT order by c.ID) as 'RowNo'
				from 
					CLIENTORDERS o
					join CLIENTORDERSCONTENT c on o.ID = c.CLIENTORDERID 
					join PRODUCTS p on p.ID = c.PRODUCTID
					join #productsForCorrectOrdersReserves r on r.Id = c.PRODUCTID
				where 				
					o.PACKED = 0 and 
					o.NotUseInReserveProc = 0 and
					(
						o.STATUS = 2 -- Подтвержденные заказы
						or
						(o.STATUS in (7, 8) and isnull(c.STOCK_QUANTITY,0) > 0)	-- Заказы в статусах "Ожидает ответа" и "Ожидает предоплаты"
					) and
					c.NotUseInReserveProc = 0
			) i
			where
				i.RowNo = 1


		end else

		-- Если для указанных товарных позиций, за исключением указанных заказов
		if @Mode = 3 begin
					
			set @ErrorMes = 'Not implemented for @Mode = 3!'
			return 1

		end else

		-- Если для указанных товарных позиций любых заказов
		if @Mode = 4 begin
						
			set @ErrorMes = 'Not implemented for @Mode = 4!'
			return 1

		end
			
		declare
			@hasCorrected	bit	= 0

		-- DEBUG
		-- select * from #ordersItemsForCorrectInstockQuantity i where i.ProductId in ('2E7E87D5-191A-4F71-B44E-2AFC706AA2C1','B7BDF276-AB63-45A5-A907-2F41DD52AE34','2FD9349D-1819-4DB0-B8E9-51E65A1AD07E')
		-- DEBUG

		-- ===============================================================================================================
		-- 1. Проверяем, обеспечено ли складом ранее "зарезервированное" количество товарных позиций под заказы

		-- Если резервирование происходит не по Приемке
		if @Mode <> 1 begin

			-- Получаем товарные позиции заказов, которые не обеспечиваются складом
			insert #productsForCorrectOrdersInstockQuantity (ProductId, Quantity)
			select 
				p.Id, 
				(i.OrdersReserveStock + p.PassiveReserveStock) - p.Stock as 'DecQuantity'
			from 
				#productInstock p 
				join
				(
					select 
						i.ProductId, sum(i.InstockQuantity) as 'OrdersReserveStock'
					from
						#ordersItemsForCorrectInstockQuantity i
					where
						i.InstockQuantity > 0
					group by
						i.ProductId
				) i on p.Id = i.ProductId
			where
				(i.OrdersReserveStock + p.PassiveReserveStock) > p.Stock
			
			-- Если есть позиций в заказах, которые не обеспечиваются складом
			-- (требуется забрать резрв у некоторых позиций)
			if exists (select 1 from #productsForCorrectOrdersInstockQuantity) begin
				
				print '#productsForCorrectOrdersInstockQuantity esists (Decrement)'

				-- Корректируем ранее "зарезервированное" количество
				-- (приведет к корректировке Плана на закупку и Заданий на закупку)
				exec DecrementOrdersInstockQuantity_v3
				
				set @hasCorrected = 1				

			end

		end
			
		-- 1. ------------------------------------------------------------------------------------------------------------
		-- ===============================================================================================================

		-- Очищаем таблицу для корректировки резервов
		truncate table #productsForCorrectOrdersInstockQuantity

		-- ===============================================================================================================
		-- 2. Проверяем, есть ли свободные остатки для дополнительного "резервирования" -----------------------------------
			
		-- Если распределение по Приемке, то необходимо выбрать все заказы из базы данных для указанных товаров
		if @Mode = 1 begin

			-- Получаем товарные позиции заказов, под которые нужно выполнить "резервирование" из Приемки
			insert #productsForCorrectOrdersInstockQuantity(ProductId, Quantity)
			select 
				p.Id, p.Stock - (p.ReserveStock + p.PassiveReserveStock) as 'IncQuantity'
			from 
				#productInstock p 
				/*
				join
				(
					select 
						i.ProductId, sum(i.Quantity) as 'OrdersReserveStock'
					from
					(
						select 
							c.PRODUCTID as 'ProductId', isnull(c.STOCK_QUANTITY, 0) as 'Quantity'
						from 
							CLIENTORDERS o
							join CLIENTORDERSCONTENT c on o.ID = c.CLIENTORDERID
							join #productsForCorrectOrdersReserves i on i.Id = c.PRODUCTID 
						where 
							o.STATUS = 2
							and o.PACKED = 0
							and o.NotUseInReserveProc = 0
						union all
						select 
							c.PRODUCTID as 'ProductId', isnull(c.STOCK_QUANTITY, 0) as 'Quantity'
						from 
							CLIENTORDERS o
							join CLIENTORDERSCONTENT c on o.ID = c.CLIENTORDERID
							join #productsForCorrectOrdersReserves i on i.Id = c.PRODUCTID 
						where 
							o.STATUS in (7, 8)
							and o.PACKED = 0
							and o.NotUseInReserveProc = 0
							and isnull(c.STOCK_QUANTITY, 0) > 0
					) i
					group by 
						i.ProductId
				) i on i.ProductId = p.Id	
				*/			
			where 
				p.Stock > (p.ReserveStock + p.PassiveReserveStock)

		end else 
		-- Если для указанных товарных позиций, то используем выборку, которую уже получили ранее (#ordersItemsForCorrectInstockQuantity)
		if @Mode = 2 begin

			insert #productsForCorrectOrdersInstockQuantity(ProductId, Quantity)
			select 
				p.Id, p.Stock - (i.OrdersReserveStock + p.PassiveReserveStock) as 'IncQuantity'
			from 
				#productInstock p 
				join
				(
					select 
						i.ProductId, sum(i.InstockQuantity) as 'OrdersReserveStock'
					from
						#ordersItemsForCorrectInstockQuantity i
					group by
						i.ProductId
				) i on p.Id = i.ProductId
			where
				p.Stock > (i.OrdersReserveStock + p.PassiveReserveStock)

		end
		
		-- Если есть позиций в заказах, под которые можно выполнить дополнительное "резервирование"
		if exists (select 1 from #productsForCorrectOrdersInstockQuantity) begin

			print '#productsForCorrectOrdersInstockQuantity esists (Increment)'

			-- Корректируем "зарезервированное" количество			
			exec IncrementOrdersInstockQuantity_v3 @Mode

			set @hasCorrected = 1

		end

		-- 2. ------------------------------------------------------------------------------------------------------------
		-- ===============================================================================================================

		-- Если изменений не было - выходим
		if @hasCorrected = 0
			return 0

		-- 3. ---------------------------------------------------------------------------------------------------------------

		-- Запоминаем только те заказы, в которых что-то изменилось
		insert #idsForRebuildPurchasePlan (Id)
		select distinct i.OrderId
		from 
			#ordersItemsForCorrectInstockQuantity i
		where 
			i.DopInstockQuantity <> 0

	end try 
	begin catch 
		set @ErrorMes = error_message()
		return 1
	end catch 

	declare @trancount int
	select @trancount = @@trancount
	
	declare 
		@InstockQuantityDate datetime = getdate()	

	-- Выполняем действия
	begin try 

		print 'begin transaction...'

		if @trancount = 0
			begin transaction

		-- 4. Обновляем "Зарезервированные" остатки в ClientOrdersContent ---------------------------------------------------

		-- Обновляем товарные позиции в заказах
		update c 
		set 
			c.STOCK_QUANTITY		= i.InstockQuantity, 
			c.STOCK_QUANTITY_DATE	= @InstockQuantityDate
		from 
			#ordersItemsForCorrectInstockQuantity i
			join CLIENTORDERSCONTENT c on c.CLIENTORDERID = i.OrderId and c.PRODUCTID = i.ProductId and c.IS_GIFT = i.IsGift
		where 
			isnull(c.STOCK_QUANTITY, 0) <> i.InstockQuantity
			and
			(
				@Mode = 1 
				or
				(
					@Mode = 2 
					and
					c.NotUseInReserveProc = 0
				)
			)

		print 'CLIENTORDERSCONTENT update rows count = ' + cast(@@rowcount as varchar(255))
			
		-- 5. Обновляем "зарезервированные" остатки в таблице Products ------------------------------------------------------
		exec RefreshInstockForSkus_v3
			
		-- 6. Обновляем таблицу PurchaseTasksContentDistributionHistory
		if @Mode = 1 begin
			
			-- Активные записи распределения
			update h
			set
				h.FactQuantity = iif((h.FactQuantity + i.DopInstockQuantity) > h.Quantity, h.Quantity, h.FactQuantity + i.DopInstockQuantity)
			from
				#purchaseTaskCodesForCorrectOrdersInstocQuantity t
				join PurchaseTasksContentDistributionHistory h on h.Code = t.Code
				join #ordersItemsForCorrectInstockQuantity i on i.Number = h.Number and i.Sku = h.Sku and i.IsGift = h.IsGift
			where
				i.InstockQuantity > 0

			print ('PurchaseTasksContentDistributionHistory update rows count = ' + cast(@@rowcount as varchar(50)))

			-- Архивные записи распределения
			update h
			set
				h.FactQuantity = iif((h.FactQuantity + i.DopInstockQuantity) > h.Quantity, h.Quantity, h.FactQuantity + i.DopInstockQuantity)
			from
				#purchaseTaskCodesForCorrectOrdersInstocQuantity t
				join PurchaseTasksContentDistributionHistoryArchive h on h.Code = t.Code
				join #ordersItemsForCorrectInstockQuantity i on i.Number = h.Number and i.Sku = h.Sku and i.IsGift = h.IsGift
			where
				i.InstockQuantity > 0

			print ('PurchaseTasksContentDistributionHistoryArchive update rows count = ' + cast(@@rowcount as varchar(50)))

		end

		-- Сохраняем заказы в таблицу для перестроения плана на закупку
		insert OrderIdsForRebuildPurchasePlan (OrderId) 
		select Id
		from #idsForRebuildPurchasePlan

		if @trancount = 0
			commit transaction

		return 0

	end try 
	begin catch 
		if @trancount = 0
			rollback transaction
		set @ErrorMes = error_message()
		return 1
	end catch 

end
