create proc UtDoubtfulPriceDocumentsView 
(
	@DocNumber		varchar(64) = null,		-- Номер документа
	@DateFrom		datetime = null,		-- Дата с
	@DateTo			datetime = null,		-- Дата по
	@ReasonId		int = null,				-- Причина
	@DocTypeId		int = null,				-- Тип документа УТ
	@PriceTypeId	int = null,				-- Тип цены
	@Sku			int = null				-- Артикул
) as
begin
	
	select
		pd.Id,
		pd.Number,
		pd.[Date],
		pd.[CreatedDate],
		pd.[Type],
		dd.ReasonId,
		dd.CreatedDate	as 'DoubtDate'
	from
		UTPriceDocuments pd
		JOIN UtDoubtfulPriceDocuments dd ON pd.Id = dd.DocId
	where
		(@DocNumber is Null OR @DocNumber is Not Null AND pd.Number = @DocNumber) AND
		(@DateFrom  is Null OR @DateFrom is Not Null AND pd.[Date] >= @DateFrom) AND
		(@DateTo    is Null OR @DateTo   is Not Null AND pd.[Date] < @DateTo) AND
		(@ReasonId  is Null OR @ReasonId is Not Null AND dd.[ReasonId] = @ReasonId) AND
		(@DocTypeId is Null OR @DocTypeId is Not Null AND pd.[Type] = @DocTypeId) AND
		(@PriceTypeId is Null OR @PriceTypeId is Not Null AND 
			Exists(
				select 1 from UtPrices utp where utp.DocId = pd.Id AND utp.PriceTypeId = @PriceTypeId
			)
		) AND
		(@Sku       is Null OR @Sku     is Not Null AND 
			Exists(
				select 1 from UtPrices utp JOIN PRODUCTS p ON utp.ProductId = p.ID
				where
					utp.DocId = pd.Id AND
					p.SKU = @Sku
			)
		)

end
