create proc SyncOrderUpdateContent
(		
	-- Основная информация
	@SiteId					uniqueidentifier,			-- Идентификатор сайта
	@PublicId				nvarchar(50),				-- Идентификатор обмена
	@PublicNumber			nvarchar(50),				-- Публичный номер
	@DispatchNumber			nvarchar(100) = null,		-- Трек номер

	-- Out-параметры
	@ErrorMes				nvarchar(255) out			-- Сообщение об ошибке
	
) as
begin
	
	set @ErrorMes = ''
	
	declare 
		@orderId	uniqueidentifier,
		@now		datetime = getdate()
		
	begin try

		-- только для СберМегаМаркета
		if (@SiteId <> 'FABE80CF-AC99-4064-8F2E-CFA701C3E59A')
		begin
			set @ErrorMes = 'Доступно только для заказов СберМегаМаркета'
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

		declare
			@productSum					float	  = 0.00,
			@productSumWithDiscount		float	  = 0.00,
			@frozenSum					float	  = 0.00

		select
			@productSum = c.FROZENRETAILPRICE * isnull(i.Quantity, c.QUANTITY)
		from CLIENTORDERSCONTENT c with (nolock)
			left join #tmp_UpdatedItems i on c.CLIENTORDERID = @orderId and c.PRODUCTID = i.ProductId

		select
			@productSumWithDiscount = @productSum + o.Delivery + o.Fee,
			@frozenSum = (iif((@productSum + o.Delivery + o.Fee > 0 and @productSum = 0), (o.Delivery + o.Fee), ( @productSum + o.Delivery + o.Fee) )) - isnull(o.DISCOUNTGIFT, 0)  -- учесть скидку на подарки
		from 
			CLIENTORDERS o with (nolock)
		where 
			o.ID = @orderId

		-- Изменения позиций
		update c
		set
			c.QUANTITY = t.Quantity
		from #tmp_UpdatedItems t
			join CLIENTORDERSCONTENT c with (nolock) on c.CLIENTORDERID = @orderId and t.ProductId = c.PRODUCTID
		where 
			c.CLIENTORDERID = @orderId


		-- Изменения заказа
		update o
		set
			o.FROZENSUM					= @frozenSum,
			o.PRODUKTSUMWITHDISCOUNTS	= @productSumWithDiscount,
			o.CHANGEDATE				= getdate()
		from 
			CLIENTORDERS o
		where 
			o.ID = @orderId

		if @trancount = 0
			commit transaction
		return 0

	end try
	begin catch
		if @trancount = 0
			rollback transaction

		set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры SyncOrderUpdateContent!'

		declare @err_mes nvarchar(4000)
		select @err_mes = error_message()
		
		if len(@err_mes) > 220
			set @ErrorMes = ('SyncOrderUpdateContent! ' + substring(@err_mes, 1, 220) + '...')
		else
			set @ErrorMes = ('SyncOrderUpdateContent! ' + @err_mes)	
		
		return 1
	end catch
	
end
