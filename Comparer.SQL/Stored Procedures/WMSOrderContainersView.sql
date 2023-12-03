create proc WMSOrderContainersView
(
	@OrderId		uniqueidentifier		-- Идентификатор заказа
) as
begin

	select 
		c.ContainerNumber		as 'Number',
		c.CellAddress			as 'CellAddress'		
	from
		OrdersWarehouseContainers c
	where
		c.OrderId = @OrderId
	order by
		c.CellAddress, c.ContainerNumber

end
