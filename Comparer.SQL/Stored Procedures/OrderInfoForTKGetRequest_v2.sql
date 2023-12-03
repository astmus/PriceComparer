create proc OrderInfoForTKGetRequest_v2
(
	@InnerId			uniqueidentifier				-- Внутренний идентификатор заказа
) as 
begin
	
	select
		o.ID							as 'InnerId',
		iif(o.PUBLICNUMBER = '', 
			cast(o.NUMBER as varchar(10)), 
			o.PUBLICNUMBER) 
										as 'PublicNumber',
		do.OuterId						as 'OuterId',
		cds.DeliveryServiceId					as 'ServiceId',
		isnull(g.OuterId, '')			as 'GroupId',
		ws.ShipmentDate					as 'ShippingDate',
		iif(o.FROZENSUM - o.PAIDSUM = 0,
			cast(1 as bit),
			 cast(0 as bit))			as 'FullyPaid',
		o.SiteId						as 'SiteId',
		pd.DepartmentId					as 'DepartmentId',
		o.PaymentKind					as 'PaymentKindId',
		do.AccountId					as 'AccountId'
	from 
		CLIENTORDERS o 
			left join ClientOrdersDelivery cds on cds.orderId = o.Id
			left join ApiDeliveryServiceOrders do on o.ID = do.InnerId
			left join ApiDeliveryServiceGroupOrderLinks og on do.InnerId = og.OrderId 
			left join ApiDeliveryServiceGroups g on og.GroupId = g.Id
			left join WmsShipmentOrderDocuments ws on ws.PublicId = o.ID
			left join ClientOrdersPaymentData pd		   on pd.OrderId = o.ID
	where o.ID = @InnerId

end
