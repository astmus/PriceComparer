create proc SyncOrderStatusSave_v2
(		
	-- Основная информация
	@SiteId					uniqueidentifier,			-- Идентификатор сайта
	@PublicId				nvarchar(50),				-- Идентификатор обмена
	@PublicNumber			nvarchar(50),				-- Публичный номер
	@StatusId				int = null,					-- Идентификатор статуса
	@DispatchNumber			nvarchar(100) = null,		-- Трек номер

	-- Out-параметры
	@ErrorMes				nvarchar(255) out			-- Сообщение об ошибке
	
) as
begin
	
	set @ErrorMes = ''
	
	declare 
		@orderId	uniqueidentifier,
		@now		datetime = getdate()
		--@status		int = @StatusId
		
	begin try

		-- Если статус не определен
		if @StatusId is null begin
			set @ErrorMes = 'Статус не определен!'
			return 1
		end 

		-- Определяем идентификатор заказа
		select @orderId = o.ID
		from CLIENTORDERS o with(nolock)
			join ClientOrdersSync s on o.ID = s.OrderId and s.PublicId = @PublicId and o.SITEID = @SiteId
			and (@DispatchNumber is null or (@DispatchNumber is not null and o.DISPATCHNUMBER = @DispatchNumber))

		-- Если заказа с указанным идентификатором обмена не существует
		if @orderId is null 
		begin
			set @ErrorMes = 'В системе нет заказа ' + @PublicNumber + ' (' + @DispatchNumber + '). Невозможно обновить статус.'
			return 1
		end 
			
		-- Проверяем разрешено ли обновление
		declare @updateEnable nvarchar(255)

		-- Сайт / Статус заказа / Обновление
		exec @updateEnable = GetSiteObjectSyncSetting @SiteId, 15, 2

		-- Если редактирование статусов запрещено
		if isnull(@updateEnable,'N') = 'N' 
			return 0
			
		-- Получаем статус заказа, статус в WMS и состояние отправки
		declare 
			@orderStatus	int

		select 
			@orderStatus = o.STATUS
		from 
			CLIENTORDERS o with(nolock)
		where 
			o.ID = @orderId
					
		-- Если заказ в ShopBase находится в терминальном статусе: Получен, Отменен, Возвращен или Утерян
		-- Возврашаем ошибку обработки
		if @orderStatus in (3, 5, 6, 16) begin
			set @ErrorMes = 'Заказ ' + @PublicNumber + ' находится в терминальном состоянии!'
			return 0
		end

		-- Если приходят статусы Ожидает оплаты или Создан проверяем, что заказ еще не принят в обработку
		if((@StatusId = 1 or @StatusId = 7) and @orderStatus not in (1, 7, 8))
			return 0
		
	end try
	begin catch
		set @ErrorMes = 'Ошибка во время проверки состояния заказа!'
		return 1
	end catch
			
	declare @trancount int
	select @trancount = @@trancount

	begin try
		
		if @trancount = 0
			begin transaction

		update o
		set
			o.STATUS		= @StatusId,
			o.CHANGEDATE	= getdate()
		from 
			CLIENTORDERS o
		where 
			o.ID = @orderId

		-- Добавляем запись в историю изменения статусов
		insert ORDERSSTATUSHISTORY(CLIENTORDER, STATUS, STATUSDATE, EMAIL, AUTHOR)			
		values(@orderId, @StatusId, getdate(), null, 'ShopBaseUser')
			
		-- Добавляем действия пользователей			
		insert USERACTIONS (USERID, 
							OBJECTTYPE, ObjectId, 
							ACTIONTYPE, 
							PARAMS, 
							ActionInfo)
		select '310FAFF6-9306-44EA-AEA5-44E43C0D5F39', 
				9, lower(cast(o.ID as varchar(36))),
				2, 
				'OrderID=' + lower(cast(o.ID as varchar(36))) + 
				';Номер заказа=' + case when o.PUBLICNUMBER = '' then cast(o.NUMBER as varchar(10)) else o.PUBLICNUMBER end + 				   
				';Статус=' + case @StatusId 
								when 3 then 'Отменен'
								when 5 then 'Получен клиентом'
								when 9 then 'Отправлен'
								when 1 then 'Создан'
								when 7 then 'Ожидает оплаты'
								else '?'
							end + ';',
				null
		from 
			CLIENTORDERS o with(nolock) 
		where 
			o.ID = @orderId

		if @trancount = 0
			commit transaction
		return 0

	end try
	begin catch
		if @trancount = 0
			rollback transaction

		set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры SyncOrderStatusSave_v2!'

		declare @err_mes nvarchar(4000)
		select @err_mes = ERROR_MESSAGE()
		
		if len(@err_mes) > 220
			set @ErrorMes = ('SyncOrderStatusSave_v2! ' + substring(@err_mes, 1, 220) + '...')
		else
			set @ErrorMes = ('SyncOrderStatusSave_v2! ' + @err_mes)	
		
		return 1
	end catch
	
end
