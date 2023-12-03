create proc SUZPurchaseTaskOrdersView
(
	@TaskId				int,			-- Идентификатор задания на закупку
	@OrderId			int				-- Идентификатор заказа СУЗ
)
as
begin
	
	select 
		-- Задание
		t.TaskId			as 'TaskId',
		t.ExpectedDate		as 'TaskExpectedDate',
		-- Заказ
		o.Id				as 'OrderId',
		o.IsActive			as 'OrderIsActive',
		o.StatusId			as 'OrderStatusId'
	from 
		SUZPurchaseTasks t
			join SUZPurchaseTaskOrders l on l.TaskId = t.TaskId
			join SUZOrders o on o.Id = l.OrderId
	where 
		(@TaskId is null or (@TaskId is not null and l.TaskId = @TaskId))			and		
		(@OrderID is null or (@OrderID is not null and l.OrderId = @OrderID))		
	order by
		o.ClosedDate

end
