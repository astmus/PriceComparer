create procedure ProductsInstockMonitorView 
(
	@Sku			int,					-- Артикул
	@BrendId		uniqueidentifier,		-- Идентификатор бренда
	@Name			nvarchar(500),			-- Наименование товара
	@RecordSince	int,					-- Номер записи, начиная с которой необходимо вывести товары
	@RecordTo		int,					-- Номер записи, заканчивая которой необходимо вывести товары
	@SortBy			int,					-- Сортировать по:
											-- 1 - Бренду
											-- 2 - Наименованию
											-- 3 - Артикулу
											-- 4 - Остаткам
											-- 5 - Резервам
											-- 6 - Кол-ву заказов
	@DescOrder		bit,					-- Обратная сортировка?
	@TotalCount		int	out					-- Общее кол-во, найденных по поиску
) as
begin
	
	set @TotalCount = 0

	-- Объявляем таблицу для товаров, у которых остатки больше 0
	create table #products
	(
		Id				uniqueidentifier	not null,		-- Идентификатор товара
		Sku				int					not null,		-- Артикул
		Name			nvarchar(max)		not null,		-- Наименование
		BrandId			uniqueidentifier	not null,		-- Идентификатор бренда
		BrandName		nvarchar(max)		not null,		-- Наименование бренда
		Instock			int					not null,		-- Остатки на складе
		Reserved		int					not null,		-- Зарезервированных		
		OrdersCount		int					not null,		-- Кол-во заказов, под которые зарезервированы позиции		
		primary key (Id)
	)

	-- Заполянем таблицу товаров
	if @Sku is not null begin	-- Отбор по артикулу

		insert #products(Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount)
		select p.ID, p.SKU, rtrim(p.NAME + ' ' + p.CHILDNAME), m.ID, m.NAME, isnull(ps.Stock, 0), isnull(ps.TotalReserveStock, 0), 0
		from 
			PRODUCTS p with(nolock)
			join MANUFACTURERS m with(nolock) on p.MANID = m.ID and p.SKU = @Sku
			left join ShowcaseProductsStock ps with(nolock) on ps.ProductId = p.ID and ps.SiteId = '48E0A097-E897-4ABD-8B98-2B3FFC6C405B'
		where 
			isnull(ps.Stock, 0) > 0

	end else
	if @BrendId is not null and @Name is not null begin	-- Отбор по бренду и наименованию товара

		insert #products(Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount)
		select p.ID, p.SKU, rtrim(p.NAME + ' ' + p.CHILDNAME), m.ID, m.NAME, isnull(ps.Stock, 0), isnull(ps.TotalReserveStock, 0), 0
		from 
			PRODUCTS p with(nolock)
			join MANUFACTURERS m with(nolock) on p.MANID = m.ID and m.ID = @BrendId 
																and replace(p.NAME + p.CHILDNAME, ' ','') like '%' + @Name + '%'
			left join ShowcaseProductsStock ps with(nolock) on ps.ProductId = p.ID and ps.SiteId = '48E0A097-E897-4ABD-8B98-2B3FFC6C405B'
		where 
			isnull(ps.Stock, 0) > 0

	end else
	if @BrendId is not null begin	-- Отбор по бренду

		insert #products(Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount)
		select p.ID, p.SKU, rtrim(p.NAME + ' ' + p.CHILDNAME), m.ID, m.NAME, isnull(ps.Stock, 0), isnull(ps.TotalReserveStock, 0), 0
		from 
			PRODUCTS p with(nolock)
			join MANUFACTURERS m with(nolock) on p.MANID = m.ID and m.ID = @BrendId 
			left join ShowcaseProductsStock ps with(nolock) on ps.ProductId = p.ID and ps.SiteId = '48E0A097-E897-4ABD-8B98-2B3FFC6C405B'
		where 
			isnull(ps.Stock, 0) > 0

	end else
	if @Name is not null begin	-- Отбор по наименованию товара

		insert #products(Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount)
		select p.ID, p.SKU, rtrim(p.NAME + ' ' + p.CHILDNAME), m.ID, m.NAME, isnull(ps.Stock, 0), isnull(ps.TotalReserveStock, 0), 0
		from 
			PRODUCTS p with(nolock)
			join MANUFACTURERS m with(nolock) on p.MANID = m.ID and replace(p.NAME + p.CHILDNAME, ' ','') like '%' + @Name + '%'
			left join ShowcaseProductsStock ps with(nolock) on ps.ProductId = p.ID and ps.SiteId = '48E0A097-E897-4ABD-8B98-2B3FFC6C405B'
		where 
			isnull(ps.Stock, 0) > 0

	end else begin

		insert #products(Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount)
		select p.ID, p.SKU, rtrim(p.NAME + ' ' + p.CHILDNAME), m.ID, m.NAME, isnull(ps.Stock, 0), isnull(ps.TotalReserveStock, 0), 0
		from 
			PRODUCTS p with(nolock)
			join MANUFACTURERS m with(nolock) on p.MANID = m.ID
			left join ShowcaseProductsStock ps with(nolock) on ps.ProductId = p.ID and ps.SiteId = '48E0A097-E897-4ABD-8B98-2B3FFC6C405B'
		where 
			isnull(ps.Stock, 0) > 0

	end

	-- Если список товаров не пуст
	if exists (select 1 from #products) begin

		set @TotalCount = (select count(1) from #products)
	
		-- Объявляем таблицу для товаров, у которых остатки больше 0
		create table #productsRange	
		(
			Id				uniqueidentifier	not null,		-- Идентификатор товара
			Sku				int					not null,		-- Артикул
			Name			nvarchar(max)		not null,		-- Наименование
			BrandId			uniqueidentifier	not null,		-- Идентификатор бренда
			BrandName		nvarchar(max)		not null,		-- Наименование бренда
			Instock			int					not null,		-- Остатки на складе
			Reserved		int					not null,		-- Зарезервированных
			OrdersCount		int					not null,		-- Кол-во заказов, под которые зарезервированы позиции		
			primary key (Id)
		)

		-- Выводим товары согласно заданной сортировке
		if @DescOrder = 0 begin	-- Прямая сортировка

			if @SortBy = 1 begin	-- 1 - Бренду
				insert #productsRange (Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount)
				select Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount from
				(
					select p.*, row_number() over (order by p.BrandName asc, p.Name asc) as RecNo
					from #products p
				) tbl
				where tbl.RecNo >= @RecordSince and tbl.RecNo <= @RecordTo
			end else
			if @SortBy = 2 begin	-- 2 - Наименованию
				insert #productsRange (Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount)
				select Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount from
				(
					select p.*, row_number() over (order by p.Name asc) as RecNo
					from #products p
				) tbl
				where tbl.RecNo >= @RecordSince and tbl.RecNo <= @RecordTo
			end else
			if @SortBy = 3 begin	-- 3 - Артикулу
				insert #productsRange (Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount)
				select Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount from
				(
					select p.*, row_number() over (order by p.Sku asc) as RecNo
					from #products p
				) tbl
				where tbl.RecNo >= @RecordSince and tbl.RecNo <= @RecordTo
			end else
			if @SortBy = 4 begin	-- 4 - Остаткам
				insert #productsRange (Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount)
				select Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount from
				(
					select p.*, row_number() over (order by p.Instock asc) as RecNo
					from #products p
				) tbl
				where tbl.RecNo >= @RecordSince and tbl.RecNo <= @RecordTo
			end else
			if @SortBy = 5 begin	-- 5 - Резервам
				insert #productsRange (Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount)
				select Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount from
				(
					select p.*, row_number() over (order by p.Reserved asc) as RecNo
					from #products p
				) tbl
				where tbl.RecNo >= @RecordSince and tbl.RecNo <= @RecordTo
			end else
			if @SortBy = 6 begin	-- 6 - Кол-ву заказов
				insert #productsRange (Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount)
				select Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount from
				(
					select p.*, row_number() over (order by p.OrdersCount asc) as RecNo
					from #products p
				) tbl
				where tbl.RecNo >= @RecordSince and tbl.RecNo <= @RecordTo
			end

		end else begin -- Обратная сортировка

			if @SortBy = 1 begin	-- 1 - Бренду
				insert #productsRange (Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount)
				select Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount from
				(
					select p.*, row_number() over (order by p.BrandName desc, p.Name desc) as RecNo
					from #products p
				) tbl
				where tbl.RecNo >= @RecordSince and tbl.RecNo <= @RecordTo
			end else
			if @SortBy = 2 begin	-- 2 - Наименованию
				insert #productsRange (Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount)
				select Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount from
				(
					select p.*, row_number() over (order by p.Name desc) as RecNo
					from #products p
				) tbl
				where tbl.RecNo >= @RecordSince and tbl.RecNo <= @RecordTo
			end else
			if @SortBy = 3 begin	-- 3 - Артикулу
				insert #productsRange (Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount)
				select Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount from
				(
					select p.*, row_number() over (order by p.Sku desc) as RecNo
					from #products p
				) tbl
				where tbl.RecNo >= @RecordSince and tbl.RecNo <= @RecordTo
			end else
			if @SortBy = 4 begin	-- 4 - Остаткам
				insert #productsRange (Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount)
				select Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount from
				(
					select p.*, row_number() over (order by p.Instock desc) as RecNo
					from #products p
				) tbl
				where tbl.RecNo >= @RecordSince and tbl.RecNo <= @RecordTo
			end else
			if @SortBy = 5 begin	-- 5 - Резервам
				insert #productsRange (Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount)
				select Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount from
				(
					select p.*, row_number() over (order by p.Reserved desc) as RecNo
					from #products p
				) tbl
				where tbl.RecNo >= @RecordSince and tbl.RecNo <= @RecordTo
			end else
			if @SortBy = 6 begin	-- 6 - Кол-ву заказов
				insert #productsRange (Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount)
				select Id, Sku, Name, BrandId, BrandName, Instock, Reserved, OrdersCount from
				(
					select p.*, row_number() over (order by p.OrdersCount desc) as RecNo
					from #products p
				) tbl
				where tbl.RecNo >= @RecordSince and tbl.RecNo <= @RecordTo
			end
		end
				
		-- Объявляем вспомогательную таблицу для подсчета зарезервированных позиций и количества заказов
		create table #reservedOrders 
		(
			OrderId			uniqueidentifier	not null,
			ProductId		uniqueidentifier	not null,
			ReservedCount	int					not null			
		)
		-- Заполняем таблицу
		insert #reservedOrders (OrderId, ProductId, ReservedCount)
		select t.OrderId, t.prodId, sum(t.pCount)
		from
		(
			select 
				o.ID as OrderId, p.Id as prodId, isnull(c.STOCK_QUANTITY,0) as 'pCount'
			from 
				#products p
				join CLIENTORDERSCONTENT c on p.Id = c.PRODUCTID and c.RETURNED = 0 and c.STOCK_QUANTITY > 0
				join CLIENTORDERS o on o.ID = c.CLIENTORDERID and o.STATUS in (2,4,7,8) and o.PACKED = 0
				left join WmsShipmentDocuments d on d.PublicId = o.ID and d.DocStatus = 10
			where 
				d.PublicId is null
			union
			select 
				o.ID as OrderId, p.Id as prodId, c.QUANTITY as 'pCount'
			from #products p
				join CLIENTORDERSCONTENT c on p.Id = c.PRODUCTID and c.RETURNED = 0
				join CLIENTORDERS o on o.ID = c.CLIENTORDERID
				left join WmsShipmentDocuments d on d.PublicId = o.ID and d.DocStatus = 10
			where 
				d.PublicId is null
				and o.ID not in
				(
					-- Исключение Турищева
					'4A80616D-14A4-457E-9449-A87E178A90B4', '6BCA820A-6C2C-4C3F-BE05-F7360D8A92E3'
				)
				and
				(
					-- Статус заказа "Готов к отгрузке" или "Готов к выдаче"					
					(
						o.STATUS in (14, 15)
					)
					-- Статус заказа "Отправлен" (ТК)
					-- и есть признак "Упакован"
					or
					(
						o.STATUS in (9, 16, 17)
						and
						o.PACKED = 1
						and 
						o.DATE > '01/01/2022'
					)
					-- Статус заказа "Получен клиентом" (Самовывоз)
					-- и есть признак "Упакован"
					or
					(
						o.STATUS = 5
						and
						o.PACKED = 1
						and 
						o.DATE > '01/01/2022'
						and
						o.SITEID <> '14F7D905-31CB-469A-91AC-0E04BC8F7AF3'	-- Не розлив
					)
				)
			union
			select 
				d.PublicId as OrderId, i.ProductId as prodId, i.Quantity as 'pCount'
			from 
				#products p
				join WmsShipmentDocumentsItems i on i.ProductId = p.ID
				join WmsShipmentDocuments d on d.Id = i.DocId and d.OuterOrder = 1 and d.DocStatus < 10
		) t
		group by t.OrderId, t.prodId

		-- Выводим результаты
		select	p.Id, p.Sku, p.Name, p.BrandId, p.BrandName, p.Instock, --isnull(ord.rQuantity,0) as 'Reserved', 
				iif(p.Reserved > p.Instock, p.Instock, p.Reserved) as 'Reserved',
				(select count(t.OrderId) from (select distinct o.OrderId from #reservedOrders o group by o.OrderId) t) as 'OrdersCount'
		from #productsRange p 
			left join (
				select o.ProductId, sum(o.ReservedCount) as rQuantity
				from #reservedOrders o
				group by o.ProductId
			) ord on ord.ProductId = p.Id

	end

end
