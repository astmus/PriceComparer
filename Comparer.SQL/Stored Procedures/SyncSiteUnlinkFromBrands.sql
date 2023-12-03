create proc SyncSiteUnlinkFromBrands 
(
	@SiteId			uniqueidentifier,			-- Идентификатор заказа
	@NeedSync		bit,						-- Требует синхронизации после связывания
	-- Out-параметры
	@ErrorMes		varchar(4000) out			-- Сообщение об ошибке
) as
begin
	
	set nocount on
	set @ErrorMes = ''

	begin try
		
		if not exists (select 1 from #brandIds) begin
			set @ErrorMes = 'Список брендов пуст!'
			return 1
		end

		if not exists (select 1 from Sites where Id = @SiteId and DataBusSync = 1) begin
			set @ErrorMes = 'Сайт не найден!'
			return 1
		end

		-- Удаляем связь с брендами
		delete sm
		from SITEMANUFACTURERS sm
			join #brandIds b on b.Id = sm.MANUFACTURERID and sm.SITEID = @SiteId

		-- Удаляем связь с товарами
		delete sp
		from #brandIds b
			join PRODUCTS p on p.MANID = b.Id
			join SITEPRODUCTS sp on p.Id = sp.PRODUCTID and sp.SITEID = @SiteId

		return 0
	end try
	begin catch
		set @ErrorMes = ERROR_MESSAGE()
		return 1
	end catch

end
