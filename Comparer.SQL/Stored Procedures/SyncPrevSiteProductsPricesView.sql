create proc SyncPrevSiteProductsPricesView
(
	@InfoType			int,					-- Тип выводимой информации
												-- 1 - Общее количество товаров, отвечающее условиям
												-- 2 - Список товаров, отвечающий условиям
	@Limit				int,					-- Мак кол-во строк
	@Offset				int,					-- Смещение
	@SiteId				uniqueidentifier		-- Идентификатор сайта
)
as
begin

	declare @mode int = 1
	if exists (select 1 from #skus)
		set @mode = 2

	-- Если нужно вывести только кол-во
	if @InfoType = 1 begin

		-- Дата изменения
		if @Mode = 1 begin
	
			select count(1) as 'TotalCount'
			from PrevSiteProducts sp
				join PRODUCTS p on p.ID = sp.PRODUCTID and p.VIEWSTYLEID in (1,4) and p.DELETED = 0
			where sp.SITEID = @SiteId
				
	
		end else
		-- Артикулы
		if @Mode = 2 begin
	
			select count(1) as 'TotalCount'
			from PrevSiteProducts sp
				join PRODUCTS p on p.ID = sp.PRODUCTID and p.VIEWSTYLEID in (1,4) and p.DELETED = 0
				join #skus skus on skus.Sku = p.SKU
			where sp.SITEID = @SiteId
			
		end

		return 0

	end


	-- Таблица для идентификаторов товаров
	declare @ids table 
	(
		Id		uniqueidentifier	not null,
		Sku		int					not null
		primary key(Id)
	)
	
	-- Заполняем таблицу
	-- Дата изменения
	if @Mode = 1 begin
	
		insert @ids (Id, Sku)
		select pid.ID, pid.SKU
		from
		(
			select p.ID, p.SKU,
				row_number() over (order by p.SKU) as rowNum
			from PrevSiteProducts sp
				join PRODUCTS p on p.ID = sp.PRODUCTID and p.VIEWSTYLEID in (1,4) and p.DELETED = 0
			where sp.SITEID = @SiteId
		) pid
		where pid.rowNum > @Offset and pid.rowNum <= (@Offset + @Limit)
	
	end else
	-- Артикулы
	if @Mode = 2 begin
	
		insert @ids (Id, Sku)
		select p.ID, p.SKU
		from PrevSiteProducts sp
			join PRODUCTS p on p.ID = sp.PRODUCTID and p.VIEWSTYLEID in (1,4) and p.DELETED = 0
			join #skus skus on skus.Sku = p.SKU
		where sp.SITEID = @SiteId
	end

	-- Выводим информацию
	select
		p.Sku									as 'Sku',
		sp.RetailPrice							as 'PriceCalc',
		sp.FixedPrice							as 'PriceRRC',
		isnull(sp.HandFixedRetailPrice,0)		as 'PriceHandFixed',
		sp.FinalPrice							as 'Price',
		sp.PrevFinalPrice						as 'PrevPrice',
		sale.SaleControlType					as 'SaleControlType',
		sale.SaleState							as 'SaleState',
		d.PUBLICGUID							as 'DiscountGuid',
		d.ACTIONS								as 'DiscountActions',
		isnull(z.RetailPrice,0)					as 'LastPrice'
	from PrevSiteProducts sp
		join SITES s on s.ID = sp.SITEID and sp.SITEID = @SiteId
		join @ids p on p.Id = sp.PRODUCTID
		join ProductsSale sale on sale.ProductId = p.ID
		left join DISCOUNTS d on d.ID = sp.DiscountId
		left join LastNoZeroRetailPrices z on z.SiteId = sp.SiteId and z.ProductId = sp.ProductId

end
