create proc ClosestCompetitorsView
(	
	@SiteId				uniqueidentifier,		-- Идентификатор сайта
	@Sku				int,					-- Артикул товара
	@Mode				int,					-- Режим отображения
												-- 1 - ВСЕ
												-- 2 - У конкурентов цена меньше
	@Limit				int,					-- Кол-во строк
	@Offset				int,					-- Смещение
	@OrderBy			varchar(255),			-- Поле для сортировки
	-- Выходные параметры
	@TotalCount			int out					-- Общее кол-во записей, удовлетворяющих условиям
) as
begin

	set @TotalCount = 0

	-- Таблица для идентификаторов товаров
	create table #ids
	(
		Id		uniqueidentifier	not null,
		RowNo	int					not null,
		primary key (Id)
	)

	-- Заполняем таблицу
	if @OrderBy = 'ProductName' begin

		insert #Ids (Id, RowNo)
		select 
			p.Id, row_number() over (order by m.NAME, p.FullName)
		from 
			Products p
			join Manufacturers m on m.ID = p.MANID
			join SiteProducts sp on sp.ProductId = p.Id
			join ClosestCompetitors c on c.ProductId = p.Id
		where
			p.Deleted = 0
			and sp.SiteId = @SiteId
			and sp.SP_WithDiscount > 0
			and 
			(
				@Mode = 1
				or
				(
					@Mode = 2
					and
					sp.SP_WithDiscount >= c.Price1	-- <= ???
				)
			)
			and 
			(
				@Sku is null
				or
				(
					@Sku is not null
					and
					p.SKU = @Sku
				)
			)
	end

	-- Получаем общее кол-во записей
	select @TotalCount = count(1) from #Ids

	-- Выводим результат
	select
		@SiteId						as 'SiteId',
		p.ID						as 'Id',
		p.Sku						as 'Sku',
		p.Published					as 'IsActive',
		m.NAME						as 'Brand',
		p.FullName					as 'Name',
		p.Instock					as 'Instock',
		p.Price						as 'BasePrice',
		p.DefaultCurrency			as 'BaseCurrency',
		-- Сайт
		sp.SP_WithDiscount			as 'SitePrice',
		-- Конкурент 1
		c.CompetitorId1				as 'CompetitorId1',
		c1.Name						as 'CompetitorName1',
		c.Price1					as 'CompetitorPrice1',
		-- Конкурент 2
		c.CompetitorId2				as 'CompetitorId2',
		c2.Name						as 'CompetitorName2',
		c.Price2					as 'CompetitorPrice2',
		-- Конкурент 3
		c.CompetitorId3				as 'CompetitorId3',
		c3.Name						as 'CompetitorName3',
		c.Price3					as 'CompetitorPrice3',
		-- Поставщики 1
		pp.DistributorID			as 'DistId1',
		pp.DistributorName			as 'DistName1',
		pp.PRICE					as 'DistPrice1',
		pp.CURRENCY					as 'DistCurrency1',
		-- Поставщики 2
		pp.DistributorID1			as 'DistId2',
		pp.DistributorName1			as 'DistName2',
		pp.PRICE1					as 'DistPrice2',
		pp.CURRENCY1				as 'DistCurrency2',
		-- Поставщики 3
		pp.DistributorID2			as 'DistId3',
		pp.DistributorName2			as 'DistName3',
		pp.PRICE2					as 'DistPrice3',
		pp.CURRENCY2				as 'DistCurrency3'
	from
		Products p
		join #Ids i on i.Id = p.ID
		join Manufacturers m on m.ID = p.MANID
		join SiteProducts sp on sp.ProductId = p.Id
		join ClosestCompetitors c on c.ProductId = p.Id
		join Competitors c1 on c1.Id = c.CompetitorId1
		left join Competitors c2 on c2.Id = c.CompetitorId2
		left join Competitors c3 on c3.Id = c.CompetitorId3
		left join PurchasesPrice pp on pp.SKU = p.Sku
	where
		i.RowNo > @Offset 
		and i.RowNo <= (@Offset + @Limit)
		and sp.SiteId = @SiteId
	order by
		i.RowNo

end
