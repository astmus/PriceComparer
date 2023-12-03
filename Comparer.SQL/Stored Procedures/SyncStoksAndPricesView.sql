create proc SyncStoksAndPricesView
(		
    @SiteId			uniqueidentifier		-- Идентификатор сайта
) as
begin

	begin try

	declare
		@WarehouseId	bigint		--- Идентификатор склада в системе Маркетплейса (основной склад Randewoo)
	select
		@WarehouseId = 
			case 
				when @SiteId = '5D4463C6-EBA6-4DD5-8618-D07AE3A23D9A'	then 15812181470000  -- OZON
				when @SiteId = 'B30E878A-C805-436E-9EAC-7865337DBEA8'	then 49125			 -- Yandex 
			else null
			end	
		
		select 
			p.Id						as 'ProductId',
			p.SKU						as 'Sku',
			sync.PublicId				as 'PublicId',
			isnull(sync.PublicSku,'')	as 'PublicSku',
			p.NeedDataMatrix			as 'NeedDataMatrix',

			sp.SP_WITHDISCOUNT			as 'Price',
			dbo.SelectPrice(sp.SP_HandFixedRetailPrice, sp.SP_RECOMMENDEDRETAILPRICE, sp.SP_RETAILPRICE)
										as 'BasePrice',
			dbo.SelectPrice(sp.SP_HandFixedRetailPrice, sp.SP_RECOMMENDEDRETAILPRICE, sp.SP_RETAILPRICE)
										as 'AdditionalPrice',
			isnull(z.RetailPrice, 0)	as 'LastPrice',
			iif((p.ManId in ('1886C20C-2230-4535-8E5E-F233D67DF081',
							 '37D9DE33-418C-4441-947F-0C45F05FE7A0',
							 'D1FB456B-17BE-47BF-AF8D-B0FACB36BD64',
							 'AC7834E2-4DB6-46E3-B636-77315879C0C8',
							 'BA24A452-351A-47DE-9647-15BFC770618B',
							 '671AF265-60C5-492E-BEF4-7669914BDDD1')), -- Бренды, по которым фактическую цену ставим минимальной), 
				sp.SP_WITHDISCOUNT, null)	as 'MinimalPrice',

			isnull(inst.Instock, isnull(ps.FreeStock, 0))
										as 'Stock',
			@WarehouseId				as 'WarehouseId'
		from 
			Products p 
			join SITEPRODUCTS sp on sp.PRODUCTID = p.ID and sp.SITEID = @SiteId
			join ProductsSync sync on p.Id = sync.ProductId and sync.siteId = sp.SITEID
			left join SyncProductsInstockData inst on inst.ProductId = sp.PRODUCTID and inst.SiteId = sp.SITEID		
			left join LastNoZeroRetailPrices z on z.ProductId = sp.PRODUCTID and z.SiteId = sp.SITEID		
			left join ShowcaseProductsStock ps on ps.ProductId = sp.PRODUCTID and ps.SiteId = sp.SITEID
		order by
			p.MANID, p.SKU 	
		
		return 0

	end try
	begin catch
		return 1
	end catch
	
end
