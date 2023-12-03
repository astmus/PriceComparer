create proc DeliveryServiceQueueView
(	
	@OrderId			uniqueidentifier,	-- Идентификатор заказа
	@OrderNumber		varchar(20),		-- Публичный номер заказа
	@ServiceId			int,				-- Идентификатор ТК	
	@HasError			bit					-- С ошибками
) as
begin
	
	-- Если задан идентификатор заказа
	if @OrderId is not null begin

		select	o.ID as 'OrderId', o.PUBLICNUMBER as 'PublicNumber',
				o.FROZENSUM as 'Sum', o.PAIDSUM as 'PaidSum', o.WEIGHT as 'Weight',
				q.AttemptCount as 'AttemptCount', q.LastAttemptDate as 'LastAttemptDate', q.LastError as 'LastError', 
				q.CreatedDate as 'QueueCreatedDate', 
				isnull(ds.Id, 0) as 'DeliveryServiceId', isnull(ds.Name,'?') as 'DeliveryServiceName',
				cast(o.STATUS as int) as 'OrderStatusId', st.NAME as 'OrderStatusName',
				o.DELIVERYKIND as 'DeliveryKindId', dt.NAME as 'DeliveryKindName',
				o.PAYMENTKIND as 'PaymentKindId', pt.TITLE as 'PaymentKindName',
				isnull(o.SITEID,'00000000-0000-0000-0000-000000000000') as 'SiteId', isnull(s.NAME,'?') as 'SiteName'
		from ApiDeliveryServiceQueue q
			join CLIENTORDERS o on q.OrderId = o.ID and o.ID = @OrderId
			join DELIVERYTYPES dt on dt.ID = o.DELIVERYKIND
			join PaymentTypes pt on pt.ID = o.PAYMENTKIND
			join CLIENTORDERSTATUSES st on st.ID = o.STATUS
			left join SITES s on s.ID = o.SITEID
			left join ApiDeliveryServicesCastOrderDeliveryKinds dsk on dsk.DeliveryKindId = o.DELIVERYKIND
			left join ApiDeliveryServices ds on ds.Id = dsk.ServiceId

	end else
	-- Если задан публичный номер заказа
	if @OrderNumber is not null begin

		select	o.ID as 'OrderId', o.PUBLICNUMBER as 'PublicNumber',
				o.FROZENSUM as 'Sum', o.PAIDSUM as 'PaidSum', o.WEIGHT as 'Weight',
				q.AttemptCount as 'AttemptCount', q.LastAttemptDate as 'LastAttemptDate', q.LastError as 'LastError', 
				q.CreatedDate as 'QueueCreatedDate', 
				isnull(ds.Id, 0) as 'DeliveryServiceId', isnull(ds.Name,'?') as 'DeliveryServiceName',
				cast(o.STATUS as int) as 'OrderStatusId', st.NAME as 'OrderStatusName',
				o.DELIVERYKIND as 'DeliveryKindId', dt.NAME as 'DeliveryKindName',
				o.PAYMENTKIND as 'PaymentKindId', pt.TITLE as 'PaymentKindName',
				isnull(o.SITEID,'00000000-0000-0000-0000-000000000000') as 'SiteId', isnull(s.NAME,'?') as 'SiteName'
		from ApiDeliveryServiceQueue q
			join CLIENTORDERS o on q.OrderId = o.ID and o.PUBLICNUMBER = @OrderNumber
			join DELIVERYTYPES dt on dt.ID = o.DELIVERYKIND
			join PaymentTypes pt on pt.ID = o.PAYMENTKIND
			join CLIENTORDERSTATUSES st on st.ID = o.STATUS
			left join SITES s on s.ID = o.SITEID
			left join ApiDeliveryServicesCastOrderDeliveryKinds dsk on dsk.DeliveryKindId = o.DELIVERYKIND
			left join ApiDeliveryServices ds on ds.Id = dsk.ServiceId

	end else begin

		select	o.ID as 'OrderId', o.PUBLICNUMBER as 'PublicNumber',
				o.FROZENSUM as 'Sum', o.PAIDSUM as 'PaidSum', o.WEIGHT as 'Weight',
				q.AttemptCount as 'AttemptCount', q.LastAttemptDate as 'LastAttemptDate', q.LastError as 'LastError', 
				q.CreatedDate as 'QueueCreatedDate', 
				isnull(ds.Id, 0) as 'DeliveryServiceId', isnull(ds.Name,'?') as 'DeliveryServiceName',
				cast(o.STATUS as int) as 'OrderStatusId', st.NAME as 'OrderStatusName',
				o.DELIVERYKIND as 'DeliveryKindId', dt.NAME as 'DeliveryKindName',
				o.PAYMENTKIND as 'PaymentKindId', pt.TITLE as 'PaymentKindName',
				isnull(o.SITEID,'00000000-0000-0000-0000-000000000000') as 'SiteId', isnull(s.NAME,'?') as 'SiteName'
		from ApiDeliveryServiceQueue q
			join CLIENTORDERS o on q.OrderId = o.ID
			join ApiDeliveryServicesCastOrderDeliveryKinds c on c.DeliveryKindId = o.DELIVERYKIND
			join DELIVERYTYPES dt on dt.ID = o.DELIVERYKIND
			join PaymentTypes pt on pt.ID = o.PAYMENTKIND
			join CLIENTORDERSTATUSES st on st.ID = o.STATUS
			left join SITES s on s.ID = o.SITEID
			left join ApiDeliveryServicesCastOrderDeliveryKinds dsk on dsk.DeliveryKindId = o.DELIVERYKIND
			left join ApiDeliveryServices ds on ds.Id = dsk.ServiceId
		where	(@ServiceId is null or (@ServiceId	is not null and c.ServiceId = @ServiceId))	and
				(@HasError	is null or (@HasError	is not null and ( (@HasError = 1 and q.LastError is not null)  or (@HasError = 0 and q.LastError is null))))
		order by q.CreatedDate desc

	end
	
end
