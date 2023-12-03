create proc UtPriceHistoryView
(
	@ProductId		uniqueidentifier,			-- ИД товара
	@DateFrom		datetime,					-- Дата с
	@DateTo			datetime,					-- Дата по
	@PriceTypeId	int							-- Тип цены
) as
begin

	select
		d.Id			as 'DocId',
		d.CreatedDate	as 'PriceDate',
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
		JOIN UtPriceDocuments d ON p.DocId = d.Id
		JOIN UtPriceTypes pt ON p.PriceTypeId = pt.Id
	where
		ProductId = @ProductId
		AND d.CreatedDate between @DateFrom AND @DateTo
		AND (@PriceTypeId is Null OR @PriceTypeId is Not Null AND p.PriceTypeId = @PriceTypeId)
	order by
		d.CreatedDate desc

end
