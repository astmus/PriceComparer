create proc SuzPurchaseTaskOrderLinksCreate
(
	-- Out-параметры
	@ErrorMes		nvarchar(4000) out		-- Сообщение об ошибках
)
as
begin

	set nocount on;

	set @ErrorMes = ''

	
	begin try

		insert SUZPurchaseTaskOrders (TaskId, OrderId)
		select 
			l.TaskId, l.OrderId
		from 
			#Links l
			left join SUZPurchaseTaskOrders e on e.TaskId = l.TaskId and e.OrderId = l.OrderId
		where
			e.TaskId is null

		return 0

	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

end
