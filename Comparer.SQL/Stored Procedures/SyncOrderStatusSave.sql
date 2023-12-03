create proc SyncOrderStatusSave
(		
	-- Основная информация
	@SiteId					uniqueidentifier,			-- Идентификатор сайта
	@PublicId				nvarchar(50),				-- Идентификатор обмена
	@PublicNumber			nvarchar(50),				-- Публичный номер
	@StatusId				int = null,					-- Идентификатор статуса

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

		-- Если заказа с указанным идентификатором обмена не существует
		if @orderId is null 
		begin
			set @ErrorMes = 'В системе нет заказа ' + @PublicNumber + '. Невозможно обновить статус.'
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
			@orderStatus	int,
			@wmsStatus		int,
			@sent			bit

		select 
			@orderStatus = o.STATUS,
			@wmsStatus = 
				case 
					when d.DocStatus is null then 0
					else d.DocStatus
				end,
			@sent = iif(o.STATUS in (9, 12, 13), cast(1 as bit), cast(0 as bit))
		from CLIENTORDERS o with(nolock)
			left join WmsShipmentOrderDocuments d on o.ID = d.PublicId
		where o.ID = @orderId
					
		-- Если заказ в ShopBase находится в терминальном статусе: Получен, Отменен или Возвращен
		-- Возврашаем ошибку обработки
		if @orderStatus in (3,5,6) begin
			set @ErrorMes = 'Заказ ' + @PublicNumber + ' находится в терминальном состоянии!'
			return 1
		end

		-- DEBUG
		-- select @orderStatus, @wmsStatus, @sent	
		-- DEBUG

		-- Если заказ отменяется из внешней системы,
		-- нужно проверить, не отгружен ли заказ в нашей системе (и в WMS соответственно)
		-- и не отправлен ли он
		if @StatusId = 3 begin
			
			-- Если заказ отгружен или отправлен,
			-- выходим без изменений.
			-- В этом случае ожидаем заказ на возврат на приемке
			if @wmsStatus = 10 or @sent = 1
				return 0

			/*
				set @updateEnable = 
					(select iif(DocStatus = 10, 0, 1)
					from WmsShipmentOrderDocuments
					where PublicId = @orderId)

				if(isnull(@updateEnable, 1) = 1)
					select @updateEnable = iif(STATUS in (9, 12, 13), 0, 1)
					from CLIENTORDERS
					where id = @orderId
			
				if(@updateEnable = 0)
				begin
					set @ErrorMes = 'Статус заказа ' + @PublicNumber + ' не может быть изменен'
					return 2
				end
			*/
		end

		-- Если приходят статусы Ожидает оплаты или Создан проверяем, что заказ еще не принят в обработку
		if((@StatusId = 1 or @StatusId = 7) and @orderStatus not in (1,7, 8))
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
			from CLIENTORDERS o
			where o.ID = @orderId

			-- Добавляем запись в историю изменения статусов
			insert ORDERSSTATUSHISTORY(CLIENTORDER, STATUS, STATUSDATE, EMAIL, AUTHOR)			
			values(@orderId, @StatusId, getdate(), null, 'DataBusBot')

		if @trancount = 0
			commit transaction
			
		-- Добавляем действия пользователей			
		insert USERACTIONS (USERID, OBJECTTYPE, ACTIONTYPE, PARAMS)
		select '1C83D780-4658-4363-A70F-59B7639C4366', 9, 2, 
				'OrderID=' + lower(cast(o.ID as varchar(36))) + 
				';Номер заказа=' + case when o.PUBLICNUMBER = '' then cast(o.NUMBER as varchar(10)) else o.PUBLICNUMBER end + 				   
				';Статус=' + case @StatusId 
								when 3 then 'Отменен'
								when 5 then 'Получен клиентом'
								when 9 then 'Отправлен'
								when 1 then 'Создан'
								when 7 then 'Ожидает оплаты'
								else '?'
							end + ';'
		from CLIENTORDERS o with(nolock) where o.ID = @orderId

		return 0

	end try
	begin catch
		if @trancount = 0
			rollback transaction

		set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры SyncOrderStatusSave!'

		declare @err_mes nvarchar(4000)
		select @err_mes = ERROR_MESSAGE()
		
		if len(@err_mes) > 220
			set @ErrorMes = ('SyncOrderStatusSave! ' + substring(@err_mes, 1, 220) + '...')
		else
			set @ErrorMes = ('SyncOrderStatusSave! ' + @err_mes)	
		
		return 1
	end catch
	
end
