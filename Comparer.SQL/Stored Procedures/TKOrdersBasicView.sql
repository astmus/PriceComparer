create proc TKOrdersBasicView
(
	@AccountId			int,		-- Идентификатор ТК
	@DateFrom			date,		-- Дата создания заказа с
	@DateTo				date		-- Дата создания заказа до
) as
begin

	create table #tempIds(	
		OrderId		uniqueidentifier	not null,
		primary key(OrderId)
	)

	if @DateTo is Null
		set @DateTo = DateAdd(day, 1, Cast(getdate() as date))


	insert into #tempIds
	select
		dso.InnerId
	from
		ApiDeliveryServiceOrders dso
	where
		dso.AccountId = @AccountId
		AND dso.CreatedDate >= @DateFrom
		AND dso.CreatedDate < @DateTo

	
	select
		o.ID						as 'InnerId',
		IIF(o.PUBLICNUMBER = '', Cast(o.NUMBER as varchar(20)), o.PUBLICNUMBER)
									as 'PublicNumber', 
		dso.DISPATCHNUMBER			as 'DispatchNumber',
		dso.OuterId					as 'OuterId',
		dso.ServiceId				as 'ServiceId',
		dso.AccountId				as 'AccountId', 
		isnull(oi.IKNId, 0)			as 'IknId',           
		isnull(ikns.Name, '')		as 'Ikn',           
		isnull(og.GroupId, '')		as 'GroupId' ,
		isnull(gi.IsSent, 0)		as 'GroupIsSent',
		o.DELIVERYKIND				as 'DeliveryKindId',
		pd.DepartmentId				as 'DepartmentId',
		oi.LabelId					as 'LabelId'
	from
		#tempIds t
		JOIN ApiDeliveryServiceOrders dso			   on t.OrderId = dso.InnerId
		join CLIENTORDERS o							   on o.ID = dso.InnerId
		left join ApiDeliveryServiceOrdersInfo oi	   on oi.InnerId = dso.InnerId
		left join ApiDeliveryServiceGroupOrderLinks og on dso.InnerId = og.OrderId
		left join ApiDeliveryServiceGroupsInfo gi	   on og.GroupId = gi.Id
		left join ApiDeliveryServicesIKNs ikns		   on oi.IKNId = ikns.Id
		left join ClientOrdersPaymentData pd		   on pd.OrderId = o.ID
	order by
		dso.CreatedDate desc

end
