create proc SyncSiteProductsPricesView
(
	@InfoType			int,					-- Тип выводимой информации
												-- 1 - Общее количество товаров, отвечающее условиям
												-- 2 - Список товаров, отвечающий условиям
	@Mode				int,					-- Режим поиска
												-- 1 - По дате изменения
												-- 2 - По списку артикулов
	@Limit				int,					-- Мак кол-во строк
	@Offset				int,					-- Смещение
	@ChangedDateSince	datetime = null,		-- Дата изменения с
	@SiteId				uniqueidentifier		-- Идентификатор сайта
)
as
begin

	-- Если нужно вывести только кол-во
	if @InfoType = 1 begin

		-- Дата изменения
		if @Mode = 1 begin
	
			select count(1) as 'TotalCount'
			from SITEPRODUCTS sp
				join PRODUCTS p on p.ID = sp.PRODUCTID and p.VIEWSTYLEID in (1,4) and p.DELETED = 0
			where sp.SITEID = @SiteId and
				(@ChangedDateSince is null or (@ChangedDateSince is not null and p.CHANGEDATE >= @ChangedDateSince))
	
		end else
		-- Артикулы
		if @Mode = 2 begin
	
			select count(1) as 'TotalCount'
			from SITEPRODUCTS sp
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
			from SITEPRODUCTS sp
				join PRODUCTS p on p.ID = sp.PRODUCTID and p.VIEWSTYLEID in (1,4) and p.DELETED = 0
			where sp.SITEID = @SiteId and
				(@ChangedDateSince is null or (@ChangedDateSince is not null and p.CHANGEDATE >= @ChangedDateSince))
		) pid
		where pid.rowNum > @Offset and pid.rowNum <= (@Offset + @Limit)
	
	end else
	-- Артикулы
	if @Mode = 2 begin
	
		insert @ids (Id, Sku)
		select p.ID, p.SKU
		from SITEPRODUCTS sp
			join PRODUCTS p on p.ID = sp.PRODUCTID and p.VIEWSTYLEID in (1,4) and p.DELETED = 0
			join #skus skus on skus.Sku = p.SKU
		where sp.SITEID = @SiteId
	end

	-- Выводим информацию
	select
		--p.Id									as 'ProductId',
		p.Sku									as 'Sku',
		--0										as 'ViewStyleId',
		--s.ID									as 'SiteId',
		--s.NAME									as 'SiteName',
		--s.HOST									as 'SiteHost',
		--s.DataBusSync							as 'DataBusSync',
		sp.SP_RETAILPRICE						as 'PriceCalc',
		sp.SP_RECOMMENDEDRETAILPRICE			as 'PriceRRC',
		isnull(sp.SP_HandFixedRetailPrice,0)	as 'PriceHandFixed',
		sp.SP_WITHDISCOUNT						as 'Price',
		sale.SaleControlType					as 'SaleControlType',
		sale.SaleState							as 'SaleState',
		--d.ID									as 'DiscountId',
		d.PUBLICGUID							as 'DiscountGuid',
		--d.NAME									as 'DiscountName',
		d.ACTIONS								as 'DiscountActions'
	from SITEPRODUCTS sp
		join SITES s on s.ID = sp.SITEID and sp.SITEID = @SiteId
		join @ids p on p.Id = sp.PRODUCTID
		join ProductsSale sale on sale.ProductId = p.ID
		left join DISCOUNTS d on d.ID = sp.SP_DISCOUNTID

end
