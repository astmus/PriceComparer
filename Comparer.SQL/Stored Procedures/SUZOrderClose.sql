create proc SUZOrderClose
(
	@OrderId			int,					-- Идентификатор заказа
	-- Out-параметры
	@ErrorMes			nvarchar(4000) out		-- Сообщение об ошибках
)
as
begin

	set nocount on;
	set @ErrorMes = ''

	begin try
	
		-- Если заказ уже закрыт - ничего не делаем
		if exists (select 1 from SuzOrders o where o.Id = @OrderId and o.IsActive = 0)
			return 0

		-- Обновляем статус
		update 
			SUZOrders 
		set
			IsActive		= 0,
			ClosedDate		= getdate()
		where
			Id = @OrderId

		-- Удаялем из очереди
		delete t
		from
			SUZPurchaseTasks t
				join SUZPurchaseTaskOrders l on t.TaskId = l.TaskId
		 where 
			l.OrderId = @OrderId

		-- Удаляем из связей с заказами СУЗ
		delete SUZPurchaseTaskOrders where OrderId = @OrderId

		return 0

	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

end
