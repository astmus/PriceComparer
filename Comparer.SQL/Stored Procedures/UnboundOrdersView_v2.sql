create proc UnboundOrdersView_v2
(
	@ServiceId		int,			-- Идентификатор сервиса доставки
	@ShippedDate	date			-- Дата отгрузки заказа
) as
begin

	declare
		@DopShippedDate date = cast(dateadd(month, -1, getdate()) as date)

	select
		o.ID				as 'OrderId',
		o.PUBLICNUMBER		as 'OrderNumber', 
		o.[STATUS]			as 'StatusId',
		o.DELIVERYKIND		as 'DeliveryKindId',
		w.WmsCreateDate		as 'ShippedDate'
	from
		CLIENTORDERS o 
		join ClientOrdersDelivery d on d.OrderId = o.ID
		join WmsShipmentDocuments w on o.ID = w.PublicId
		left join ApiDeliveryServiceOrders dso on o.ID = dso.InnerId
	where
		o.[STATUS] in (9, 12, 13, 15)
		and isnull(o.DISPATCHNUMBER, '') = ''
		and w.DocStatus = 10
		and dso.OuterId is null
		and d.DeliveryServiceId = @ServiceId
		and (
			(@ShippedDate is not null and cast(w.WmsCreateDate as date) = @ShippedDate) 
			or
			(@ShippedDate is null and cast(w.WmsCreateDate as date) > @DopShippedDate) 
		)
		and o.DATE > '01/01/2022'
	order by
		w.WmsCreateDate, o.PUBLICNUMBER

end
