create proc OrderInfoForTKGetRequest
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
		do.ServiceId					as 'ServiceId',
		isnull(g.OuterId, '')			as 'GroupId',
		ws.ShipmentDate					as 'ShippingDate',
		iif(o.FROZENSUM - o.PAIDSUM = 0,
			cast(1 as bit),
			 cast(0 as bit))			as 'FullyPaid',
		o.SiteId						as 'SiteId'
	from 
		CLIENTORDERS o 
			left join ApiDeliveryServiceOrders do on o.ID = do.InnerId
			left join ApiDeliveryServiceGroupOrderLinks og on do.InnerId = og.OrderId 
			left join ApiDeliveryServiceGroups g on og.GroupId = g.Id
			left join WmsShipmentOrderDocuments ws on ws.PublicId = o.ID
	where o.ID = @InnerId

end
