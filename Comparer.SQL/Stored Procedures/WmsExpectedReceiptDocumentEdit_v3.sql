create proc WmsExpectedReceiptDocumentEdit_v3 
(
	@Operation			int,					-- Операция: 1 - создание, 2 - корректировка, 3 - удаление
	@WarehouseId		int,					-- Идентификатор склада
	@PublicId			uniqueidentifier,		-- Идентификатор документа в WMS
	@Number				varchar(32),			-- Номер документа
	@DocSource			int,					-- Источник поступления: 
												-- 1 - Приемка от поставщиков, 
												-- 2 - Приемка возвратов от клиентов
												-- 3 - Перемещение из оптовой точки,
												-- 4 - Приемка парфюмерных пробников в зоне розлива
												-- 5 - Др.
	@DocStatus			int,					-- Статус документа:
												-- 1 - Новая
												-- 2 - К выполнению
												-- 3 - В работе
												-- 4 - Принята
												-- 5 - Заблокирована
												-- 6 - Размешена
	@WmsCreateDate		datetime,				-- Дата создание/корректировки/удаления документа
	@ExpectedDate		date,					-- Дата ожидаемого поступления товара
	@IsDeleted			bit,					-- Пометка на удаление
	@SourceDocumentId	uniqueidentifier,		-- Источник 
	@Comments			nvarchar(1024),			-- Колмментарий	
	@AuthorId			uniqueidentifier,		-- Идентификатор автора
	-- Выходные параметры
	@ErrorMes			nvarchar(4000) out		-- Сообщение об ошибках
) as
begin

	-- 20.12.2021
	-- Добавлено поле @SourceDocumentId
	
	set @ErrorMes = ''
	set nocount on

	declare 
		@result			int				= 0,
		@newDocId		bigint			= 0,
		@oldDocId		bigint			= 0,
		@err			nvarchar(4000)	= ''

	declare @trancount int
	select @trancount = @@trancount

	begin try 
	
		if @trancount = 0
			begin transaction

		-- Если создание документа
		if @Operation = 1 begin
	
			-- Если требуется удалить ранее созданный документ
			if @IsDeleted = 1 begin

				-- Удаляем указанный документ
				exec @result = WmsExpectedReceiptDocumentEdit_v3 3, @WarehouseId, @PublicId, @Number, @DocSource, @DocStatus, 
																	@WmsCreateDate, @ExpectedDate, @IsDeleted, @SourceDocumentId, @Comments, 
																	@AuthorId, @err out
				-- Если корректировка закончилась неудачей, делаем rollback транзакции
				if @result = 1 begin
					if @trancount = 0
						rollback transaction
					set @ErrorMes = @err
					return 1
				end else begin
					if @trancount = 0
						commit transaction
					return 0
				end
				
			end else

			-- Проверяем, есть ли в базе данных уже такой документ
			if exists (select 1 from WmsExpectedReceiptDocuments where PublicId = @PublicId) begin

				-- Выполняем корректировку остатков по соответствующим товарным позициям				
				exec @result = WmsExpectedReceiptDocumentEdit_v3 2, @WarehouseId, @PublicId, @Number, @DocSource, @DocStatus, 
																	@WmsCreateDate, @ExpectedDate, @IsDeleted, @SourceDocumentId, @Comments, 
																	@AuthorId, @err out
				-- Если корректировка закончилась неудачей, делаем rollback транзакции
				if @result = 1 begin
					if @trancount = 0
						rollback transaction
					set @ErrorMes = @err
					return 1
				end else begin
					if @trancount = 0
						commit transaction
					return 0
				end

			end

			-- Вставляем запись в таблицу Документов
			insert WmsExpectedReceiptDocuments (WarehouseId, PublicId, Number, WmsCreateDate, ExpectedDate, DocStatus, DocSource, IsDeleted, SourceDocumentId, Comments, Operation, AuthorId)	
			values(@WarehouseId, @PublicId, @Number, @WmsCreateDate, @ExpectedDate, @DocStatus, @DocSource, @IsDeleted, @SourceDocumentId, @Comments, @Operation, @AuthorId)

			set @newDocId = @@Identity

			-- Если таблица ожидаемого товара не пуста
			if exists (select 1 from #wmsExpectedReceiptDocumentItems) begin

				-- Создаем записи в таблице Товары по документу
				insert WmsExpectedReceiptDocumentsItems (DocId, TaskId, ProductId, Sku, Quantity, Price, ForOrder)
				select @newDocId, i.TaskId, i.ProductId, p.Sku, i.Quantity, i.Price, i.ForOrder
				from #wmsExpectedReceiptDocumentItems i
					join PRODUCTS p on p.ID = i.ProductId
				
			end

		end else

		-- Если изменение документа
		if @Operation = 2 begin

			select @oldDocId = Id from WmsExpectedReceiptDocuments where WarehouseId = @WarehouseId and PublicId = @PublicId
	
			-- Архивируем устаревший Документ
			insert WmsExpectedReceiptDocumentsArchive (Id, WarehouseId, PublicId, Number, WmsCreateDate, ExpectedDate, DocStatus, DocSource, IsDeleted, Comments, AuthorId, Operation, CreateDate, ReportDate)	
			select Id, WarehouseId, PublicId, Number, WmsCreateDate, ExpectedDate, DocStatus, DocSource, IsDeleted, Comments, AuthorId, Operation, CreateDate, ReportDate
			from WmsExpectedReceiptDocuments 
			where Id = @oldDocId

			-- Архивируем Товарные позиции по устаревшему Документу
			insert WmsExpectedReceiptDocumentsItemsArchive (Id, DocId, TaskId, ProductId, Sku, Quantity, ForOrder, CreateDate)
			select Id, DocId, TaskId, ProductId, Sku, Quantity, ForOrder, CreateDate
			from WmsExpectedReceiptDocumentsItems 
			where DocId = @olddocId
			-- Удаляем Товарные позиции по устаревшему Документу
			delete WmsExpectedReceiptDocumentsItems where DocId = @olddocId
			
			-- Обновляем текущий Документ
			update WmsExpectedReceiptDocuments
			set 
				Number				= @Number,
				WmsCreateDate		= @WmsCreateDate,
				ExpectedDate		= @ExpectedDate,
				DocStatus			= @DocStatus,
				DocSource			= @DocSource,
				IsDeleted			= @IsDeleted,
				Operation			= @Operation,
				SourceDocumentId	= @SourceDocumentId,
				Comments			= @Comments,
				AuthorId			= @AuthorId,
				ReportDate			= getdate()
			where 
				Id = @oldDocId

			-- Если таблица ожидаемого товара не пуста
			if exists (select 1 from #wmsExpectedReceiptDocumentItems) begin
	
				-- Создаем записи в таблице Товары по документу
				insert WmsExpectedReceiptDocumentsItems (DocId, TaskId, ProductId, Sku, Quantity, Price, ForOrder)
				select @oldDocId, i.TaskId, i.ProductId, p.Sku, i.Quantity, i.Price, i.ForOrder
				from #wmsExpectedReceiptDocumentItems i
					join PRODUCTS p on p.ID = i.ProductId
				
			end

		end else

		-- Если удаление документа
		if @Operation = 3 begin

			select @oldDocId = Id from WmsExpectedReceiptDocuments where WarehouseId = @WarehouseId and PublicId = @PublicId
	
			-- Архивируем устаревший Документ
			insert WmsExpectedReceiptDocumentsArchive (Id, WarehouseId, PublicId, Number, WmsCreateDate, ExpectedDate, DocStatus, DocSource, IsDeleted, Comments, AuthorId, Operation, CreateDate, ReportDate)	
			select Id, WarehouseId, PublicId, Number, WmsCreateDate, ExpectedDate, DocStatus, DocSource, IsDeleted, Comments, AuthorId, Operation, CreateDate, ReportDate
			from WmsExpectedReceiptDocuments 
			where Id = @oldDocId

			-- Архивируем Товарные позиции по устаревшему Документу
			insert WmsExpectedReceiptDocumentsItemsArchive (Id, DocId, TaskId, ProductId, Sku, Quantity, ForOrder, CreateDate)
			select Id, DocId, TaskId, ProductId, Sku, Quantity, ForOrder, CreateDate
			from WmsExpectedReceiptDocumentsItems 
			where DocId = @olddocId
			-- Удаляем Товарные позиции по устаревшему Документу
			delete WmsExpectedReceiptDocumentsItems where DocId = @olddocId
			
			-- Обновляем текущий Документ
			update WmsExpectedReceiptDocuments
			set 
				Number				= @Number,
				WmsCreateDate		= @WmsCreateDate,
				ExpectedDate		= @ExpectedDate,
				DocStatus			= @DocStatus,
				DocSource			= @DocSource,
				IsDeleted			= @IsDeleted,
				Operation			= @Operation,
				SourceDocumentId	= @SourceDocumentId,
				Comments			= @Comments,
				AuthorId			= @AuthorId,
				ReportDate			= getdate()
			where 
				Id = @oldDocId

			-- Если таблица ожидаемого товара не пуста
			if exists (select 1 from #wmsExpectedReceiptDocumentItems) begin
	
				-- Создаем записи в таблице Товары по документу
				insert WmsExpectedReceiptDocumentsItems (DocId, TaskId, ProductId, Sku, Quantity, Price, ForOrder)
				select @oldDocId, i.TaskId, i.ProductId, p.Sku, i.Quantity, i.Price, i.ForOrder
				from #wmsExpectedReceiptDocumentItems i
					join PRODUCTS p on p.ID = i.ProductId
				
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
