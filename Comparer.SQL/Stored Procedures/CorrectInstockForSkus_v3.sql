create proc CorrectInstockForSkus_v3 
(	
	@WarehouseId	int,		-- Идентификатор склада
	@ModeId		int,			-- Режим корректировки остатков:
								-- 1 - Поступление (увеличивает остатки)
								-- 2 - Отгрузка (уменьшает остатки)
								-- 3 - Изменение качества  (изменяет качество)
	@DocumentType   int,		-- Тип документа WMS:
								-- 2 - Приемка 
								-- 4 - Отгрузка 
								-- 5 - Акт сверки
								-- 6 - Документ Комплектации
	@DocId			bigint		-- Идентификатор документа			
) as
begin

	-- Если изменение качества
	if @ModeId = 3 begin

		-- DEBUG
		-- select * from #skusForInstockCorrect
		-- DEBUG

		-- Обновляем существующие (увеличиваем те качества, в которые перешли товары)
		update i
		set 
			i.Stock = i.Stock + c.Quantity
		from 
			(
				select 
					ProductId, QualityId, sum(Quantity) as 'Quantity'
				from 
					#skusForInstockCorrect
				group by 
					ProductId, QualityId
			) c
			join WarehousesStockQuality i on i.ProductId = c.ProductId and i.QualityId = c.QualityId
		where
			i.WarehouseId = @WarehouseId

		-- Вставляем новую запись, если указанного качества для конкретного товара еще нет
		insert WarehousesStockQuality (WarehouseId, ProductId, QualityId, Stock)
		select 
			@WarehouseId, c.ProductId, c.QualityId, c.Quantity
		from 
			(
				select 
					ProductId, QualityId, sum(Quantity) as 'Quantity'
				from 
					#skusForInstockCorrect
				group by 
					ProductId, QualityId
			) c
			left join WarehousesStockQuality i on i.WarehouseId = @WarehouseId and i.ProductId = c.ProductId and i.QualityId = c.QualityId
		where 
			i.ProductId is null

		-- Обновляем существующие (ументшаем те качества, из которых перешли товары)
		update i
		set 
			i.Stock = i.Stock - c.Quantity
		from 
			(
				select ProductId, OldQualityId, sum(Quantity) as 'Quantity'
				from 
					#skusForInstockCorrect
				where
					OldQualityId <> 0
				group by 
					ProductId, OldQualityId
			) c
			join WarehousesStockQuality i on i.ProductId = c.ProductId and i.QualityId = c.OldQualityId
		where
			i.WarehouseId = @WarehouseId

		-- Вставляем новую запись, если указанного качества для конкретного товара еще нет
		insert WarehousesStockQuality (WarehouseId, ProductId, QualityId, Stock)
		select 
			@WarehouseId, c.ProductId, c.OldQualityId, -c.Quantity
		from 
			(
				select 
					ProductId, OldQualityId, sum(Quantity) as 'Quantity'
				from 
					#skusForInstockCorrect
				where
					OldQualityId <> 0
				group by 
					ProductId, OldQualityId
			) c
			left join WarehousesStockQuality i on i.WarehouseId = @WarehouseId and i.ProductId = c.ProductId and i.QualityId = c.OldQualityId
		where 
			i.ProductId is null

	end else begin

		declare 
			@factor int = 1
		if @ModeId = 1 
			set @factor = -1

		-- Записываем в историю текущие остатки и новые
		insert WarehouseProductsStockHistory (WarehouseId, ProductId, OldStock, NewStock, DocumentType, DocId)
		select 
			@WarehouseId, c.ProductId, isnull(w.Stock, 0), isnull(w.Stock, 0) - (c.Quantity * @factor), @DocumentType, @DocId
		from 
			(
				select 
					ProductId, sum(Quantity) as 'Quantity'
				from 
					#skusForInstockCorrect
				group by 
					ProductId
			) c
			left join WarehousesStock w on w.ProductId = c.ProductId and w.WarehouseId = @WarehouseId

		-- Приход
		if @ModeId = 1 begin

			-- Обновляем существующие
			update i
			set 
				i.Stock = i.Stock + c.Quantity
			from 
				(
					select ProductId, QualityId, sum(Quantity) as 'Quantity'
					from 
						#skusForInstockCorrect
					where
						QualityId is not null
					group by 
						ProductId, QualityId
				) c
				join WarehousesStockQuality i on i.ProductId = c.ProductId and i.QualityId = c.QualityId
			where
				i.WarehouseId = @WarehouseId

			-- Создаем новые
			insert WarehousesStockQuality (WarehouseId, ProductId, QualityId, Stock)
			select 
				@WarehouseId, c.ProductId, c.QualityId, c.Quantity
			from 
				(
					select ProductId, QualityId, sum(Quantity) as 'Quantity'
					from 
						#skusForInstockCorrect
					where
						QualityId is not null
					group by 
						ProductId, QualityId
				) c
				left join WarehousesStockQuality i on i.WarehouseId = @WarehouseId and i.ProductId = c.ProductId and i.QualityId = c.QualityId
			where 
				i.ProductId is null

		end else
		-- Расход
		if @ModeId = 2 begin
			
			-- Обновляем существующие
			update i
			set 
				i.Stock = i.Stock - c.Quantity
			from 
				(
					select ProductId, QualityId, sum(Quantity) as 'Quantity'
					from 
						#skusForInstockCorrect
					where
						QualityId is not null
					group by 
						ProductId, QualityId
				) c
				join WarehousesStockQuality i on i.ProductId = c.ProductId and i.QualityId = c.QualityId
			where
				i.WarehouseId = @WarehouseId

			-- Создаем новые
			insert WarehousesStockQuality (WarehouseId, ProductId, QualityId, Stock)
			select 
				@WarehouseId, c.ProductId, c.QualityId, -c.Quantity
			from 
				(
					select ProductId, QualityId, sum(Quantity) as 'Quantity'
					from 
						#skusForInstockCorrect
					where
						QualityId is not null
					group by 
						ProductId, QualityId
				) c
				left join WarehousesStockQuality i on i.WarehouseId = @WarehouseId and i.ProductId = c.ProductId and i.QualityId = c.QualityId
			where 
				i.ProductId is null
				
		end

	end

	-- Остатки для обновления сводных данных (агрегатов)
	create table #summary
	(
		WarehouseId			int						not null,			-- Идентификатор склада
		ProductId			uniqueidentifier		not null,			-- Идентификатор товара
		Stock				int						not null,			-- Остатки
		ConditionStock		int						not null			-- Остатки, доступные к продаже
		primary key (WarehouseId, ProductId)
	)

	insert #summary (WarehouseId, ProductId, Stock, ConditionStock)
	select
		s.WarehouseId, s.ProductId, 
		sum(s.Stock)							as 'Stock', 
		sum(iif(IsCondition = 1, s.Stock, 0))	as 'ConditionStock' 
	from
	(
		select 
			s.WarehouseId, s.ProductId, s.Stock, 
			cast(iif(s.QualityId in (1,8,9), 1, 0) as bit) as 'IsCondition'
		from 
			WarehousesStockQuality s
			join (select distinct ProductId from #skusForInstockCorrect) p on p.ProductId = s.ProductId
	) s
	group by
		s.WarehouseId, s.ProductId
			
	-- Выполняем корректировку сводных остатков по складам
	update w
	set 
		w.Stock				= s.Stock,
		w.ConditionStock	= s.ConditionStock
	from 
		#summary s
		join WarehousesStock w on w.WarehouseId = s.WarehouseId and w.ProductId = s.ProductId

	-- Вставляем записи сводных остатков по складам, которых еще нет
	insert WarehousesStock (WarehouseId, ProductId, Stock, ConditionStock)
	select 
		s.WarehouseId, s.ProductId, s.Stock, s.ConditionStock
	from 
		#summary s
		left join WarehousesStock w on w.WarehouseId = s.WarehouseId and w.ProductId = s.ProductId
	where
		w.ProductId is null
				
	-- Выполняем корректировку сводных остатков по витринам
	update s
	set 
		s.Stock				= l.Stock,
		s.ConditionStock	= l.ConditionStock
	from 
		(
			select
				l.SiteId, s.ProductId, 
				sum(s.Stock)			as 'Stock', 
				sum(s.ConditionStock)	as 'ConditionStock'
			from
				#summary s
				join WarehouseShowcaseLinks l on l.WarehouseId = s.WarehouseId
			where
				l.IsActive = 1
			group by 
				l.SiteId, s.ProductId
		) l
		join ShowcaseProductsStock s on s.SiteId = l.SiteId and s.ProductId = l.ProductId

	-- Вставляем записи для сводных остатков по витринам, которых еще нет
	insert ShowcaseProductsStock (SiteId, ProductId, Stock, ConditionStock)
	select
		l.SiteId, l.ProductId, l.Stock, l.ConditionStock
	from 
		(
			select
				l.SiteId, s.ProductId, 
				sum(s.Stock)			as 'Stock', 
				sum(s.ConditionStock)	as 'ConditionStock'
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

end
