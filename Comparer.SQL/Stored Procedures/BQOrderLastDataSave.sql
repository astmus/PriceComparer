create proc BQOrderLastDataSave
(
	@OrderId			uniqueidentifier,				-- Идентификатор заказа
	@PublicNumber		nvarchar(20),					-- Публичный номер заказа
	@OrderCreatedDate	datetime,						-- Дата и время создания заказа
	@SiteId				uniqueidentifier,				-- Идентификатор сайта заказа
	@StatusId			int,							-- Идентификатор статуса заказа
	@ClientId			uniqueidentifier,				-- Идентификатор клиента
	@ClientTypeId		int,							-- Идентификатор типа клиента
	@DeliveryTypeId		int,							-- Идентификатор типа доставки
	@PaymentTypeId		int,							-- Идентификатор типа оплаты
	@Locality			nvarchar(50),					-- Населенный пункт
	@ReturnReasonId		int,							-- Идентификатор причины отмены/возврата
	@FaultPartyId		int,							-- Идентификатор виновной стороны отмены/возврата	
	@Coupon				nvarchar(64),					-- Примененный купон	
	@OrdersCount		int,							-- Число заказов у клиента на момент текущего заказа (не обновляется)
	@DeliveryCost		float,							-- Стоимость доставки	
	@FrozenSum			float,							-- Сумма к оплате
	@BonusPaidSum		float,							-- Уплоченная сумма	бонусами
	@PaidSum			float,							-- Уплоченная сумма	полная

	@Message			nvarchar(max),					-- Данные для отправки в BQ
		-- Выходные параметры
	@NewId				int out,						-- Идентификатор созданного BQ заказа
	@ErrorMes			nvarchar(4000) out				-- Сообщение об ошибках
)
as
begin
	
	--1 Подготовка данных
	begin try

	set nocount on

	set @ErrorMes = ''
	set @NewId = -1
	
	declare @trancount int
	select @trancount = @@trancount

	declare @result int = 0
	declare @err nvarchar(255) = ''

		if @trancount = 0
			begin transaction

	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

	-- 2 Выполнение операций
	begin try

			-- Проверяем, есть ли в базе данных уже такой заказ BQ, то редактируем
			if exists (select 1 from BQOrdersLastData where OrderId = @OrderId) begin

				-- Если изменение заказа
			update o
			set
				o.PublicNumber		= @PublicNumber,		
				o.OrderCreatedDate	= @OrderCreatedDate,	
				o.SiteId			= @SiteId,				
				o.StatusId			= @StatusId,			
				o.ClientId			= @ClientId,			
				o.ClientTypeId		= @ClientTypeId,		
				o.DeliveryTypeId	= @DeliveryTypeId,		
				o.PaymentTypeId		= @PaymentTypeId,		
				o.Locality			= @Locality,			
				o.ReturnReasonId	= @ReturnReasonId,		
				o.FaultPartyId		= @FaultPartyId,		
				o.Coupon			= @Coupon,				
				o.OrdersCount		= @OrdersCount,		
				o.DeliveryCost		= @DeliveryCost,	
				o.FrozenSum			= @FrozenSum,			
				o.BonusPaidSum		= @BonusPaidSum,		
				o.PaidSum			= @PaidSum,
				o.ChangedDate		= getdate()

			from BQOrdersLastData	o
			where
				o.OrderId = @OrderId	

			select
				@NewId = o.Id from BQOrdersLastData	o where o.OrderId = @OrderId

				-- Позиции
				-- Удаляем имеющиеся позиции
				delete oi from BQOrderItemsLastData oi where oi.OrderId = @OrderId

				-- Вставляем новые позиции
				insert BQOrderItemsLastData (OrderId, ProductId, 
										BrandId, CategoryName, 
										Quantity, 
										Discount, FrozenPriceWithDiscount)
			select
				@OrderId, i.ProductId,
				i.BrandId, i.CategoryName,
				i.Quantity,
				i.Discount,
				i.FrozenPriceWithDiscount
			from #orderItems i	

			end
			else begin
				
				-- Если создание заказа
				insert BQOrdersLastData (OrderId,	PublicNumber,	OrderCreatedDate,	
										SiteId,	StatusId, ClientId,	ClientTypeId, DeliveryTypeId, PaymentTypeId,	
										Locality, ReturnReasonId, FaultPartyId,	Coupon,	OrdersCount,	
										DeliveryCost, FrozenSum, BonusPaidSum, PaidSum)
				values ( @OrderId, @PublicNumber, @OrderCreatedDate,
							@SiteId, @StatusId, @ClientId, @ClientTypeId, @DeliveryTypeId, @PaymentTypeId,	
							@Locality, @ReturnReasonId, @FaultPartyId, @Coupon, @OrdersCount,	
							@DeliveryCost, @FrozenSum, @BonusPaidSum, @PaidSum
						)

				set @NewId = @@Identity

				-- Позиции
				insert BQOrderItemsLastData (OrderId, ProductId, 
											BrandId, CategoryName, 
											Quantity, 
											Discount, FrozenPriceWithDiscount)
				select
					@OrderId, i.ProductId,
					i.BrandId, i.CategoryName,
					i.Quantity,
					i.Discount,
					i.FrozenPriceWithDiscount
				from #orderItems i

			end
			
		-- Предача в очередь BQ
		insert BQQueue (PublicId, ObjectTypeId, Data)
		values (newid(), 1, @Message)

		-- Удаление из очереди на обработку
		--delete o from BQExportOrders o where o.OrderId = @OrderId
			
		if @trancount = 0
			commit transaction
			return 0

	end try 
	begin catch 
		if @trancount = 0
			rollback transaction
		set @ErrorMes = error_message()
		return 1
	end catch

end
