create proc DeliveryServiceQueueOrderDelete
(	
	@OrderId			uniqueidentifier,		-- Идентификатор заказа
	@AuthorId			uniqueidentifier,		-- Идентификатор автора
	-- Out-параметры
	@ErrorMes			nvarchar(255) out		-- Сообщение об ошибках
) as
begin
	
	set nocount on
	set @ErrorMes = ''

	declare @trancount int
	select @trancount = @@TRANCOUNT

	-- Обновление очереди
	begin try

		-- Проверяем, существует ли заказ в очереди
		if not exists (select 1 from ApiDeliveryServiceQueue q where q.OrderId = @OrderId) begin
			set @ErrorMes = 'Ошибка во время удаления заказа из очереди! Заказ не существует.'		
			return 1
		end
				
		if @trancount = 0
			begin transaction

		-- Архивируем запись
		insert ApiDeliveryServiceQueueArchive (OrderId, AttemptCount, LastAttemptDate, LastError, AuthorId, CreatedDate, ChangedDate, ArchiveStatus)
		select OrderId, AttemptCount, LastAttemptDate, LastError, AuthorId, CreatedDate, ChangedDate, 2
		from ApiDeliveryServiceQueue
		where OrderId = @OrderId
				
		-- Архивируем запись с отметкой "Удалена"
		insert ApiDeliveryServiceQueueArchive (OrderId, AttemptCount, LastAttemptDate, LastError, AuthorId, CreatedDate, ChangedDate, ArchiveStatus)
		select OrderId, AttemptCount, LastAttemptDate, LastError, @AuthorId, CreatedDate, getdate(), 3
		from ApiDeliveryServiceQueue
		where OrderId = @OrderId

		-- Удаляем запись
		delete ApiDeliveryServiceQueue where OrderId = @OrderId
		
		if @trancount = 0
			commit transaction
		return 0
	end try
	begin catch
		if @trancount = 0
			rollback transaction
		set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры DeliveryServiceEditQueueOrder!'		
		return 1
	end catch
	
end
