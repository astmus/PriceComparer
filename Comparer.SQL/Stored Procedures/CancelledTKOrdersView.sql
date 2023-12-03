create proc CancelledTKOrdersView 
	(
		@InnerId uniqueidentifier  -- Внутренний  идентификатор заказа
	)
as
begin

	select
		o.ID							as 'InnerId',
		case when o.PUBLICNUMBER = '' 
			then cast(o.NUMBER as varchar(20)) 
			else o.PUBLICNUMBER end		as 'PublicNumber', 
		do.DISPATCHNUMBER				as 'DispatchNumber',
		do.OuterId						as 'OuterId',
		do.ServiceId					as 'ServiceId',
		do.AccountId					as 'AccountId', 
		isnull(oi.IKNId, 0)				as 'IknId',           
		isnull(ikns.Name, '')			as 'Ikn',           
		isnull(og.GroupId, '')			as 'GroupId' ,
		isnull(gi.IsSent, 0)			as 'GroupIsSent',
		o.DELIVERYKIND					as 'DeliveryKindId',
		pd.DepartmentId					as 'DepartmentId',
		oi.LabelId						as 'LabelId'
	from
		ApiDeliveryServiceOrdersArchive do		
			join CLIENTORDERS o							   on o.ID = do.InnerId		      
			left join ApiDeliveryServiceOrdersInfo oi	   on oi.InnerId = do.InnerId
			left join ApiDeliveryServiceGroupOrderLinks og on do.InnerId = og.OrderId 
			left join ApiDeliveryServiceGroupsInfo gi	   on og.GroupId = gi.Id
			left join ApiDeliveryServicesIKNs ikns		   on  oi.IKNId = ikns.Id
			left join ClientOrdersPaymentData pd		   on pd.OrderId = o.ID
	where 
		(@InnerId  is null or (@InnerId is not null and do.InnerId = @InnerId ))
		and do.StatusId = 6 
	
	order by do.ArchiveDate desc

	return 0
end
