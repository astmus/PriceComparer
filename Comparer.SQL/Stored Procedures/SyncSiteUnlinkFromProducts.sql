create proc SyncSiteUnlinkFromProducts (
	@SiteId			uniqueidentifier,			-- Идентификатор заказа
	@NeedSync		bit,						-- Требует синхронизации после связывания
	-- Out-параметры
	@ErrorMes		varchar(4000) out			-- Сообщение об ошибке
) as
begin
	
	set nocount on
	set @ErrorMes = ''

	begin try
		
		if not exists (select 1 from #productIds) begin
			set @ErrorMes = 'Список товаров пуст!'
			return 1
		end

		if not exists (select 1 from Sites where Id = @SiteId and DataBusSync = 1) begin
			set @ErrorMes = 'Сайт не найден!'
			return 1
		end

		delete sp
		from SITEPRODUCTS sp
			join #productIds p on p.Id = sp.ProductId and sp.SiteId = @SiteId

		return 0
	end try
	begin catch
		set @ErrorMes = ERROR_MESSAGE()
		return 1
	end catch

end
