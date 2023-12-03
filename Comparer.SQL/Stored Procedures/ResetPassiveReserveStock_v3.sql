create proc ResetPassiveReserveStock_v3 
(
	@ErrorMes		nvarchar(4000) out	-- Сообщение об ошибках
)
as
begin

	set @ErrorMes = ''
	set nocount on

	begin try 

		-- Тоары и их кол-во под заказы, готовые к отгрузке, и заказы УТ
		create table #passiveReserves
		(
			
			ProductId		uniqueidentifier		not null,
			Stock			int						not null
			primary key (ProductId)
		)

		-- Товары, пассивные резервы по которым требуется сбросить
		create table #passiveReservesForReset
		(
			
			ProductId		uniqueidentifier		not null
			primary key (ProductId)
		)

		insert #passiveReserves (ProductId, Stock)
		select 
			i.ProductId, sum(i.Quantity)
		from 
		(
			-- Заполняем таблицу на основе документов из УТ
			select i.ProductId, i.Quantity
			from 
				WmsShipmentDocuments d 
				join WmsShipmentDocumentsItems i on i.DocId = d.Id				
			where 
				d.OuterOrder = 1 and 
				d.DocStatus < 10

			union all

			-- Добавляем записи из заказов в статусе "Готов к отгрузке" и "Готов к выдаче"
			select 
				c.PRODUCTID as 'ProductId', isnull(c.QUANTITY, 0)
			from 
				CLIENTORDERS o
				join CLIENTORDERSCONTENT c on c.CLIENTORDERID = o.ID
				left join WmsShipmentDocuments d on d.PublicId = o.ID and d.DocStatus = 10
				left join _excludedOrdersForReserves e on e.OrderId = o.ID
			where 
				-- Нет документа отгрузки (или не долетел своевременно)
				d.PublicId is null
				-- Исключенные заказы
				and e.OrderId is null
				and
				(
					-- Статус заказа "Готов к отгрузке" или "Готов к выдаче"
					(
						o.STATUS in (14, 15)
					)
					-- Статус заказа "Отправлен" (ТК) или "Отгружен" или "Получен клиентом" (Самовывоз) или "Утерян"
					-- и есть признак "Упакован"
					or
					(
						o.STATUS in (5, 9, 16, 17)
						and
						o.PACKED = 1
						and 
						o.DATE > '01/01/2023'
						and
						o.SITEID <> '14F7D905-31CB-469A-91AC-0E04BC8F7AF3'	-- Не розлив
					)
				)
		) i
		group by 
			i.ProductId
		
		-- Загружаем товары, пассивные резервы по которым необходимо сбросить
		insert #passiveReservesForReset (ProductId)
		select
			r.ProductId
		from 
			WarehouseProductReserves r
			left join #passiveReserves p on p.ProductId = r.ProductId
		where
			r.WarehouseId = 1	-- Розничный склад
			and p.ProductId is null
			and r.PassiveReserveStock is not null

		-- Сбрасываем пассивные резервы, которые не попали в расчет
		update r
		set 
			r.PassiveReserveStock = null
		from 
			WarehouseProductReserves r
			join #passiveReservesForReset p on p.ProductId = r.ProductId
		where
			r.WarehouseId = 1	-- Розничный склад

		-- Обновляем пасcивные резервы для существующих записей
		update r
		set 
			r.PassiveReserveStock = p.Stock
		from 
			#passiveReserves p
			join WarehouseProductReserves r on p.ProductId = r.ProductId and r.WarehouseId = 1	-- Розничный склад

		-- Вставляем новые паcсивные резервы для не существующих записей
		insert WarehouseProductReserves (WarehouseId, ProductId, PassiveReserveStock)
		select 1, p.ProductId, p.Stock
		from
			#passiveReserves p
			left join WarehouseProductReserves r on p.ProductId = r.ProductId and r.WarehouseId = 1	-- Розничный склад
		where
			r.ProductId is null
				
		-- Пассивные резервы для обновления сводных данных (агрегатов)
		create table #summary
		(
			WarehouseId			int						not null,			-- Идентификатор склада
			ProductId			uniqueidentifier		not null,			-- Идентификатор товара
			Reserves			int						not null			-- Остатки
			primary key (WarehouseId, ProductId)
		)

		insert #summary (WarehouseId, ProductId, Reserves)
		select 
			1, p.ProductId, p.Stock
		from			
			#passiveReserves p
		union
		select
			1, r.ProductId, 0
		from
			#passiveReservesForReset r
		
		-- Выполняем корректировку сводных пассивных резервов по витринам
		update s
		set 
			s.PassiveReserveStock = l.Reserves
		from 
			(
				select
					l.SiteId, s.ProductId, sum(s.Reserves) as 'Reserves'
				from
					#summary s
					join WarehouseShowcaseLinks l on l.WarehouseId = s.WarehouseId
				where
					l.IsActive = 1
				group by 
					l.SiteId, s.ProductId
			) l
			join ShowcaseProductsStock s on s.SiteId = l.SiteId and s.ProductId = l.ProductId

		-- Вставляем записи для пассивные резервов, которых еще нет
		insert ShowcaseProductsStock (SiteId, ProductId, PassiveReserveStock)
		select 
			l.SiteId, l.ProductId, l.Reserves
		from
			(
				select
					l.SiteId, s.ProductId, sum(s.Reserves) as 'Reserves'
				from
					#summary s
					join WarehouseShowcaseLinks l on l.WarehouseId = s.WarehouseId
				where
					l.IsActive = 1
				group by 
					l.SiteId, s.ProductId
			) l
			left join ShowcaseProductsStock s on s.SiteId = l.SiteId and s.ProductId = l.ProductId
		where
			s.ProductId is null

		return 0

	end try 
	begin catch 	
		set @ErrorMes = error_message()
		return 1
	end catch

end
