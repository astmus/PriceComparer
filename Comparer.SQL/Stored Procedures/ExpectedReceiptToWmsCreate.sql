create proc ExpectedReceiptToWmsCreate
(
	@Operation			int,					-- Операция: 1 - создание, 2 - корректировка, 3 - удаление
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
	begin try
		declare @trancount int
		select @trancount = @@trancount

		if @trancount = 0
        	begin transaction

        declare @newDocId bigint = 0

        -- Вставляем запись в таблицу Документов
        insert WmsExpectedReceiptDocuments (PublicId, Number, WmsCreateDate, ExpectedDate, DocStatus, DocSource, IsDeleted, SourceDocumentId, Comments, Operation, AuthorId)	
        values(@PublicId, @Number, @WmsCreateDate, @ExpectedDate, @DocStatus, @DocSource, @IsDeleted, @SourceDocumentId, @Comments, @Operation, @AuthorId)

        set @newDocId = @@Identity

        -- Если таблица ожидаемого товара не пуста
		if exists (select 1 from #tmp_wmsExpectedReceiptDocItems) begin
			-- Создаем записи в таблице Товары по документу
			insert WmsExpectedReceiptDocumentsItems (DocId, TaskId, ProductId, Sku, Quantity, Price, ForOrder)
			select @newDocId, i.TaskId, i.ProductId, p.Sku, i.Quantity, i.Price, i.ForOrder
			from #tmp_wmsExpectedReceiptDocItems i
			join PRODUCTS p on p.ID = i.ProductId
		end

        -- Экспорт в WMS
        insert into ExportPurchaseTasks (TaskId, Operation)
        values (@PublicId, @Operation)

		if @trancount = 0
        	commit transaction

        return 0

    end try 
	begin catch 
		if @trancount > 0
			rollback transaction

		set @ErrorMes = error_message()

		return 1
	end catch
end

drop table #tmp_wmsExpectedReceiptDocItems
