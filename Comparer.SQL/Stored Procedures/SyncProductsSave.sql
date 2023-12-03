create proc SyncProductsSave
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
	if @trancount = 0
			begin transaction 


		--Вставляем новые 
		insert ProductsSync(ProductId, SiteId, PublicId, PublicSku, ChangedDate, CreatedDate)
		(select
			tp.ProductId,
			@SiteId,
			tp.PublicId,
			tp.PublicSku,
			getdate(),
			getdate()
		from #tmp_updateProductSync tp
		left join ProductsSync p on p.ProductId = tp.ProductId and p.SiteId = @SiteId
		where p.ProductId is null)

		-- Так как у нас уже есть в ProductsSync товары, для которых сохранен внешний артикул, но нет id, то надо и обновлять
		update ps
		set ps.PublicId = tp.PublicId,
		ps.ChangedDate =  getdate()
		from #tmp_updateProductSync tp 
			join ProductsSync ps on ps.ProductId = tp.ProductId and ps.SiteId = @SiteId

		
		if @trancount = 0
			commit transaction
		--return 0

	end try
	begin catch
		if @trancount = 0
			rollback transaction

		set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры SyncProductsSave!'

		declare @err_mes nvarchar(4000)
		select @err_mes = ERROR_MESSAGE()
		
		if len(@err_mes) > 220
			set @ErrorMes = ('SyncProductsSave! ' + substring(@err_mes, 1, 220) + '...')
		else
			set @ErrorMes = ('SyncProductsSave! ' + @err_mes)	
		
		return 1
	end catch

	return 0
	
end
