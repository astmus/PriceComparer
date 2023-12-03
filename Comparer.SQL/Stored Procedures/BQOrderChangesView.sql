create proc BQOrderChangesView
(
	@OrderId		uniqueidentifier		-- Идентификатор заказа
)
as
begin
	
	-- 1. Получаем идентификаторы данных
	declare
		@PublicNumber		nvarchar(20),					-- Публичный номер заказа
		@PublicId			int,							-- Публичный номер заказа на сайте
		@OrderCreatedDate	datetime,						-- Дата и время создания заказа
		@StatusId			int,							-- Идентификатор статуса заказа
		@Status				nvarchar(20),					-- Статус заказа

		@SiteId				uniqueidentifier,				-- Идентификатор сайта заказа
		@Site				nvarchar(20),					-- Наименование сайта заказа
		
		@ClientId			uniqueidentifier,				-- Идентификатор клиента
		@ClientTypeId		int,							-- Идентификатор типа клиента
		@ClientType			nvarchar(20),					-- Наименование типа клиента
		
		@DeliveryTypeId		int,							-- Идентификатор типа доставки
		@DeliveryType		nvarchar(255),
		@PaymentTypeId		int,							-- Идентификатор типа оплаты
		@PaymentType		nvarchar(255),

		@Locality			nvarchar(50),					-- Населенный пункт
		
		@ReturnReasonId		int,							-- Идентификатор причины отмены/возврата
		@ReturnReason		nvarchar(50),					-- Название причины отмены/возврата
		@FaultPartyId		int,							-- Идентификатор виновной стороны отмены/возврата	
		@FaultParty			nvarchar(50),					-- Название виновной стороны отмены/возврата

		@Coupon				nvarchar(64),					-- Примененный купон	
		@OrdersCount		int,							-- Число заказов у клиента на момент текущего заказа (не обновляется)
		
		@DeliveryCost		float,							-- Стоимость доставки	
		@FrozenSum			float,							-- Сумма к оплате
		@BonusPaidSum		float,							-- Уплоченная сумма	бонусами
		@PaidSum			float							-- Уплоченная сумма	наличными

	-- Заказ
	select
		@PublicNumber		= co.PublicNumber,	
		@PublicId			= co.PUBLICID,	
		@OrderCreatedDate	= co.[Date],		
		@SiteId				= co.SiteId,		
		@StatusId			= co.[Status],		
		
		@ClientId			= co.CLIENTID,

		@DeliveryTypeId		= co.DELIVERYKIND,
		@PaymentTypeId		= co.PAYMENTKIND,
		@Coupon				= co.COUPONCODE,
		@DeliveryCost		= co.DELIVERY,
		@FrozenSum			= co.FROZENSUM,
		@PaidSum			= co.PAIDSUM
	from CLIENTORDERS co with (nolock)
	where
		co.ID = @OrderId		

		-- Статус
	select @Status = s.NAME from CLIENTORDERSTATUSES s where s.ID = @StatusId
		-- Сайт
	select @Site = s.Name from SITES s with (nolock) where s.Id = @SiteId
		-- Адрес
	select @Locality = iif(a.LOCALITY <> '', a.LOCALITY, iif(a.City <> '', a.City, a.Region)) 
					from CLIENTORDERADDRESSES a with (nolock) where a.CLIENTORDERID = @OrderId
		-- Доставка
	if(@DeliveryTypeId > 0)
		select @DeliveryType = dt.TITLE from DELIVERYTYPES dt with (nolock) where dt.Id = @DeliveryTypeId
	else
		select @DeliveryType ='Без доставки'
		-- Оплата
	if(@PaymentTypeId > 0)
		select @PaymentType = pt.TITLE from PaymentTypes pt with (nolock) where pt.Id = @PaymentTypeId
	else
		select @PaymentType = 'Не определен'
		-- Клиент
	select 
		@ClientTypeId	= c.ClientType,
		@ClientType		= ct.Name 
	from CLIENTS c with (nolock) 
		join ClientTypes ct with (nolock) on c.ClientType = ct.Id
	where 
		c.Id = @ClientId
		-- Причины
	select 
		@ReturnReasonId		= rr.ReasonId,
		@ReturnReason		= isnull(cr.Reason, ''),
		@FaultPartyId		= rr.FaultPartyId,
		@FaultParty			= isnull(fp.Name, '')
	from OrderReturnReasons rr with (nolock) 
		join OrderReturnCommonReasons cr with (nolock) on cr.Id = rr.ReasonId
		left join OrderReturnFaultParties fp with (nolock) on fp.Id = rr.FaultPartyId
	where 
		rr.OrderId = @OrderId

	-- Количество заказов (Рассчет только в первый раз)
	select @OrdersCount = o.OrdersCount from BQOrdersLastData o where o.OrderId = @OrderId
	if (@OrdersCount is null)
		select
			@OrdersCount = count(1)
			from
			(
				select 
					o1.CLIENTID, o1.STATUS, row_number() over (order by o1.DATE desc) as 'RowNo'
				from CLIENTORDERS o1 with (nolock)
				where o1.CLIENTID = @ClientId and o1.ID <> @OrderId and o1.DATE < @OrderCreatedDate -- Смотрим предыдущий к текущему заказ
			) o
			where 
				o.STATUS in (3,5,6,16) 




	-- 2. Вывод данных
	-- 2.1. Заказ
	select  
		-- Заказ общее
		@OrderId					as 'OrderId',
		@PublicNumber				as 'PublicNumber',
		@PublicId					as 'PublicId',
		@OrderCreatedDate			as 'OrderCreatedDate',
		getdate()					as 'OrderChangeDate',
		@StatusId					as 'StatusId',
		@Status						as 'OrderStatus',

		@SiteId						as 'SiteId',
		@Site						as 'Site',
		-- Клиент
		@ClientId					as 'ClientId',
		@ClientTypeId				as 'ClientTypeId',
		@ClientType					as 'ClientType',
		-- Доставка/оплата			
		@DeliveryTypeId				as 'DeliveryTypeId',
		@DeliveryType				as 'DeliveryType',
		@PaymentTypeId				as 'PaymentTypeId',
		@PaymentType				as 'PaymentType',
		
		@Locality					as 'Locality',
		-- Причины
		@ReturnReasonId				as 'ReturnReasonId',
		@ReturnReason				as 'ReturnReason',
		@FaultPartyId				as 'FaultPartyId',
		@FaultParty					as 'FaultParty',

		@Coupon						as 'Coupon',
		@OrdersCount				as 'OrdersCount',
		-- Суммы
		@DeliveryCost				as 'DeliveryCost',	
		@FrozenSum					as 'FrozenSum',	
		null						as 'BonusPaidSum', -- не хранится
		@PaidSum					as 'PaidSum'


	-- 2.2. Позиции
	select  
		@OrderId					as 'OrderId',	
		-- Товар
		i.ProductId					as 'ProductId',
		p.SKU						as 'ProductSKU',
		p.FullName					as 'ProductName',
		-- Бренд
		p.MANID						as 'BrandId',
		m.[Name]					as 'BrandName',
				
		dbo.GetTypeCategoryOfProduct(i.ProductId)
									as 'CategoryName',
		-- Позиция
		i.Quantity					as 'Quantity',
		i.FROZENRETAILPRICEORIGINAL - i.FROZENRETAILPRICE				
									as 'Discount',
		iif(isnull(i.FrozenRetailPriceWithDiscount, 0) > 0, i.FrozenRetailPriceWithDiscount, i.FROZENRETAILPRICE)	
									as 'FrozenPriceWithDiscount'


	from CLIENTORDERSCONTENT i
		join PRODUCTS p with (nolock) on p.ID = i.ProductId
		join MANUFACTURERS m with (nolock) on m.ID = p.ManId
	where
		i.CLIENTORDERID = @OrderId

end
