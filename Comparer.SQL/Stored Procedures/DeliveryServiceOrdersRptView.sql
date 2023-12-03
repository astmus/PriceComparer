create proc [dbo].DeliveryServiceOrdersRptView
(
	@ServiceId			int,						-- Идентификатор ТК
	@StatusId			int,						-- Идентификатор статуса ТК
	@DateFrom			datetime,					-- Дата с
	@DateTo				datetime					-- Дата до
) as
begin

	create table #tempIds(
		InnerId		uniqueidentifier	not null,
		primary key(InnerId)
	)


	insert into #tempIds (InnerId)
	select distinct
		o.ID as 'InnerId'
	from
		ApiDeliveryServiceOrders do
		join CLIENTORDERS o on o.ID = do.InnerId		
		join ORDERSSTATUSHISTORY h on o.ID = h.CLIENTORDER
	where
		(@ServiceId is null			or (@ServiceId is not null			and do.ServiceId = @ServiceId)) and
		(@StatusId is null			or (@StatusId is not null			and h.[STATUS] = @StatusId)) and
		(@DateFrom is null			or (@DateFrom is not null			and cast(h.STATUSDATE as date) >= @DateFrom))
		and (@DateTo is null		or (@DateTo is not null				and cast(h.STATUSDATE as date) < @DateTo))

	
	select
		o.ID			as 'InnerId',
		case when o.PUBLICNUMBER = '' then cast(o.NUMBER as varchar(20)) else o.PUBLICNUMBER end 
						as 'PublicNumber', 
		do.OuterId		as 'OuterId',
		o.FROZENSUM		as 'Sum',
		o.PAIDSUM		as 'PaidSum',
		do.ServiceId	as 'ServiceId',
		ds.Name			as 'ServiceName',
		do.AccountId	as 'AccountId',
		do.CreatedDate	as 'OuterCreatedDate',
		do.StatusId		as 'OuterStatusId',
		isnull(st.Name, '?')
						as 'OuterStatusName',
		o.DATE			as 'InnerCreatedDate',
		o.DISPATCHNUMBER as 'DispatchNumber',
		o.STATUS		as 'InnerStatusId',
		ist.NAME		as 'InnerStatusName',
		o.DELIVERYKIND	as 'DeliveryKindId',
		dt.NAME			as 'DeliveryKindName'
	FROM
		#tempIds t 
		join CLIENTORDERS o on t.InnerId = o.ID
		left join ApiDeliveryServiceOrders do ON t.InnerId = do.InnerId
		left join ApiDeliveryServices ds ON do.ServiceId = ds.Id
		left join ApiDeliveryServiceOrderStatuses st on st.Id = do.StatusId
		left join DELIVERYTYPES dt on dt.ID = o.DELIVERYKIND
		left join CLIENTORDERSTATUSES ist on ist.ID = o.STATUS
	ORDER BY
		o.PublicNumber

end
