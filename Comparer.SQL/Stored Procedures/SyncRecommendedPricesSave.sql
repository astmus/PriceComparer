create proc SyncRecommendedPricesSave
(		
    @SiteId					uniqueidentifier,			--
	-- Out-параметры
	@ErrorMes				nvarchar(255) out			--
	
) as
begin

	declare @trancount int
	select @trancount = @@TRANCOUNT

	declare @orderId uniqueidentifier
	set @ErrorMes = ''

	declare 
		@now datetime = getdate()

	begin try

	if (not object_id('tempdb..#tmp_updateProductSync') is null) drop table #tmp_updateProductSync
	create table #tmp_updateProductSync
	(	
		ProductId			uniqueidentifier		not null,   -- Идентификатор товара  
		PublicId			varchar(100)		not null,       -- Идентификатор товара во внешней системе
		PublicSku			varchar(100)		null,			-- Артикул товара во внешней системе
	)

	if @trancount = 0
			begin transaction 

			--Обновляем список синхронизированных товаров
			insert #tmp_updateProductSync
			select 
				p.Id as 'ProductId',
				PublicId,
				PublicSku
			from #tmp_prices tp
			join Products p on p.Sku = tp.Sku

			exec SyncProductsSave @SiteId, @ErrorMes out



			--обновляем старые
			update srp 
			set srp.RecommendedPrice = tp.RecommendedPrice,
				srp.MinPrice	     = tp.MinPrice
			from #tmp_prices tp
			join ProductsSync ps on tp.PublicId = ps.PublicId and ps.SiteId = @SiteId
			join SyncRecommendedPrices srp on srp.ProductId = ps.ProductId and srp.SiteId = @SiteID


			--update sp
			--set sp.sp_recommendedretailprice = tp.RecommendedPrice
			--from #tmp_prices tp
			--join ProductsSync ps on tp.PublicId = ps.PublicId and ps.SiteId = @SiteId
			--join SiteProducts sp on sp.ProductId = ps.ProductId and sp.SITEID = @SiteId

			--Вставляем новые 
			insert SyncRecommendedPrices(SiteId, ProductId, RecommendedPrice, MinPrice)
			(select 
				@SiteId,
				ps.ProductId as 'ProductId',
				tp.RecommendedPrice,
				tp.MinPrice
			from #tmp_prices tp
			left join ProductsSync ps on ps.PublicId = tp.PublicId and ps.SiteId = @SiteId
			left join SyncRecommendedPrices s on s.ProductId = ps.ProductId and s.SiteId = @SiteId
			where s.ProductId is null and ps.ProductId  is not null)
		
		drop table #tmp_updateProductSync
		
		if @trancount = 0
			commit transaction
		--return 0

	end try
	begin catch
		if @trancount = 0
			rollback transaction

		set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры SyncRecommendedPricesSave!'

		declare @err_mes nvarchar(4000)
		select @err_mes = ERROR_MESSAGE()
		
		if len(@err_mes) > 220
			set @ErrorMes = ('SyncRecommendedPricesSave! ' + substring(@err_mes, 1, 220) + '...')
		else
			set @ErrorMes = ('SyncRecommendedPricesSave! ' + @err_mes)	
		
		return 1
	end catch

	return 0
	
end
