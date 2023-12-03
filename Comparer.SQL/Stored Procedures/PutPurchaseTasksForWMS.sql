create proc PutPurchaseTasksForWMS as
begin

	-- Вер.2: Добавлены алгоритмы работы с полем "Приоритет"

	set nocount on
	declare @trancount int
	select @trancount = @@TRANCOUNT
	
	begin try

		if @trancount = 0
			begin transaction
	
		-- 1. Проверяем наличие этих заданий в экспортной таблице
		-- Объявляем таблицу, в которую сохраним уже существующие в таблице ExportPurchaseTasks идентификаторы заказов поставщиков
		declare @existsIds table (
			TaskId			uniqueidentifier	not null,				-- Идентификатор заказа поставщику
			Operation		int					not null,				-- Операция
			Primary key (TaskId)
		)
		
		-- "Захватываем" таблицу ExportPurchaseTasks и запоминаем список заказов поставщиков, которые уже есть в таблице
		insert @existsIds (TaskId, Operation)
		select e.TaskId, e.Operation
		from ExportPurchaseTasks e
			join #purchaseTaskIdsForExport t on e.TaskId = t.TaskId

		-- Если в таблице для экспорта уже есть чать заказов поставщиков
		if exists(select 1 from @existsIds) begin
							
			-- Архивируем существующие заказы поставщиков (идентификатор сессии равен нулю: SessionId = 0)
			insert ExportPurchaseTasksSessionItemsArchive (SessionId, Id, TaskId, Operation, ReportDate)
			select 0, i.Id, i.TaskId, i.Operation, i.ReportDate
			from ExportPurchaseTasks i
				join @existsIds e on e.TaskId = i.TaskId
			
			-- Удаляем существующие заказы поставщиков
			delete i 			
			from ExportPurchaseTasks i
				join @existsIds e on e.TaskId = i.TaskId

		end 

		-- 2. Добавляем Задания на закупку
		-- Добавляем Задания на закупку в таблицу "Ожидаемые приемки"
		insert WmsExpectedReceiptDocuments (PublicId, Number, WmsCreateDate, ExpectedDate, DocStatus, 
											DocSource, IsDeleted, Priority, Comments, AuthorId, Operation, CreateDate)
		select t.PublicGuid, ('crm-' + cast(t.CODE as varchar(10))), getdate(), isnull(t.DELIVERYDATE, getdate()), 1,
				1, 0, dbo.PriorityForExpectedReceipt(t.Code), '', '695B7A37-3A07-4CAE-A288-7E1C1D20A23C', 1, t.PURCHASEDATE
		from #purchaseTaskIdsForExport e
			join PurchasesTasks t on t.PublicGuid = e.TaskId 
		where not exists (select 1 from WmsExpectedReceiptDocuments rd where rd.PublicId = e.TaskId)

		-- Добавляем товарные позиции Задания на закупку в таблицу "Товары ожидаемой приемки"
		insert WmsExpectedReceiptDocumentsItems (DocId, TaskId, ProductId, Sku, Quantity, ForOrder, CreateDate)
		select d.Id, t.PublicGuid, p.ID, p.SKU, c.PLANQUANTITY, 
				case t.TASK_TYPE 					
					when 1 then case when c.ItemType = 2 then cast(0 as bit) else cast(1 as bit) end
					else cast(0 as bit)
				end, getdate()
		from #purchaseTaskIdsForExport e 
			join PurchasesTasks t on t.PublicGuid = e.TaskId
			join WmsExpectedReceiptDocuments d on d.PublicId = t.PublicGuid
			join PurchasesTasksContent c on c.CODE = t.CODE and c.ARCHIVE = 0
			join PRODUCTS p on p.SKU = c.SKU
		where not exists (select 1 from WmsExpectedReceiptDocumentsItems i where i.DocId = d.Id and i.TaskId = t.PublicGuid and i.Sku = c.SKU)

		-- Вставляем новые записи в таблицу ExportPurchaseTasks
		insert ExportPurchaseTasks (TaskId, Operation)
		select TaskId, Operation
		from #purchaseTaskIdsForExport
		
		if @trancount = 0
			commit transaction
			
		return 0
	end try 
	begin catch 
		if @trancount = 0
			rollback transaction
		return 1
	end catch 
	
end
