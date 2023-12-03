create proc WmsShipmentDocumentEdit_v3
(
	@Operation			int,					-- Операция: 1 - создание, 2 - корректировка, 3 - удаление
	@WarehouseId		int,					-- Идентификатор склада
	@PublicId			uniqueidentifier,		-- Идентификатор обмена
	@Number				varchar(32),			-- Номер документа в WMS
	@ShipmentDirection	int,					-- Направление отгрузки:
												-- 1 - Курьерская доставка
												-- 2 - Доставка транспортной компанией
												-- 3 - Самовывоз (включая Escentric и перемещение на оптовую точку)
												-- 4 - Отгрузка на розлив
												-- 5 - Др.
	@DocStatus			int,					-- Статус документа:
												-- 1 - Новый 
												-- 2 - К планированию
												-- 3 - Спланирован частично
												-- 4 - Готов к отбору
												-- 5 - В отбор
												-- 6 - В отборе
												-- 7 - Отобран
												-- 8 - Готов к отгрузке
												-- 9 - Заблокирован
												-- 10 - Отгружен
												-- 11 - Отменен
	@RouteId			uniqueidentifier,		-- Код маршрута
	--@OuterOrder			bit,					-- Внешний заказ
	@CreateDate			datetime,				-- Дата создание/корректировки/удаления документа
	@ShipmentDate		datetime,				-- Дата отгрузки
	@Comments			nvarchar(1024),			-- Колмментарий
	@IsDeleted			bit,					-- Пометка на удаление
	@AuthorId			uniqueidentifier,		-- Идентификатор автора	
	-- Выходные параметры
	@NewId				int out,				-- Идентификатор созданного документа
	@ErrorMes			nvarchar(4000) out		-- Сообщение об ошибках
) as
begin

	set @NewId = -1
	set @ErrorMes = ''
	set nocount on

	declare @trancount int
	select @trancount = @@trancount

	declare @result int = 0	
	declare @oldDocId bigint = 0
	declare @err nvarchar(255) = ''

	declare @DocKind int = @ShipmentDirection + 10

	begin try 
	
		if @trancount = 0
			begin transaction
		
		-- Создаем все необходимые временные таблицы --------------------------------------------------------------------

		-- Создаем временную таблицу для артикулов, остатки по которым требуют корректировки
		if (not object_id('tempdb..#skusForInstockCorrect') is null) drop table #skusForInstockCorrect
        create table #skusForInstockCorrect 
		(
				ProductId		uniqueidentifier	not null,				-- Идентификатор товара
				Sku				int					not null,				-- Артикул товара
				Quantity		int					not null,				-- Количество
				QualityId		int					not null,				-- Качество
				OldQualityId	int					not null default(0)		-- Качество, из которого перешел товар
				primary key (Sku, QualityId, OldQualityId)
		)

		-- Временная таблица для артикулов, по которым необходимо выполнить "перерезервирование" товарных позиций по заказам
		if (not object_id('tempdb..#skuForCorrectOrdersInstocQuantity') is null) drop table #skuForCorrectOrdersInstocQuantity
		create table #skuForCorrectOrdersInstocQuantity 
		(
			Sku		int		not null,
			primary key (Sku)
		)

		-- Временная таблица для номеров Заказов клиентов, по которым выполнена отшрузка
		if (not object_id('tempdb..#orderNumbersForCorrectOrdersInstocQuantity') is null) drop table #orderNumbersForCorrectOrdersInstocQuantity
		create table #orderNumbersForCorrectOrdersInstocQuantity 
		(
			Number		int		not null,
			primary key (Number)
		)
		
		-- Создаем все необходимые временные таблицы --------------------------------------------------------------------

		declare @oldStatus int

		declare @isOuterOrder bit = 0
		if not exists (select 1 from CLIENTORDERS where ID = @PublicId)
			set @isOuterOrder = 1

		-- Если создание документа
		if @Operation = 1 begin
	
			-- Если требуется удалить ранее созданный документ
			if @IsDeleted = 1 begin

				-- Удаляем документ
				exec @result = WmsShipmentDocumentEdit_v3 3, @WarehouseId, @PublicId, @Number, @ShipmentDirection, @DocStatus, @RouteId,
														@CreateDate, @ShipmentDate, @Comments, @IsDeleted, @AuthorId, @NewId out, @err out						
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
			if exists (select 1 from WmsShipmentDocuments where WarehouseId = @WarehouseId and PublicId = @PublicId) begin

				-- Выполняем корректировку документа
				exec @result = WmsShipmentDocumentEdit_v3 2, @WarehouseId, @PublicId, @Number, @ShipmentDirection, @DocStatus, @RouteId,
															@CreateDate, @ShipmentDate, @Comments, @IsDeleted, @AuthorId, @NewId out, @err out						
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
			insert WmsShipmentDocuments (WarehouseId, PublicId, Number, Operation, WmsCreateDate, ShipmentDate, ShipmentDirection, DocStatus, RouteId, OuterOrder, IsDeleted, Comments, AuthorId)	
			values(@WarehouseId, @PublicId, @Number, 1, @CreateDate, @ShipmentDate, @ShipmentDirection, @DocStatus, @RouteId, @isOuterOrder, @IsDeleted, @Comments, @AuthorId)

			set @NewId = @@Identity
			
			-- Если отгрузка под заказ клиента
			if @ShipmentDirection > 0 begin
				-- Изменяем статус документа "Заказ клиента"
				exec @result = SetWmsShipmentOrderDocumentStatus_v5 @WarehouseId, @PublicId, @DocStatus, @AuthorId, @err out
				if @result = 1 begin
					if @trancount = 0
						rollback transaction
					set @ErrorMes = @err
				end
			end

			-- Если таблица отгруженного товара не пуста
			if exists (select 1 from #wmsShipmentDocumentItems) begin

				-- Определяем артикулы товаров
				update i
				set i.Sku = p.SKU
				from 
					#wmsShipmentDocumentItems i 
					join PRODUCTS p with (nolock) on p.ID = i.ProductId

				-- Создаем записи в таблице Товары по документу
				insert WmsShipmentDocumentsItems (DocId, OrderId, ProductId, Sku, Quantity, QualityId)
				select @NewId, i.OrderId, i.ProductId, i.Sku, i.Quantity, i.QualityId
				from #wmsShipmentDocumentItems i
			
				-- Заполняем временную таблицу для артикулов, остатки по которым требуют корректировки				
				insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)
				select i.ProductId, i.Sku, i.QualityId, 0, sum(i.Quantity)
				from #wmsShipmentDocumentItems i 
				group by i.ProductId, i.Sku, i.QualityId
				
				-- Если Заказ на отгрузку пришел в статусе "Отгружен"
				if @DocStatus = 10 begin
					-- Выполняем корректировку остатков по соответствующим товарным позициям
					--exec @result = CorrectInstockForSkus 2
					exec CorrectInstockForSkus_v3 @WarehouseId, 2, 4, @NewId
					
					-- Ставим в очередь на обработку событий
					declare @ActionBody varchar(100) = '{"OrderId":"' + cast(@PublicId as varchar(36)) +'","StatusId":10}'
					exec ActionsProcessingQueuePut @PublicId, 2, 801, @ActionBody, 2, '86C6A872-1187-4C8B-B382-8DBD917837EC'

				end

			end

		end else

		-- Если изменение документа
		if @Operation = 2 begin

			-- Получаем идентификатор и текущий статус документа
			select 
				@olddocId	= Id, 
				@oldStatus	= DocStatus
			from WmsShipmentDocuments
			where WarehouseId = @WarehouseId and PublicId = @PublicId

			select @NewId = @oldDocId

			-- Если документ уже отгружен, и пришла корректировка со статусом Новый или другим,
			-- то ничего не делаем
			if @oldStatus = 10 and @DocStatus < 10 begin
				if @trancount = 0
					rollback transaction
				return 0
			end

			-- Объявляем таблицу, для получения списка ранее загруженных позиций
			declare @oldItems table 
			(				
				ProductId			uniqueidentifier	not null,	-- Идентификатор товара
				Sku					int					not null,	-- Артикул товара
				Quantity			int					not null,	-- Количество товарных позиций	
				QualityId			int					not null	-- Качество
				primary key (Sku, QualityId)
			)
			-- Получаем список ранее загруженных позиций
			insert @oldItems (ProductId, Sku, QualityId, Quantity)
			select ProductId, Sku, QualityId, sum(Quantity)
			from WmsShipmentDocumentsItems 
			where DocId = @olddocId
			group by ProductId, Sku, QualityId

			-- Архивируем устаревший Документ
			insert WmsShipmentDocumentsArchive (Id, WarehouseId, PublicId, Number, Operation, WmsCreateDate, ShipmentDate, ShipmentDirection, DocStatus, RouteId, OuterOrder, IsDeleted, Comments, AuthorId, CreateDate)	
			select Id, WarehouseId, PublicId, Number, Operation, WmsCreateDate, ShipmentDate, ShipmentDirection, DocStatus, RouteId, OuterOrder, IsDeleted, Comments, AuthorId, CreateDate
			from WmsShipmentDocuments 
			where Id = @oldDocId
			
			-- Архивируем Товарные позиции по устаревшему Документу
			insert WmsShipmentDocumentsItemsArchive (Id, DocId, OrderId, ProductId, Sku, Quantity, QualityId, CreateDate, IsDeleted)
			select Id, DocId, OrderId, ProductId, Sku, Quantity, QualityId, CreateDate, IsDeleted
			from WmsShipmentDocumentsItems 
			where DocId = @olddocId
			-- Удаляем Товарные позиции по устаревшему Документу
			delete WmsShipmentDocumentsItems where DocId = @olddocId

			-- Обновляем текущий Документ
			update 
				WmsShipmentDocuments
			set 
				Operation = @Operation,
				WmsCreateDate = @CreateDate,
				ShipmentDate = @ShipmentDate,
				ShipmentDirection = @ShipmentDirection,
				DocStatus = @DocStatus,
				RouteId = @RouteId,
				IsDeleted = @IsDeleted,
				Comments = @Comments,
				AuthorId = @AuthorId
			where 
				Id = @olddocId

			-- Если таблица поступившего товара не пуста
			if exists (select 1 from #wmsShipmentDocumentItems) begin

				-- Определяем артикулы товаров
				update i
				set i.Sku = p.SKU
				from 
					#wmsShipmentDocumentItems i 
					join PRODUCTS p with (nolock) on p.ID = i.ProductId

				-- Объявляем таблицу, для получения текущего списка позиций
				declare @newItems table 
				(
					ProductId			uniqueidentifier	not null,	-- Идентификатор товара
					Sku					int					not null,	-- Артикул товара
					Quantity			int					not null,	-- Количество товарных позиций	
					QualityId			int					not null	-- Качество
					primary key (Sku, QualityId)
				)
				-- Получаем список текущих позиций
				insert @newItems (ProductId, Sku, QualityId, Quantity)
				select ProductId, Sku, QualityId, sum(Quantity)
				from #wmsShipmentDocumentItems 
				group by ProductId, Sku, QualityId

				-- Создаем записи в таблице Товары по документу
				insert WmsShipmentDocumentsItems (DocId, OrderId, ProductId, Sku, Quantity, QualityId)
				select @olddocId, i.OrderId, i.ProductId, i.Sku, i.Quantity, i.QualityId
				from #wmsShipmentDocumentItems i
				
				-- Если Заказ на отгрузку пришел в статусе "Отгружен" и текущий статус тоже "Отгружен",
				-- то выполняем корректировку по остаткам
				if @DocStatus = 10 and @oldStatus = 10 begin
								
					-- Заполняем временную таблицу для артикулов, остатки по которым необходимо увеличить
					insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)
					select	oi.ProductId, oi.Sku, oi.QualityId, 0,
							case when ni.Quantity is null then oi.Quantity else oi.Quantity - ni.Quantity end
					from @oldItems oi 
						left join @newItems ni on oi.Sku = ni.Sku and oi.QualityId = ni.QualityId
					where ni.Quantity is null or (ni.Quantity is not null and oi.Quantity > ni.Quantity)
								
					-- Выполняем корректировку остатков по соответствующим товарным позициям
					--exec @result = CorrectInstockForSkus 1
					exec CorrectInstockForSkus_v3 @WarehouseId, 1, 4, @oldDocId

					-- Очищаем временную таблицу 
					delete #skusForInstockCorrect

					-- Заполняем временную таблицу для артикулов, остатки по которым необходимо уменьшить
					insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)
					select	ni.ProductId, ni.Sku, ni.QualityId, 0,
							case when oi.Quantity is null then ni.Quantity else ni.Quantity - oi.Quantity end
					from @newItems ni 
						left join @oldItems oi on ni.Sku = oi.Sku and oi.QualityId = ni.QualityId
					where oi.Quantity is null or (oi.Quantity is not null and ni.Quantity > oi.Quantity)
								
					-- Выполняем корректировку остатков по соответствующим товарным позициям
					--exec @result = CorrectInstockForSkus 2
					exec CorrectInstockForSkus_v3 @WarehouseId, 2, 4, @oldDocId

				end else
				-- Если Заказ на отгрузку пришел в статусе "Отгружен", а текущий статус "Новый",
				-- то выполняем корректировку по остаткам
				if @DocStatus = 10 and @oldStatus < 10 begin

					-- Заполняем временную таблицу для артикулов, остатки по которым требуют корректировки				
					insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)
					select ProductId, Sku, QualityId, 0, sum(Quantity) 
					from #wmsShipmentDocumentItems 
					group by ProductId, Sku, QualityId
									
					-- Выполняем корректировку остатков по соответствующим товарным позициям
					--exec @result = CorrectInstockForSkus 2
					exec CorrectInstockForSkus_v3 @WarehouseId, 2, 4, @oldDocId
					
					-- Ставим в очередь на обработку событий
					declare @ActionObj varchar(100) = '{"OrderId":"' + cast(@PublicId as varchar(36)) +'","StatusId":10}'
					exec ActionsProcessingQueuePut @PublicId, 2, 801, @ActionObj, 2, '86C6A872-1187-4C8B-B382-8DBD917837EC'

				end

			end

		end else

		-- Если удаление документа
		if @Operation = 3 begin

			if not exists (select 1 from WmsShipmentDocuments where WarehouseId = @WarehouseId and PublicId = @PublicId) begin
				if @trancount = 0
					rollback transaction
				set @ErrorMes = 'Документ не удален! Документ с указанным идентификатором отсутствует в базе данных.'
				return 0
			end

			-- Получаем идентификатор и текущий статус документа
			select 
				@olddocId	= Id, 
				@oldStatus	= DocStatus
			from WmsShipmentDocuments
			where WarehouseId = @WarehouseId and PublicId = @PublicId

			select @NewId = @oldDocId

			-- Объявляем таблицу, для получения списка ранее загруженных позиций
			declare @items table 
			(				
				ProductId			uniqueidentifier	not null,	-- Идентификатор товара
				Sku					int					not null,	-- Артикул товара
				Quantity			int					not null,	-- Количество товарных позиций	
				QualityId			int					not null	-- Качество
				primary key (Sku, QualityId)
			)
			-- Получаем список ранее загруженных позиций
			insert @items (ProductId, Sku, QualityId, Quantity)
			select ProductId, Sku, QualityId, sum(Quantity) 
			from WmsShipmentDocumentsItems 
			where DocId = @olddocId 
			group by ProductId, Sku, QualityId

			-- Архивируем устаревший Документ
			insert WmsShipmentDocumentsArchive (Id, WarehouseId, PublicId, Number, Operation, WmsCreateDate, ShipmentDate, ShipmentDirection, DocStatus, RouteId, OuterOrder, IsDeleted, Comments, AuthorId, CreateDate)	
			select Id, WarehouseId, PublicId, Number, Operation, WmsCreateDate, ShipmentDate, ShipmentDirection, DocStatus, RouteId, OuterOrder, IsDeleted, Comments, AuthorId, CreateDate
			from WmsShipmentDocuments where Id = @oldDocId

			-- Архивируем Товарные позиции по устаревшему Документу
			insert WmsShipmentDocumentsItemsArchive (Id, DocId, OrderId, ProductId, Sku, Quantity, QualityId, CreateDate, IsDeleted)
			select Id, DocId, OrderId, ProductId, Sku, Quantity, QualityId, CreateDate, IsDeleted
			from 
				WmsShipmentDocumentsItems 
			where 
				DocId = @olddocId
			-- Удаляем Товарные позиции по устаревшему Документу
			delete WmsShipmentDocumentsItems where DocId = @oldDocId

			-- Обновляем текущий Документ
			update 
				WmsShipmentDocuments
			set 
				Operation = @Operation,
				DocStatus = 11,
				IsDeleted = @IsDeleted,
				Comments = @Comments,
				AuthorId = @AuthorId
			where 
				Id = @olddocId
			
			-- Если таблица поступившего товара не пуста
			if exists (select 1 from #wmsShipmentDocumentItems) begin

				-- Определяем артикулы товаров
				update i
				set i.Sku = p.SKU
				from #wmsShipmentDocumentItems i join PRODUCTS p with (nolock) on p.ID = i.ProductId

				-- Создаем записи в таблице Товары по документу
				insert WmsShipmentDocumentsItems (DocId, OrderId, ProductId, Sku, Quantity, QualityId)
				select @oldDocId, i.OrderId, i.ProductId, i.Sku, i.Quantity, i.QualityId
				from #wmsShipmentDocumentItems i

			end

			-- Если статус удаляемого документа "Отгружен"
			if @oldStatus = 10 begin
								
				-- Заполняем временную таблицу для артикулов, остатки по которым необходимо списать
				insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)
				select ProductId, Sku, QualityId, 0, sum(Quantity)
				from @items					
				group by ProductId, Sku, QualityId

				-- Выполняем корректировку остатков по соответствующим товарным позициям
				exec CorrectInstockForSkus_v3 @WarehouseId, 1, 4, @oldDocId

			end

		end

		if @trancount = 0
			commit transaction

	end try 
	begin catch 
		if @trancount = 0
			rollback transaction
		select @ErrorMes = error_message()
		return 1
	end catch

	-- Проверяем отгрузку на предмет связи с документом УТ "Перемещение на розлив"
	declare 
		@ErrorMesage nvarchar(255) = ''
	exec UTMovingRozlivDocument @PublicId, @ErrorMesage out

	return 0

end
