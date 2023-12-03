create proc GetOrdersInGroup 
(
	@InnerId	int		-- Внутренний идентификатор заказа
)
as
begin
	
	select
		do.InnerId as 'InnerId',
		do.OuterId as 'OuterId'
	from ApiDeliveryServiceGroups g 
		join ApiDeliveryServiceGroupOrderLinks og on g.Id = og.GroupId 
		join ApiDeliveryServiceOrders do ON og.OrderId = do.InnerId
	where g.Id = @InnerId

end
