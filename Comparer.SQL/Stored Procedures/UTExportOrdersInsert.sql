create proc UTExportOrdersInsert 
(
	@EntityId uniqueidentifier
) as
begin

	-- Если заказа с данным идентификатором нет выходим
	if not exists (select 1 from CLIENTORDERS where ID = @EntityId) 
		return 1

	begin try

		insert UTExportOrders (OrderId, Operation, OrderState)
		values(@EntityId, 1, 1)
			
		return 0
	end try 
	begin catch 
		return 1
	end catch 
	
end
