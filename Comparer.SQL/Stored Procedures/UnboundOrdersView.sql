create proc UnboundOrdersView 
(
	@ServiceId		int				-- Идентификатор сервиса доставки
) as
begin

	select
		o.ID				as 'OrderId',
		o.PUBLICNUMBER		as 'PUBLICNUMBER', 
		o.ExpectedDate		as 'ExpectedDate', 
		o.DELIVERYKIND		as 'DK',
		o.[STATUS]			as 'STATUS',
		dso.OuterId			as 'OuterId'
	from
		CLIENTORDERS o 
		join ClientOrdersDelivery d on d.OrderId = o.ID
		join WmsShipmentDocuments w on o.ID = w.PublicId
		left join ApiDeliveryServiceOrders dso on o.ID = dso.InnerId
	where
		o.[STATUS] not in (3, 5, 6, 16)
		and w.DocStatus = 10
		and dso.OuterId is null
		and d.DeliveryServiceId = @ServiceId
		--AND o.ExpectedDate = '4/08/2022'	-- DEV
	order by
		o.ExpectedDate, o.PUBLICNUMBER

end
