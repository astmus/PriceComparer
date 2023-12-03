create proc IncrementOrdersInstockQuantity_v3
(
	@Mode		int			-- Режим распределения
							-- 1 - Приемка
							-- 2 - Распределение свободных остатков
)
as
begin

	-- Артикулы и их кол-во, которые ожидаются по заданиям на закупку
	-- на основе данных о распределении
	create table #purchaseDistributionSkus
	(			
		Number			int			not null,
		Sku				int			not null,
		Quantity		int			not null,
		IsArchive		bit			not null
		primary key (Number, Sku)
	)

	-- Таблица для артикулов Отливантов
	create table #otlivants
	(
		ProductId		uniqueidentifier		not null
		primary key (ProductId)
	)

	insert #otlivants (ProductId)
	select 
		distinct i.ProductId
	from 
		#productsForCorrectOrdersInstockQuantity i
		join PRODUCTS p with (nolock) on p.ID = i.ProductId
	where
		p.IsOtlivant = 1

	-- DEBUG
	--select * from #productsForCorrectOrdersInstockQuantity p where p.ProductId in ('2E7E87D5-191A-4F71-B44E-2AFC706AA2C1','B7BDF276-AB63-45A5-A907-2F41DD52AE34','2FD9349D-1819-4DB0-B8E9-51E65A1AD07E')
	-- DEBUG

	-- Если распределение из Приемки
	if @Mode = 1 begin

		-- Активные записи распределения
		insert #purchaseDistributionSkus (Number, Sku, Quantity, IsArchive)
		select 
				h.Number, h.Sku, sum(h.Quantity - h.FactQuantity), 0
		from
			#purchaseTaskCodesForCorrectOrdersInstocQuantity p
			join PurchaseTasksContentDistributionHistory h on h.Code = p.Code
		group by
			h.Number, h.Sku

		-- Дополняем записями из архива, если приемка пришла после закрытия ОП
		insert #purchaseDistributionSkus (Number, Sku, Quantity, IsArchive)
		select 
			a.Number, a.Sku, a.Quantity, 1
		from
			(
				select 
						h.Number, h.Sku, sum(h.Quantity - h.FactQuantity) as 'Quantity'
				from
					#purchaseTaskCodesForCorrectOrdersInstocQuantity p
					join PurchaseTasksContentDistributionHistoryArchive h on h.Code = p.Code
				group by
					h.Number, h.Sku
			) a
			left join #purchaseDistributionSkus h on h.Number = a.Number and h.Sku = a.Sku
		where
			h.Number is null

	end

	declare 
		@ProductId		uniqueidentifier, 
		@Quantity		int
		
	declare incCursor cursor for
	select i.ProductId, i.Quantity
	from 
		#productsForCorrectOrdersInstockQuantity i

	open incCursor 

	fetch next from incCursor into @ProductId, @Quantity

	while @@fetch_status = 0
	begin
			
		exec IncrementOrderItemInstockQuantity_v3 @ProductId, @Quantity, @Mode
	
		fetch next from incCursor into @ProductId, @Quantity
	end

	close incCursor
	deallocate incCursor

	drop table #purchaseDistributionSkus
	drop table #otlivants

end
