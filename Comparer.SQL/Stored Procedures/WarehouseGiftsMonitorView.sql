create proc WarehouseGiftsMonitorView
(	
	@Mode			int = 1			-- Режим отображения
									-- 1 - Все товары во всех активных акциях
									-- 2 - Все товары конкретной акции
									-- 3 - Товары с указанными артикулами
) as
begin
	
	declare @now datetime = getdate()

	-- Все товары во всех активных акциях
	if @Mode = 1 begin

		insert #GiftDiscounts (Id, Name, Gifts)
		select g.ID, g.NAME, g.ACTIONS
		from GIFTS g
		where	g.ACTIVE = 1			and
				g.DATEFROM < @now		and
				g.DATETO > @now			and
				--g.Id = 29				and
				g.ACTIONS like '%"type":"add_product"%'

		if exists (select 1 from #GiftDiscounts) begin

			declare @res int = 1
			exec @res = WarehouseGiftsMonitorPrepareView
			if @res = 1 begin
				select 'Error'
				return
			end

			select 
				p.ID as 'Id',
				p.SKU as 'Sku',
				m.NAME as 'BrandName', 
				p.NAME + ' ' + p.CHILDNAME as 'Name',
				isnull(ps.Stock, 0) as 'Instock',
				isnull(ps.TotalReserveStock, 0) as 'Reserved',
				isnull(g.ID, 0) as 'GiftId',
				isnull(g.NAME, '') as 'GiftName',
				g.DATEFROM as 'GiftDateFrom',
				g.DATETO as 'GiftDateTo'
			from 
				#GiftDiscountsSkus gs
				join PRODUCTS p on p.SKU = gs.Sku
				join MANUFACTURERS m on m.ID = p.MANID
				left join GIFTS g on g.ID = gs.DiscountId
				left join ShowcaseProductsStock ps on ps.ProductId = p.ID and ps.SiteId = '48E0A097-E897-4ABD-8B98-2B3FFC6C405B'
			where
				p.DELETED = 0
			order by 
				GiftId, BrandName, Name
			
		end else begin

			select 'Empty'

		end

	end


end
