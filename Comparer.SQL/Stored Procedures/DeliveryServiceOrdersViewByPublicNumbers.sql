create proc DeliveryServiceOrdersViewByPublicNumbers 
as
begin 
	select
		o.ID		as 'InnerId',
		do.OuterId	as 'OuterId',
		isnull(cds.DeliveryServiceId, do.ServiceId) as 'ServiceId',
		ds.Name		as 'ServiceName',
		do.AccountId,
		a.Name		as 'AccountName',
		isnull(oi.IKNId,do.IKNId) as 'IKNId',
		ikn.Name	as 'IKNName',
		do.CreatedDate as 'OuterCreatedDate',
		do.StatusId as 'OuterStatusId',
		do.StatusDate as 'OuterStatusDate',
		do.StatusDescription as 'OuterStatusDescription',
		st.Name		as 'OuterStatusName',
		o.DATE		as 'InnerCreatedDate',
		o.WEIGHT	as 'Weight',
		case when o.PUBLICNUMBER = '' then cast(o.NUMBER as varchar(20)) else o.PUBLICNUMBER end as 'PublicNumber', 
		o.DISPATCHNUMBER as 'DispatchNumber',
		o.PACKED	as 'Packed',
		o.STATUS	as 'InnerStatusId',
		ist.NAME	as 'InnerStatusName',
		o.DELIVERYKIND as 'DeliveryKindId',
		dt.NAME		as 'DeliveryKindName',
		o.PAYMENTKIND as 'PaymentKindId',
		IIF(o.paymentkind in (2, 4, 5, 8, 10, 12, 13, 19, 20), cast(1 as bit), cast(0 as bit)) as 'IsPrepaid',
		pt.TITLE	as 'PaymentKindName',
		o.SITEID	as 'SiteId',
		isnull(s.NAME,'') as 'SiteName',
		g.Id		as 'GroupId',
		g.Name		as 'GroupName',
		ISNULL(oi.LabelDowloadCount, 0) AS 'LabelDowloadCount',
		o.PAIDSUM	as 'PaidSum',
		o.FROZENSUM as 'Sum',
		co.REGION	as 'Region',
		co.URBANAREA as 'Area',
		co.DISTRICT as 'District',
		op.ProblemInTK as 'ProblemInTK',
		''			as 'Zip',
		''			as 'Country',
		''			as 'Locality',
		''			as 'City',
		''			as 'Street',
		''			as 'House',
		''			as 'Block',
		''			as 'Flat',
		Cast(0 as bit) as 'PartialReturned',
		''			as 'Comment',
		getdate()	as 'SentDate',
		''			as 'ClientFullName',
		oi.CompensationNumber as 'CompensationNumber',
		oi.CompensationDate	  as 'CompensationDate',
		oi.CompensationSum as 'CompensationSum',
		oi.CompensationFail as 'CompensationFail'
	FROM
		#tmp_PublicNumbers t 
		join CLIENTORDERS o on o.PublicNumber = t.PublicNumber
		left join ApiDeliveryServiceOrders do ON o.Id = do.InnerId
		left join ClientOrdersDelivery cds on cds.orderId = o.Id
		left join ApiDeliveryServices ds ON isnull(cds.DeliveryServiceID, do.ServiceId) = ds.Id
		left join ApiDeliveryServiceOrderStatuses st on st.Id = do.StatusId
		left join DELIVERYTYPES dt on dt.ID = o.DELIVERYKIND
		left join PaymentTypes pt on pt.ID = o.PAYMENTKIND
		left join CLIENTORDERSTATUSES ist on ist.ID = o.STATUS
		left join ApiDeliveryServicesAccounts a on a.Id = do.AccountId
		left join SITES s on s.ID = o.SITEID
		left join ApiDeliveryServiceGroupOrderLinks og on o.ID = og.OrderId
		left join ApiDeliveryServiceGroups g on og.GroupId = g.Id
		left join ApiDeliveryServiceOrdersInfo oi ON do.InnerId = oi.InnerId
		left join CLIENTORDERADDRESSES co on o.ID = co.CLIENTORDERID
		left join ApiDeliveryServicesIKNs ikn on isnull(oi.IKNId,do.IKNId) = ikn.Id
		left join ClientOrdersAdditionalParams op on op.OrderId = o.ID

end
