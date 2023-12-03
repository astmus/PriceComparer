create proc UtPriceDocumentsView
(
	@Number				nvarchar(64),			-- Номер документа
	@CreatedFrom		datetime,				-- Период поиска по
	@CreatedTo			datetime,				-- Период поиска с 
	@TypeId				int,					-- Тип документа
	@PriceTypeId		int,					-- Тип цены
	@Sku				int						-- Артикул
) as
begin
	
	select
		d.Id,
		d.PublicId,
		d.Number,
		d.[Date],
		d.[Type],
		d.IsCancelled,
		d.CreatedDate,
		d.ChangedDate
	from
		UtPriceDocuments d
		/*left join
		(
			select 
				pr.DocId 
			from 
				UTPrices pr 
			where 
				pr.PriceTypeId = @PriceTypeId
		) i on i.DocId = d.Id*/
	where 
		(
			@Number is not null 
			and 
			d.Number = @Number
		)
		or
		(
			@Number is null 
			and
			(
				(@CreatedFrom is null or (@CreatedFrom is not null and d.Date >= cast(@CreatedFrom as date)))
				and (@CreatedTo is null or (@CreatedTo is not null and d.Date <= cast(@CreatedTo as date))) 
				and (@TypeId is null or (@TypeId is not null and d.[Type] = @TypeId))
				and 
				(
					@PriceTypeId is null
					or
					(
						@PriceTypeId is not null
						and
						d.Id in
						(
							select pr.DocId from UTPrices pr where pr.PriceTypeId = @PriceTypeId
						)
					)
				)
				and 
				(
					@Sku is null
					or
					(
						@Sku is not null
						and
						d.Id in
						(
							select pr.DocId from UTPrices pr join PRODUCTS p on pr.ProductId = p.ID where p.SKU = @Sku
						)
					)
				)
			)
		)
		order by d.Date desc
		
end
