create proc BQOrdersHistoryStateView
as
begin
	
	-- Таблица для сохранения исторических записей заказов
	create table #OrdersHistory
	(
		OrderId				uniqueidentifier		not null,
		PublicNumber		nvarchar(20),								-- Публичный номер заказа
		PublicId			int,										-- Публичный номер заказа на сайте
		OrderCreatedDate	datetime				not null,			-- Дата и время создания заказа
		OrderChangeDate		datetime				not null,			-- Дата и время последнего изменения заказа
		StatusId			int						not null,			-- Идентификатор статуса заказа
		OrderStatus			nvarchar(20)			not null,			-- Статус заказа
		SiteId				uniqueidentifier,							-- Идентификатор сайта заказа
		[Site]				nvarchar(20),								-- Наименование сайта заказа
		
		ClientId			uniqueidentifier		not null,			-- Идентификатор клиента
		ClientTypeId		int						not null,			-- Идентификатор типа клиента
		ClientType			nvarchar(20),								-- Наименование типа клиента
		
		DeliveryTypeId		int						not null,			-- Идентификатор типа доставки
		DeliveryType		nvarchar(255),
		PaymentTypeId		int						not null,			-- Идентификатор типа оплаты
		PaymentType			nvarchar(255),

		Locality			nvarchar(255)			not null,			-- Населенный пункт
		
		ReturnReasonId		int,										-- Идентификатор причины отмены/возврата
		ReturnReason		nvarchar(150),								-- Название причины отмены/возврата
		FaultPartyId		int,										-- Идентификатор виновной стороны отмены/возврата	
		FaultParty			nvarchar(150),								-- Название виновной стороны отмены/возврата

		Coupon				nvarchar(150)			not null,			-- Примененный купон	
		OrdersCount			int						not null default(0),-- Число заказов у клиента на момент текущего заказа (не обновляется)
		
		DeliveryCost		float					not null,			-- Стоимость доставки	
		FrozenSum			float					not null,			-- Сумма к оплате
		BonusPaidSum		float,										-- Уплоченная сумма	бонусами
		PaidSum				float					not null			-- Уплоченная сумма	наличными
		primary key(OrderId)
	)
	
	insert #OrdersHistory (
						OrderId, PublicNumber, PublicId,
						OrderCreatedDate, OrderChangeDate,
						StatusId, OrderStatus, SiteId, [Site],	
						ClientId, ClientTypeId, ClientType,
						DeliveryTypeId, DeliveryType, 
						PaymentTypeId, PaymentType,
						Locality,
						ReturnReasonId, ReturnReason, FaultPartyId, FaultParty,
						Coupon, OrdersCount,
						DeliveryCost, FrozenSum, BonusPaidSum, PaidSum
						)
						
	select
		co.Id, co.PublicNumber,	co.PUBLICID,	
		co.[Date], co.Changedate,		
		 co.[Status], s.[NAME], co.SiteId, si.[NAME],
		co.CLIENTID, c.ClientType, ct.[Name], 
		co.DELIVERYKIND, iif(co.DELIVERYKIND > 0, dt.TITLE, 'Без доставки'),
		co.PAYMENTKIND, iif(co.PAYMENTKIND > 0, pt.TITLE, 'Не определен'),
		iif(a.LOCALITY <> '', a.LOCALITY, iif(a.City <> '', a.City, a.Region)),
		rr.ReasonId, isnull(cr.Reason, ''), rr.FaultPartyId, isnull(fp.[Name], ''),
		co.COUPONCODE, 0,
		co.DELIVERY, co.FROZENSUM, null, co.PAIDSUM

	from #orderIds ord
		left join CLIENTORDERS co with (nolock) on co.ID = ord.Id
		left join CLIENTORDERSTATUSES s with (nolock) on s.ID = co.[Status]
		left join SITES si with (nolock) on si.Id = co.SiteId
		left join CLIENTORDERADDRESSES a with (nolock) on a.CLIENTORDERID = co.ID
		left join DELIVERYTYPES dt with (nolock) on dt.Id = co.DELIVERYKIND
		left join PaymentTypes pt with (nolock) on pt.Id = co.PAYMENTKIND
		left join CLIENTS c with (nolock)  on c.ID = co.CLIENTID
		left join ClientTypes ct with (nolock) on c.ClientType = ct.Id
		left join OrderReturnReasons rr with (nolock) on rr.OrderId = co.ID
		left join OrderReturnCommonReasons cr with (nolock) on cr.Id = rr.ReasonId
		left join OrderReturnFaultParties fp with (nolock) on fp.Id = rr.FaultPartyId
	where
		co.SITEID is not null


	--- Таблица идентификаторов исторических терминальных заказов по отношению к заказам  из #OrdersHistory
	create table #OrdersHistoryCount
	(
		OrderId				uniqueidentifier		not null,
		ClientId			uniqueidentifier		not null,
		[Date]				datetime				not null
		primary key (OrderId)
	)

	declare @serchDate		date

	set @serchDate = DateAdd(day, 1,(select top 1 oh.OrderChangeDate from #OrdersHistory oh))

	
	insert #OrdersHistoryCount
		(OrderId, ClientId, [Date])
	select 
		o.ID, o.CLIENTID, o.[Date]
	from 
		(select distinct oh.CLIENTID
		 from
			#OrdersHistory oh
		) cl
		left join CLIENTORDERS o with (nolock) on o.CLIENTID = cl.ClientId
				and o.DATE < @serchDate
				and o.STATUS in (3,4,5,6,16)
	where o.ID is not null

			
	update oh
	set oh.OrdersCount = 
	(
		select 
			count(*)
		from 
			#OrdersHistoryCount ohc
		where 
			ohc.ClientId = oh.ClientId and
			ohc.Date < oh.OrderCreatedDate
	)
	from
		#OrdersHistory oh 



	--update oh
	--set oh.OrdersCount = hc.PreviousOrdersCount + 1
	--select
	--	hc.*
	--from(
	--		select
	--			ohc.ClientId,
	--			ohc2.OrderId,
	--			count(ohc.ClientId)	as 'PreviousOrdersCount'
	--			--row_number() over (partition by ohc.ClientId, ohc.Date )
	--		from #OrdersHistoryCount ohc2 
	--			left join #OrdersHistoryCount ohc on ohc.ClientId = ohc2.ClientId and ohc.Date < ohc2.Date
	--		group by 
	--			ohc.ClientId, ohc2.OrderId
	--	)hc 
	--	left join #OrdersHistory oh on oh.OrderId = hc.OrderId and oh.ClientId = hc.ClientId



	-- 2. Вывод данных
	-- 2.1. Заказ
	select *
	from
		#OrdersHistory oh

	-- 2.2. Позиции
	select  
		ord.Id						as 'OrderId',
		c.PUBLICNUMBER				as 'PublicNumber',
		c.[DATE]					as 'OrderCreatedDate',
		c.CHANGEDATE				as 'OrderChangeDate',
		c.SITEID					as 'SiteId',
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


	from #orderIds ord
		join CLIENTORDERS c on c.ID = ord.Id
		join CLIENTORDERSCONTENT i on i.CLIENTORDERID = ord.Id
		join PRODUCTS p with (nolock) on p.ID = i.ProductId
		join MANUFACTURERS m with (nolock) on m.ID = p.ManId

end
