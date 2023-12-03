create proc SetWmsExpectedReceiptDocumentStatus_v3
(	
	@WarehouseId		int,					-- Идентификатор склада
	@PublicId			uniqueidentifier,		-- Идентификатор документа в WMS	
	@DocStatus			int,					-- Статус документа
	@AuthorId			uniqueidentifier,		-- Идентификатор автора
	-- Выходные параметры
	@ErrorMes			nvarchar(4000) out		-- Сообщение об ошибках
) as
begin

	set @ErrorMes = ''
	set nocount on

	declare @trancount int
	select @trancount = @@trancount

	declare @result int = 0
	declare @err nvarchar(255) = ''

	-- Проверяем наличие документа в базе данных
	if not exists (select 1 from WmsExpectedReceiptDocuments where PublicId = @PublicId) begin
		set @ErrorMes = 'Ошибка во время изменения статуса документа "Ожидаемая приемка"! Документ с указанным идентификатором (' +
			cast(@PublicId as char(36)) + ') отсутствует в базе данных.'			
		return 0
	end

	begin try 
		
		if @trancount = 0
			begin transaction
					
		-- Получаем текущий статус документа
		declare @oldStatus int 
		set @oldStatus = (select DocStatus from WmsExpectedReceiptDocuments where PublicId = @PublicId and WarehouseId = @WarehouseId)

		-- Архивируем текущую запись документа
		insert WmsExpectedReceiptDocumentsArchive(Id, WarehouseId, PublicId, Number, CreateDate, WmsCreateDate, ExpectedDate, DocStatus, DocSource, IsDeleted, AuthorId, Comments, Operation, ReportDate)
		select Id, WarehouseId, PublicId, Number, CreateDate, WmsCreateDate, ExpectedDate, DocStatus, DocSource, IsDeleted, AuthorId, Comments, Operation, ReportDate
		from WmsExpectedReceiptDocuments 
		where 
			PublicId = @PublicId
			and WarehouseId = @WarehouseId
					
		-- Обновляем текущую запись с новым статусом
		update d
		set 
			d.DocStatus		= @DocStatus, 
			d.ReportDate	= getdate()
		from WmsExpectedReceiptDocuments d
		where 
			d.PublicId = @PublicId
			and d.WarehouseId = @WarehouseId

		-- Генерируем событие в очередь DataLoader
		declare @ActionObj varchar(255) = '{"PublicId":"' + cast(@PublicId as varchar(36)) +'","StatusId":' + cast(@DocStatus as varchar(2)) +' }'
		exec ActionsProcessingQueuePut @PublicId, 2, 802, @ActionObj, 2, @AuthorId 

		-- Выполняем закрытие Задания на закупку
		-- Проверяем, есть ли такое задание в базе данных
		if not exists (select 1 from PurchasesTasks where PublicGuid = @PublicId) begin
			set @ErrorMes = 'Ошибка во время изменения статуса документа "Ожидаемая приемка"! Задание на закупку с указанным идентификатором отсутствует в базе данных или уже закрыто и перемещено в архив.'
			if @trancount = 0
				commit transaction
			return 0
		end

		-- Если статус документа "Принята" или "Размещена" и документ еще не был в этих статусах
		if (@DocStatus = 4 or @DocStatus = 6) and @oldStatus <> 4 and @oldStatus <> 6 begin
		
			-- Получаем номер задания на закупку
			declare @code int = (select CODE from PurchasesTasks where PublicGuid = @PublicId)

			-- Закрываем Задание на закупку
			exec @result = ClosePurchaseTaskFromWms @code, @AuthorId, @err out
			-- Если "перерезервирование" закончилось неудачей, делаем rollback транзакции
			if @result = 1 begin
				if @trancount = 0
					rollback transaction
				set @ErrorMes = @err
				return 1
			end								
		end

		if @trancount = 0
			commit transaction
		return 0

	end try 
	begin catch 
		if @trancount = 0
			rollback transaction
		set @ErrorMes = error_message()
		return 1
	end catch

end
