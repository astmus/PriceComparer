create proc DeliveryServicePutOrderToQueue 
(
	@OrderId		uniqueidentifier,		-- Идентификатор заказа
	@AuthorId		uniqueidentifier,		-- Идентификатор автора
	-- Out-параметры
	@ErrorMes		nvarchar(255) out		-- Сообщение об ошибках
) as
begin
	
	set nocount on
	set @ErrorMes = ''

	-- Если заказ уже есть в очереди, выходим из ХП
	if	exists (select 1 from ApiDeliveryServiceQueue where OrderId = @OrderId) or
		exists (select 1 from ApiDeliveryServiceOrders where InnerId = @OrderId)
		return 0

			
	-- Обновление очереди
	begin try

		-- Создаем запись
		insert ApiDeliveryServiceQueue (OrderId, AuthorId) values (@OrderId, @AuthorId)

		return 0
	end try
	begin catch		
		set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры DeliveryServicePutOrderToQueue!'		
		return 1
	end catch

end
