create proc [dbo].[OrdersForTKEditView] as
begin

	select
		o.ID							as 'InnerId',
		o.PublicNumber					as 'PublicNumber',
		do.OuterId						as 'OuterId',
		do.ServiceId					as 'ServiceId',
		do.AccountId					as 'AccountId', 
		isnull(oi.IKNId, 0)				as 'IknId',           
		isnull(og.GroupId, '')			as 'GroupId' ,
		isnull(gi.IsSent, 0)			as 'GroupIsSent' 
	from
		#tkOrders t 
			join ApiDeliveryServiceOrders do on t.InnerId = do.InnerId
			join ApiDeliveryServiceOrdersInfo oi on oi.InnerId = do.InnerId
			join CLIENTORDERS o on o.ID = do.InnerId		      
			left join ApiDeliveryServiceGroupOrderLinks og on do.InnerId = og.OrderId 
			left join ApiDeliveryServiceGroupsInfo gi on og.GroupId = gi.Id
end
