create proc DeliveryServiceQueueOrderEdit
(	
	@OrderId			uniqueidentifier,		-- Идентификатор заказа
	@HasAttempt			bit,					-- Была попытка создать заказ в ЛК ТК
	@AttemptError		varchar(4000),			-- Сообщение об ошибке во время попытки создать заказ в ЛК ТК
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
			set @ErrorMes = 'Ошибка во время изменения заказа в очереди! Заказ не существует.'		
			return 1
		end

		-- Если параметры не заданы, выходим из ХП
		if isnull(@HasAttempt,0) = 0 and @AttemptError is null
			return 0

		if @trancount = 0
			begin transaction

		-- Архивируем запись
		insert ApiDeliveryServiceQueueArchive (OrderId, AttemptCount, LastAttemptDate, LastError, AuthorId, CreatedDate, ChangedDate, ArchiveStatus)
		select OrderId, AttemptCount, LastAttemptDate, LastError, AuthorId, CreatedDate, ChangedDate, 2
		from ApiDeliveryServiceQueue
		where OrderId = @OrderId

		-- Обновляем запись
		update ApiDeliveryServiceQueue
		set AttemptCount = case when @HasAttempt = 1 then AttemptCount + 1 else AttemptCount end,
			LastError = case when @AttemptError is null then LastError else @AttemptError end,
			LastAttemptDate = case when @HasAttempt = 1 then getdate() else LastAttemptDate end,
			AuthorId = @AuthorId,
			ChangedDate = getdate()
		where OrderId = @OrderId
		
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
