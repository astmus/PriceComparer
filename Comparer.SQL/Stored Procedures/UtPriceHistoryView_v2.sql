create proc UtPriceHistoryView_v2
(
	@ProductId		uniqueidentifier,			-- ИД товара
	@ProductSKU		int,						-- Артикл товара
	@DateFrom		datetime,					-- Дата с
	@DateTo			datetime,					-- Дата по
	@PriceTypeId	int,						-- Тип цены

	-- Выходные параметры -----
	@ErrorMes		nvarchar(2000) out			-- Ошибка
) as
begin

	if (@PriceTypeId = 0)
		set @PriceTypeId = null

	if @ProductId is null begin
		select @ProductId = p.ID from PRODUCTS p where p.SKU = @ProductSKU
		
		if (@ProductId is null) begin
			set @ErrorMes = 'Товар не определен!'
			return 1
		end
	end
		

	select
		d.Id			as 'DocumentId',
		d.Number		as 'DocumentNumber',
		d.[Date]		as 'PriceDate',
		d.[CreatedDate]	as 'CreatedDate',
		p.Id			as 'Id',		
		p.ProductId		as 'ProductId',
		p.Price			as 'Price',
		p.PriceTypeId	as 'PriceTypeId',
		p.CurrencyId	as 'CurrencyId',
		pt.Name			as 'PriceType',
		IIF(p.CurrencyId = 1, 'руб', IIF(p.CurrencyId = 2, 'usd', 'eur'))
						as 'Currency'
	from
		UtPrices p
		join UtPriceDocuments d ON p.DocId = d.Id
		join UtPriceTypes pt ON p.PriceTypeId = pt.Id
	where
		ProductId = @ProductId
		and d.Date between @DateFrom and @DateTo
		and p.PriceTypeId <> 5	-- Не оптовая цена
		and (@PriceTypeId is null or @PriceTypeId is not null and p.PriceTypeId = @PriceTypeId)
	order by
		d.Date desc

	return 0
end
