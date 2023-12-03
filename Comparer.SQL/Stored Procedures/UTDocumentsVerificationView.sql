create proc UTDocumentsVerificationView
(
	@PublicId		varchar(36),		-- Публичный идентификатор документа
	@DateFrom		date,				-- Дата сверки с
	@DateTo			date				-- Дата сверки по
) as
begin
	
	create table #docs
	(
		Id			int			not null,
		primary key (Id)
	)

	if @PublicId is not null begin

		insert #Docs (Id)
		select 
			d.Id
		from 
			UtPriceDocuments d
		where
			d.PublicId = @PublicId

	end else begin

		insert #Docs (Id)
		select 
			d.Id
		from 
			UtPriceDocuments d
		where
			d.[Date] >= @DateFrom and
			d.[Date] <= @DateTo

	end

	-- Если ничего не найдено
	if not exists (select 1 from #Docs)
		return;

	-- Выводим документы
	select 
		d.Id						as 'Id',
		d.PublicId					as 'PublicId',
		d.[Date]					as 'DocDate',
		d.Number					as 'DocNumber',
		case d.[Type]
			when 1 then ''
			when 2 then ''
			else ''
		end							as 'DocType',
		d.IsCancelled				as 'IsCancelled',
		d.CreatedDate				as 'CreatedDate'
	from
		#docs e
		join UtPriceDocuments d with (nolock) on d.Id = e.Id
	
	-- Выводим содержимое документов
	select 
		i.Id						as 'Id',
		i.DocId						as 'DocId',
		i.ProductId					as 'ProductId',
		p.SKU						as 'Sku',
		i.Price						as 'Price',
		isnull(c.SHORTNAME, '?')	as 'Currency',
		isnull(t.OuterId, '?')		as 'TypePublicId',
		isnull(t.[Name], '?')		as 'TypeName'
	from
		#docs e
		join UtPrices i with (nolock) on i.DocId = e.Id
		join PRODUCTS p with (nolock) on p.ID = i.ProductId
		left join UtPriceTypes t with (nolock) on t.Id = i.PriceTypeId
		left join CURRENCIES c on c.CURRENCYID = i.CurrencyId

end
