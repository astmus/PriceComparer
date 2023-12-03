create proc RefreshInstockForSkus_v3 as
begin

	-- Объявляем таблицу товаров, для которых выполнялось перерезервирование
	create table #productsForReserveChanges
	(
		Id			uniqueidentifier		not null,	-- Идентификатор товара
		Quantity	int						not null	-- Кол-во, зарезервированное под заказы
		primary key (Id)
	)

	-- Объявляем таблицу для товаров, у которых изменилось состояние резервов
	create table #reserveChanges 
	(
		ProductId		uniqueidentifier		not null,	-- Идентификатор товара
		NewState		int						not null,	-- Новое состояние
		Diff			int						not null	-- Величина, на которую изменилось количество
															-- Может быть отрицательным и положительным		
		primary key (ProductId)
	)

	begin try 

		-- Заполняем таблицу товаров и кол-ва, зарезервированного под заказы
		-- (товары, для которых выполнялся пересчет - #productsForCorrectOrdersReserves)
		insert #productsForReserveChanges (Id, Quantity)
		select 
			t.ProductId, sum(t.StockQuantity)
		from
		(
			select 
				c.PRODUCTID as 'ProductId', isnull(c.STOCK_QUANTITY, 0) as 'StockQuantity'
			from 
				CLIENTORDERS o
				join CLIENTORDERSCONTENT c on o.ID = c.CLIENTORDERID 
				join #productsForCorrectOrdersReserves r on r.Id = c.PRODUCTID
			where 
				o.STATUS = 2 and
				o.PACKED = 0 and 
				o.NotUseInReserveProc = 0
			union all
			-- Заказы в статусах "Ожидает ответа" и "Ожидает предоплаты"
			select 
				c.PRODUCTID as 'ProductId', isnull(c.STOCK_QUANTITY, 0) as 'StockQuantity'
			from 
				CLIENTORDERS o 
				join CLIENTORDERSCONTENT c on o.ID = c.CLIENTORDERID
				join #productsForCorrectOrdersReserves r on r.Id = c.PRODUCTID
			where
				o.STATUS in (7, 8) and 
				o.PACKED = 0 and 
				o.NotUseInReserveProc = 0 and
				isnull(c.STOCK_QUANTITY,0) > 0
		) t
		group by
			t.ProductId

		-- Заполняем таблицу изменений
		-- (учитываем только те товары, для которых кол-во зарезервированных изменилось)
		insert #reserveChanges (ProductId, NewState, Diff)
		select p.ID, p.Quantity, p.Quantity - isnull(r.ReserveStock, 0)
		from 
			#productsForReserveChanges p
			left join WarehouseProductReserves r on r.ProductId = p.Id and r.WarehouseId = 1 -- Розничный склад
		where 
			p.Quantity <> isnull(r.ReserveStock, 0)

		-- Если есть изменившиеся резервы
		if exists (select 1 from #reserveChanges) begin
	
			-- Обновляем зарезервированное кол-во для существующих записей
			update r
			set 
				r.ReserveStock = ch.NewState
			from 				
				#reserveChanges ch 
				join WarehouseProductReserves r on r.ProductId = ch.ProductId and r.WarehouseId = 1 -- Розничный склад

			print 'WarehouseProductReserves update rows count = ' + cast(@@rowcount as varchar(255))

			-- Вставляем записи для новых резервов
			insert WarehouseProductReserves (WarehouseId, ProductId, ReserveStock)
			select 
				1, ch.ProductId, ch.NewState
			from
				#reserveChanges ch 
				left join WarehouseProductReserves r on r.ProductId = ch.ProductId and r.WarehouseId = 1 -- Розничный склад
			where
				r.ProductId is null

			print 'WarehouseProductReserves insert rows count = ' + cast(@@rowcount as varchar(255))

			-- Выполняем корректировку сводных пассивных резервов по витринам
			update s
			set 
				s.ReserveStock = l.Reserves
			from 
				(
					select
						l.SiteId, s.ProductId, sum(s.NewState) as 'Reserves'
					from
						#reserveChanges s
						join WarehouseShowcaseLinks l on l.WarehouseId = 1	-- Розничный склад
					where
						l.IsActive = 1
					group by 
						l.SiteId, s.ProductId
				) l
				join ShowcaseProductsStock s on s.SiteId = l.SiteId and s.ProductId = l.ProductId

			print 'ShowcaseProductsStock update rows count = ' + cast(@@rowcount as varchar(255))

			-- Вставляем записи для пассивные резервов, которых еще нет
			insert ShowcaseProductsStock (SiteId, ProductId, ReserveStock)
			select 
				l.SiteId, l.ProductId, l.Reserves
			from
				(
					select
						l.SiteId, s.ProductId, sum(s.NewState) as 'Reserves'
					from
						#reserveChanges s
						join WarehouseShowcaseLinks l on l.WarehouseId = 1	-- Розничный склад
					where
						l.IsActive = 1
					group by 
						l.SiteId, s.ProductId
				) l
				left join ShowcaseProductsStock s on s.SiteId = l.SiteId and s.ProductId = l.ProductId
			where
				s.ProductId is null

			print 'ShowcaseProductsStock insert rows count = ' + cast(@@rowcount as varchar(255))

		end

		return 0
	end try 
	begin catch 
		return 1
	end catch

end
