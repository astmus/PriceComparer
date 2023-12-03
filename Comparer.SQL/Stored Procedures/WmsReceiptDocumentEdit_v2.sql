create proc WmsReceiptDocumentEdit_v2 (
	@Operation			int,					-- Операция: 1 - создание, 2 - корректировка, 3 - удаление
	@PublicId			uniqueidentifier,		-- Идентификатор документа в WMS	
	@Number				varchar(32),			-- Номер документа в WMS	
	@DocSource			int,					-- Источник поступления: 
												-- 1 - Приемка от поставщиков, 
												-- 2 - Приемка возвратов от клиентов
												-- 3 - Перемещение из оптовой точки,
												-- 4 - Приемка парфюмерных пробников в зоне розлива
												-- 5 - прочее.
	@WmsCreateDate		datetime,				-- Дата создание/корректировки/удаления документа
	@IsDeleted			bit,					-- Пометка на удаление
	@ReturnedOrderId	uniqueidentifier,		-- Идентификатор заказа, по которому выполняется возврат
	@Comments			nvarchar(1024),			-- Колмментарий
	@AuthorId			uniqueidentifier,		-- Идентификатор автора
	-- Выходные параметры
	@ErrorMes nvarchar(255) out					-- Сообщение об ошибках
) as
begin

	set @ErrorMes = ''
	set nocount on

	declare @trancount int
	select @trancount = @@TRANCOUNT

	declare @result int = 0
	declare @newDocId bigint = 0
	declare @oldDocId bigint = 0
	declare @err nvarchar(255) = ''

	begin try 
	
		-- Создаем все необходимые временные таблицы --------------------------------------------------------------------

		-- Создаем временную таблицу для артикулов, остатки по которым требуют корректировки
		if (not object_id('tempdb..#skusForInstockCorrect') is null) drop table #skusForInstockCorrect
        create table #skusForInstockCorrect (
			ProductId		uniqueidentifier	not null,	-- Идентификатор товара
			Sku				int					not null,	-- Артикул товара
			Quantity		int					not null,	-- Количество
			QualityId		int					not null,	-- Качество
			OldQualityId	int					null		-- Качество, из которого перешел товар
		)

		-- Временная таблица для артикулов, по которым необходимо выполнить "перерезервирование" товарных позиций по заказам
		if (not object_id('tempdb..#skuForCorrectOrdersInstocQuantity') is null) drop table #skuForCorrectOrdersInstocQuantity
		create table #skuForCorrectOrdersInstocQuantity (
			Sku		int		not null,
			primary key (Sku)
		)

		-- Временная таблица для номеров Заданий на закупку, 
		-- по которым необходимо выполнить "перерезервирование" товарных позиций по заказам
		if (not object_id('tempdb..#purchaseTaskCodesForCorrectOrdersInstocQuantity') is null) drop table #purchaseTaskCodesForCorrectOrdersInstocQuantity
		create table #purchaseTaskCodesForCorrectOrdersInstocQuantity (
			Code	bigint		not null,
			primary key (Code)
		)

		-- Создаем все необходимые временные таблицы --------------------------------------------------------------------

		declare @orderExists bit = 0
		if @DocSource = 2 and @ReturnedOrderId is not null begin
			if exists (select 1 from CLIENTORDERS where ID = @ReturnedOrderId)
				set @orderExists = 1
		end


		if @trancount = 0
			begin transaction
		
		-- Если создание документа
		if @Operation = 1 begin
	
			-- Если требуется удалить ранее созданный документ
			if @IsDeleted = 1 begin

				-- Выполняем корректировку остатков по соответствующим товарным позициям				
				exec @result = WmsReceiptDocumentEdit_v2 3, @PublicId, @Number, @DocSource, @WmsCreateDate, @IsDeleted, @ReturnedOrderId, 
														@Comments, @AuthorId, @err out
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
			if exists (select 1 from WmsReceiptDocuments where PublicId = @PublicId) begin

				-- Выполняем корректировку остатков по соответствующим товарным позициям				
				exec @result = WmsReceiptDocumentEdit_v2 2, @PublicId, @Number, @DocSource, @WmsCreateDate, @IsDeleted, @ReturnedOrderId,
														@Comments, @AuthorId, @err out
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
			insert WmsReceiptDocuments (PublicId, Number, WmsCreateDate, Operation, DocSource, IsDeleted, ReturnedOrderId, Comments, AuthorId)	
			values(@PublicId, @Number, @WmsCreateDate, 1, @DocSource, @IsDeleted, @ReturnedOrderId, @Comments, @AuthorId)

			set @newDocId = @@Identity

			-- Если таблица поступившего товара не пуста
			if exists (select 1 from #wmsReceiptDocumentItems) begin

				-- Определяем артикулы товаров
				update i
				set i.Sku = p.SKU
				from #wmsReceiptDocumentItems i join PRODUCTS p with (nolock) on p.ID = i.ProductId

				-- Создаем записи в таблице Товары по документу
				insert WmsReceiptDocumentsItems (DocId, TaskId, ProductId, Sku, Quantity, QualityId, Price)
				select @newDocId, i.TaskId, i.ProductId, i.Sku, i.Quantity, i.QualityId, i.Price
				from #wmsReceiptDocumentItems i
								
				-- Заполняем временную таблицу для артикулов, остатки по которым требуют корректировки
				insert #skusForInstockCorrect(ProductId, Sku, QualityId, Quantity)
				select ProductId, Sku, QualityId, sum(Quantity)
				from #wmsReceiptDocumentItems 
				group by ProductId, Sku, QualityId
								
				-- Выполняем корректировку остатков по соответствующим товарным позициям
				exec @result = CorrectInstockForSkus_v2 1
				-- Если корректировка закончилась неудачей, делаем rollback транзакции
				if @result = 1 begin
					if @trancount = 0
						rollback transaction
					set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры CorrectInstockForSkus_v2 (1)!'
					return 1
				end

				-- Заполняем временную таблицу для артикулов, по которым необходимо выполнить "перерезервирование" товарных позиций по заказам
				insert #skuForCorrectOrdersInstocQuantity(Sku)
				select distinct Sku from #wmsReceiptDocumentItems

				-- Заполняем временную таблицу для номеров Заданий на закупку, 
				-- по которым необходимо выполнить "перерезервирование" товарных позиций по заказам
				insert #purchaseTaskCodesForCorrectOrdersInstocQuantity(Code)
				select distinct t.CODE 
				from #wmsReceiptDocumentItems i 
					join PurchasesTasks t on t.PublicGuid = i.TaskId 
				where i.TaskId is not null
								
				-- Если не удалось найти ни одного Задания на закупку,
				-- считаем что это Приемка по Ожидаемой приемке, созданная в WMS или УТ
				-- Соответственно тип документа изменяем на 5 - "Прочее".
				if not exists (select 1 from #purchaseTaskCodesForCorrectOrdersInstocQuantity) begin

					set @ErrorMes = ''

				end else begin
				
					-- Если корректировка успешно выполнена,
					-- вызываем хранимую процедуру для "перерезервирования" товаров под заказы
					exec @result = CorrectOrdersInstockQuantityForSkus @DocSource, @err out
					-- Если "перерезервирование" закончилось неудачей, делаем rollback транзакции
					if @result = 1 begin
						if @trancount = 0
							rollback transaction
						set @ErrorMes = @err
						return 1
					end

				end
				
			end

		end else

		-- Если изменение документа
		if @Operation = 2 begin

			-- Получаем идентификатор документа
			set @oldDocId = (select Id from WmsReceiptDocuments where PublicId = @PublicId)

			-- Объявляем таблицу, для получения списка ранее загруженных позиций
			declare @oldItems table (				
				ProductId			uniqueidentifier	not null,	-- Идентификатор товара
				Sku					int					not null,	-- Артикул товара
				Quantity			int					not null,	-- Количество товарных позиций	
				QualityId			int					not null	-- Качество				
			)
			-- Получаем список ранее загруженных позиций
			insert @oldItems (ProductId, Sku, Quantity, QualityId)
			select ProductId, Sku, QualityId, sum(Quantity)
			from WmsReceiptDocumentsItems 
			where DocId = @oldDocId 
			group by ProductId, Sku, QualityId

			-- Архивируем устаревший Документ
			insert WmsReceiptDocumentsArchive (Id, PublicId, Number, WmsCreateDate, Operation, DocSource, IsDeleted, ReturnedOrderId, Comments, AuthorId, CreateDate)	
			select Id, PublicId, Number, WmsCreateDate, Operation, DocSource, IsDeleted, ReturnedOrderId, Comments, AuthorId, CreateDate
			from WmsReceiptDocuments 
			where Id = @oldDocId
						
			-- Архивируем Товарные позиции по устаревшему Документу
			insert WmsReceiptDocumentsItemsArchive (Id, DocId, TaskId, ProductId, Sku, Quantity, QualityId, Price, CreateDate)
			select Id, DocId, TaskId, ProductId, Sku, Quantity, QualityId, Price, CreateDate
			from WmsReceiptDocumentsItems where DocId = @oldDocId
			-- Удаляем Товарные позиции по устаревшему Документу
			delete WmsReceiptDocumentsItems where DocId = @oldDocId

			-- Обновляем текущий Документ
			update WmsReceiptDocuments
			set Number = @Number,
				WmsCreateDate = @WmsCreateDate,
				Operation = @Operation,
				DocSource = @DocSource,
				IsDeleted = @IsDeleted,
				ReturnedOrderId = @ReturnedOrderId,
				Comments = @Comments,
				AuthorId = @AuthorId
			where Id = @oldDocId
			
			-- Если таблица поступившего товара не пуста
			if exists (select 1 from #wmsReceiptDocumentItems) begin

				-- Определяем артикулы товаров
				update i
				set i.Sku = p.SKU
				from #wmsReceiptDocumentItems i join PRODUCTS p with (nolock) on p.ID = i.ProductId

				-- Объявляем таблицу, для получения текущего списка позиций
				declare @newItems table (				
					ProductId			uniqueidentifier	not null,	-- Идентификатор товара
					Sku					int					not null,	-- Артикул товара
					Quantity			int					not null,	-- Количество товарных позиций	
					QualityId			int					not null	-- Качество					
				)
				-- Получаем список текущих позиций
				insert @newItems (ProductId, Sku, QualityId, Quantity)
				select ProductId, Sku, QualityId, sum(Quantity)
				from #wmsReceiptDocumentItems 
				group by ProductId, Sku, QualityId

				-- Создаем записи в таблице Товары по документу
				insert WmsReceiptDocumentsItems (DocId, TaskId, ProductId, Sku, Quantity, QualityId, Price)
				select @oldDocId, i.TaskId, i.ProductId, i.Sku, i.Quantity, QualityId, i.Price
				from #wmsReceiptDocumentItems i
								
				-- Заполняем временную таблицу для артикулов, остатки по которым необходимо списать
				insert #skusForInstockCorrect(ProductId, Sku, QualityId, Quantity)
				select	oi.ProductId, oi.Sku, oi.QualityId, 
						case when ni.Quantity is null then oi.Quantity else oi.Quantity - isnull(ni.Quantity,0) end
				from @oldItems oi 
					left join @newItems ni on oi.Sku = ni.Sku and oi.QualityId = ni.QualityId
				where ni.Quantity is null or (ni.Quantity is not null and oi.Quantity > ni.Quantity)
								
				-- Выполняем корректировку остатков по соответствующим товарным позициям
				exec @result = CorrectInstockForSkus_v2 2
				-- Если корректировка закончилась неудачей, делаем rollback транзакции
				if @result = 1 begin
					if @trancount = 0
						rollback transaction
					set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры CorrectInstockForSkus_v2 (2)!'
					return 1
				end

				-- Очищаем временную таблицу 
				delete #skusForInstockCorrect

				-- Заполняем временную таблицу для артикулов, остатки по которым необходимо увеличить
				insert #skusForInstockCorrect(ProductId, Sku, QualityId, Quantity)
				select	ni.ProductId, ni.Sku, ni.QualityId, 
						case when oi.Quantity is null then ni.Quantity else ni.Quantity - isnull(oi.Quantity,0) end
				from @newItems ni 
					left join @oldItems oi on ni.Sku = oi.Sku and oi.QualityId = ni.QualityId
				where oi.Quantity is null or (oi.Quantity is not null and ni.Quantity > oi.Quantity)
								
				-- Выполняем корректировку остатков по соответствующим товарным позициям
				exec @result = CorrectInstockForSkus_v2 1
				-- Если корректировка закончилась неудачей, делаем rollback транзакции
				if @result = 1 begin
					if @trancount = 0
						rollback transaction
					set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры CorrectInstockForSkus_v2 (1)!'
					return 1
				end

				-- Заполняем временную таблицу для артикулов, по которым необходимо выполнить "перерезервирование" товарных позиций по заказам
				insert #skuForCorrectOrdersInstocQuantity(Sku)
				select Sku from @oldItems
				union
				select Sku from @newItems				

				-- Заполняем временную таблицу для номеров Заданий на закупку, 
				-- по которым необходимо выполнить "перерезервирование" товарных позиций по заказам
				insert #purchaseTaskCodesForCorrectOrdersInstocQuantity(Code)
				select distinct t.CODE 
				from #wmsReceiptDocumentItems i 
					join PurchasesTasks t on t.PublicGuid = i.TaskId 
				where i.TaskId is not null
				
				-- Если не удалось найти ни одного Задания на закупку,
				-- считаем что это Приемка по Ожидаемой приемке, созданная в WMS или УТ
				-- Соответственно тип документа изменяем на 5 - "Прочее".
				if not exists (select 1 from #purchaseTaskCodesForCorrectOrdersInstocQuantity) begin
									
					set @ErrorMes = ''

				end else begin
							
					-- Вызываем хранимую процедуру для "перерезервирования" товаров под заказы
					exec @result = CorrectOrdersInstockQuantityForSkus @DocSource, @err out
					-- Если "перерезервирование" закончилось неудачей, делаем rollback транзакции
					if @result = 1 begin
						if @trancount = 0
							rollback transaction
						set @ErrorMes = @err
						return 1
					end

				end

			end

		end else

		-- Если удаление документа
		if @Operation = 3 begin

			-- Получаем идентификатор документа
			set @oldDocId = (select Id from WmsReceiptDocuments where PublicId = @PublicId)

			-- Объявляем таблицу, для получения списка ранее загруженных позиций
			declare @items table (				
				ProductId			uniqueidentifier	not null,	-- Идентификатор товара
				Sku					int					not null,	-- Артикул товара
				Quantity			int					not null,	-- Количество товарных позиций	
				QualityId			int					not null	-- Качество
			)
			-- Получаем список ранее загруженных позиций
			insert @items (ProductId, Sku, Quantity, QualityId)
			select ProductId, Sku, QualityId, sum(Quantity)
			from WmsReceiptDocumentsItems 
			where DocId = @oldDocId 
			group by ProductId, Sku, QualityId

			-- Архивируем устаревший Документ
			insert WmsReceiptDocumentsArchive (Id, PublicId, Number, WmsCreateDate, Operation, DocSource, IsDeleted, ReturnedOrderId, Comments, AuthorId, CreateDate)	
			select Id, PublicId, Number, WmsCreateDate, Operation, DocSource, IsDeleted, ReturnedOrderId, Comments, AuthorId, CreateDate
			from WmsReceiptDocuments where Id = @oldDocId
			
			-- Архивируем Товарные позиции по устаревшему Документу
			insert WmsReceiptDocumentsItemsArchive (Id, DocId, TaskId, ProductId, Sku, Quantity, QualityId, Price, CreateDate)
			select Id, DocId, TaskId, ProductId, Sku, Quantity, QualityId, Price, CreateDate
			from WmsReceiptDocumentsItems where DocId = @oldDocId
			-- Удаляем Товарные позиции по устаревшему Документу
			delete WmsReceiptDocumentsItems where DocId = @oldDocId
						
			-- Обновляем текущий Документ
			update WmsReceiptDocuments
			set Number = @Number,
				WmsCreateDate = @WmsCreateDate,
				Operation = @Operation,
				DocSource = @DocSource,
				IsDeleted = @IsDeleted,
				ReturnedOrderId = @ReturnedOrderId,
				Comments = @Comments,
				AuthorId = @AuthorId
			where Id = @oldDocId
			
			-- Если таблица поступившего товара не пуста
			if exists (select 1 from #wmsReceiptDocumentItems) begin

				-- Определяем артикулы товаров
				update i
				set i.Sku = p.SKU
				from #wmsReceiptDocumentItems i join PRODUCTS p with (nolock) on p.ID = i.ProductId

				-- Создаем записи в таблице Товары по документу
				insert WmsReceiptDocumentsItems (DocId, TaskId, ProductId, Sku, Quantity, QualityId, Price)
				select @oldDocId, i.TaskId, i.ProductId, i.Sku, i.Quantity, i.QualityId, i.Price
				from #wmsReceiptDocumentItems i
				
			end

			-- Заполняем временную таблицу для артикулов, остатки по которым необходимо списать
			insert #skusForInstockCorrect(ProductId, Sku, QualityId, Quantity)
			select ProductId, Sku, QualityId, sum(Quantity)
			from @items 
			group by ProductId, Sku, QualityId
								
			-- Выполняем корректировку остатков по соответствующим товарным позициям
			exec @result = CorrectInstockForSkus_v2 2
			-- Если корректировка закончилась неудачей, делаем rollback транзакции
			if @result = 1 begin
				if @trancount = 0
					rollback transaction
				set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры CorrectInstockForSkus_v2 (1)!'
				return 1
			end

		end

		-- Если Приемка возвратов от клиентов и документ только создается
		if @DocSource = 2 and @ReturnedOrderId is not null and @Operation = 1 begin -- exists (select 1 from #wmsReceiptDocumentItems where OrderId is not null) begin

			-- Если заказ не в статусе "Отменен" и "Возвращен в магазин"
			if exists (select 1 from CLIENTORDERS where ID = @ReturnedOrderId and STATUS <> 3 and STATUS <> 6) begin
			
				-- Объявляем временную таблицу для передачи идентификаторов товарных позиций заказа, которые необходимо вернуть
				if (not object_id('tempdb..#orderItemIdsForReturn') is null) drop table #orderItemIdsForReturn
				create table #orderItemIdsForReturn
				(	
					ProductId		uniqueidentifier	not null,		-- Идентификатор товарной позиции
					Quantity		int					not null,		-- Количество
					Primary key (ProductId)
				)
			
				-- Заполняем временную таблицу
				insert #orderItemIdsForReturn (ProductId, Quantity)
				select i.ProductId, sum(i.Quantity)
				from #wmsReceiptDocumentItems i --where i.OrderId is not null
				group by i.ProductId

				-- Получаем идентификатор заказа
				--declare @orderId uniqueidentifier
				--set @orderId = (select top 1 OrderId from #wmsReceiptDocumentItems)

				-- Выполняем возврат товарных позиций
				exec @result = ReturnOrderItems @ReturnedOrderId, @err
				if @result = 1 begin				
					if @trancount = 0
						rollback transaction
					set @ErrorMes = @err
					return 1
				end

			end

		end


		if @trancount = 0
			commit transaction

		return 0
	end try 
	begin catch 
		if @trancount = 0
			rollback transaction

		set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры WmsReceiptDocumentEdit_v2!'
		declare @err_mes nvarchar(4000)
		select @err_mes = ERROR_MESSAGE()
		if @err_mes is null begin
			set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры WmsReceiptDocumentEdit_v2! Причина не установлена.'
		end else begin
			if len(@err_mes) > 200
				set @ErrorMes = 'WmsReceiptDocumentEdit_v2! ' + substring(@ErrorMes, 1, 200)
			else
				set @ErrorMes = 'WmsReceiptDocumentEdit_v2! ' + @err_mes
		end
		return 1
	end catch

end
