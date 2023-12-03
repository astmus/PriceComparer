create proc SUZPurchaseTaskClose
(
	@TaskId				int,					-- Идентификатор задания на закупку
	-- Out-параметры
	@ErrorMes			nvarchar(4000) out		-- Сообщение об ошибках
)
as
begin

	set nocount on;
	set @ErrorMes = ''

	begin try
	
		if not exists (select 1 from SUZPurchaseTasks t where t.TaskId = @TaskId)
			return 0

		-- Удаялем из очереди
		delete SUZPurchaseTasks where TaskId = @TaskId

		-- Отмечаем заказ в СУЗ на удаление
		update o
		set
			o.MustBeClosed = 1
		from
			SUZOrders o
				join SUZPurchaseTaskOrders l on o.Id = l.OrderId
		where 
			l.TaskId = @TaskId

		-- Удаляем из связей с заказами СУЗ
		delete SUZPurchaseTaskOrders where TaskId = @TaskId

		return 0

	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

end
