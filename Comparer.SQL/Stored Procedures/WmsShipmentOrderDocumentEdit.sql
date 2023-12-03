create proc WmsShipmentOrderDocumentEdit 
(
	@Operation			int,					-- Операция: 1 - создание, 2 - корректировка, 3 - удаление
	@PublicId			uniqueidentifier,		-- Идентификатор обмена (PK в таблице ClientOrders)
	@ClientId			uniqueidentifier,		-- Идентификатор клиента
	@Number				varchar(32),			-- Номер документа
	@ShipmentDirection	int,					-- Направление отгрузки: 
												-- 1 - Курьерская доставка,
												-- 2 - Доставка транспортной компанией,
												-- 3 - Самовывоз,
												-- 4 - Отгрузка на розлив
												-- 5 - Возврат поставщику.	
	@OrderSource		uniqueidentifier,		-- Источник заказа.
												-- Идентификатор Ожадаемой приемки для Возврата поставщику
	@DocStatus			int,					-- Статус документа (уточнить в Концептуальном Дизайне)	
	@WmsCreateDate		datetime,				-- Дата создание/корректировки/удаления документа
	@ShipmentDate		date,					-- Дата отгрузки
	@DeliveryAddress	nvarchar(500),			-- Адрес доставки
	@RouteId			uniqueidentifier,		-- Идентификатор маршрута (ветка метро)
	@IsShipped			bit,					-- Отгружен
	@IsPartial			bit,					-- Частично зарезервированный заказ
	@IsDeleted			bit,					-- Пометка на удаление
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
	declare @err nvarchar(4000) = ''

	begin try 
	
		if @trancount = 0
			begin transaction

		-- Если создание документа
		if @Operation = 1 begin
	
			-- Если требуется удалить ранее созданный документ
			if @IsDeleted = 1 begin

				-- Удаляем указанный документ
				exec @result = WmsShipmentOrderDocumentEdit 3, @PublicId, @ClientId, @Number, @ShipmentDirection, @OrderSource,
					@DocStatus, @WmsCreateDate, @ShipmentDate, 
					@DeliveryAddress, @RouteId, @IsShipped, @IsPartial, @IsDeleted, @Comments, @AuthorId, @err out
				-- Если корректировка закончилась неудачей, делаем rollback транзакции
				if @result = 1 begin
					if @trancount = 0
						rollback transaction
					set @ErrorMes = @err
					return 1
				end else begin
					return 0
				end
				
			end else

			-- Проверяем, есть ли в базе данных уже такой документ
			if exists (select 1 from WmsShipmentOrderDocuments where PublicId = @PublicId) begin

				-- Выполняем корректировку остатков по соответствующим товарным позициям				
				exec @result = WmsShipmentOrderDocumentEdit 2, @PublicId, @ClientId, @Number, @ShipmentDirection, @OrderSource,
					@DocStatus, @WmsCreateDate, @ShipmentDate, 
					@DeliveryAddress, @RouteId, @IsShipped, @IsPartial, @IsDeleted, @Comments, @AuthorId, @err out
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
			insert WmsShipmentOrderDocuments (PublicId, ClientId, Number, WmsCreateDate, ShipmentDate, ShipmentDirection, OrderSource, 
											  DeliveryAddress, RouteId, DocStatus, IsShipped, IsPartial, IsDeleted, AuthorId, Comments, Operation)	
			values(@PublicId, @ClientId, @Number, @WmsCreateDate, @ShipmentDate, @ShipmentDirection, @OrderSource,
					@DeliveryAddress, @RouteId, @DocStatus, @IsShipped, @IsPartial, @IsDeleted, @AuthorId, @Comments, @Operation)

			set @newDocId = @@Identity

			-- Если временная таблица товара не пуста
			if exists (select 1 from #wmsShipmentOrderDocumentItems) begin

				-- Создаем записи в таблице Товары по документу
				insert WmsShipmentOrderDocumentsItems (DocId, ProductId, Sku, Quantity, Price)
				select @newDocId, i.ProductId, p.SKU, i.Quantity, i.Price
				from #wmsShipmentOrderDocumentItems i
					Join PRODUCTS p on p.ID = i.ProductId
				
			end

			-- Если создан Возврат поставщику
			if @ShipmentDirection = 5 begin

				-- Вставляем новые записи в таблицу ExportOrders
				insert ExportOrders (OrderId, Operation, IsPartial, OrderState)
				values (@PublicId, 1, 0, 0)
				

			end

		end else

		-- Если изменение документа
		if @Operation = 2 begin

			set @oldDocId = (select Id from WmsShipmentOrderDocuments where PublicId = @PublicId)

			-- Архивируем устаревший Документ
			insert WmsShipmentOrderDocumentsArchive 
			(
				Id, PublicId, ClientId, Number, WmsCreateDate, ShipmentDate, ShipmentDirection, OrderSource, 
				DeliveryAddress, RouteId, DocStatus, IsShipped, IsPartial, IsDeleted, AuthorId, Comments, ReportDate, Operation, CreateDate
			)	
			select 
				Id, PublicId, ClientId, Number, WmsCreateDate, ShipmentDate, ShipmentDirection, OrderSource, 
				DeliveryAddress, RouteId, DocStatus, IsShipped, @IsPartial, IsDeleted, AuthorId, Comments, ReportDate, Operation, CreateDate
			from 
				WmsShipmentOrderDocuments 
			where 
				Id = @oldDocId
			
			-- Архивируем Товарные позиции по устаревшему Документу
			insert WmsShipmentOrderDocumentsItemsArchive (Id, DocId, ProductId, Sku, Quantity, CreateDate)
			select Id, DocId, ProductId, Sku, Quantity, CreateDate
			from WmsShipmentOrderDocumentsItems where DocId = @oldDocId
			-- Удаляем Товарные позиции по устаревшему Документу
			delete WmsShipmentOrderDocumentsItems where DocId = @oldDocId

			-- Обновляем запись в таблице Документов
			update WmsShipmentOrderDocuments
			set ClientId = @ClientId,
				--Number = @Number,
				WmsCreateDate = @WmsCreateDate,
				ShipmentDate = @ShipmentDate,
				ShipmentDirection = @ShipmentDirection,
				OrderSource = @OrderSource,
				DeliveryAddress = @DeliveryAddress,
				RouteId = @RouteId,
				DocStatus = case 
								when DocStatus = 1 then @DocStatus 
								when DocStatus < @DocStatus then @DocStatus
								else DocStatus
							end,
				IsShipped = @IsShipped,
				IsDeleted = @IsDeleted,
				IsPartial = @IsPartial,
				AuthorId = @AuthorId,
				Comments = @Comments,
				Operation = @Operation,
				ReportDate = getdate()
			where Id = @oldDocId

			-- Если таблица ожидаемого товара не пуста
			if exists (select 1 from #wmsShipmentOrderDocumentItems) begin

				-- Создаем записи в таблице Товары по документу
				insert WmsShipmentOrderDocumentsItems (DocId, ProductId, Sku, Quantity, Price)
				select @oldDocId, i.ProductId, p.SKU, i.Quantity, i.Price
				from #wmsShipmentOrderDocumentItems i
					Join PRODUCTS p on p.ID = i.ProductId
				
			end

			-- Если создан Возврат поставщику
			if @ShipmentDirection = 5 begin

				-- Вставляем новые записи в таблицу ExportOrders
				insert ExportOrders (OrderId, Operation, IsPartial, OrderState)
				values (@PublicId, 2, 0, 0)
				

			end

		end else

		-- Если удаление документа
		if @Operation = 3 begin

			set @oldDocId = (select Id from WmsShipmentOrderDocuments where PublicId = @PublicId)

			-- Архивируем устаревший Документ
			insert WmsShipmentOrderDocumentsArchive 
			(
				Id, PublicId, ClientId, Number, WmsCreateDate, ShipmentDate, ShipmentDirection, OrderSource, 
				DeliveryAddress, RouteId, DocStatus, IsShipped, IsPartial, IsDeleted, AuthorId, Comments, Operation, CreateDate,
				ReportDate
			)	
			select 
				Id, PublicId, ClientId, Number, WmsCreateDate, ShipmentDate, ShipmentDirection, OrderSource, 
				DeliveryAddress, RouteId, DocStatus, IsShipped, IsPartial, IsDeleted, AuthorId, Comments, Operation, CreateDate,
				ReportDate
			from 
				WmsShipmentOrderDocuments 
			where 
				Id = @oldDocId
			
			-- Архивируем Товарные позиции по устаревшему Документу
			insert WmsShipmentOrderDocumentsItemsArchive (Id, DocId, ProductId, Sku, Quantity, CreateDate)
			select Id, DocId, ProductId, Sku, Quantity, CreateDate
			from WmsShipmentOrderDocumentsItems where DocId = @oldDocId
			-- Удаляем Товарные позиции по устаревшему Документу
			delete WmsShipmentOrderDocumentsItems where DocId = @oldDocId

			-- Обновляем запись в таблице Документов
			update WmsShipmentOrderDocuments
			set ClientId = @ClientId,
				Number = @Number,
				WmsCreateDate = @WmsCreateDate,
				ShipmentDate = @ShipmentDate,
				ShipmentDirection = @ShipmentDirection,
				OrderSource = @OrderSource,
				DeliveryAddress = @DeliveryAddress,
				RouteId = @RouteId,
				DocStatus = @DocStatus,
				IsShipped = @IsShipped,
				IsDeleted = @IsDeleted,
				IsPartial = @IsPartial,
				AuthorId = @AuthorId,
				Comments = @Comments,
				Operation = @Operation,
				ReportDate = getdate()
			where Id = @oldDocId

			-- Если таблица ожидаемого товара не пуста
			if exists (select 1 from #wmsShipmentOrderDocumentItems) begin

				-- Создаем записи в таблице Товары по документу
				insert WmsShipmentOrderDocumentsItems (DocId, ProductId, Sku, Quantity, Price)
				select @oldDocId, i.ProductId, p.SKU, i.Quantity, i.Price
				from #wmsShipmentOrderDocumentItems i
					Join PRODUCTS p on p.ID = i.ProductId
				
			end

		end

		if @trancount = 0
			commit transaction
		return 0

	end try 
	begin catch 
		if @trancount = 0
			rollback transaction

		set @err = error_message();
		if (len(@err) > 255)
			set @err = substring(@err, 0, 200)

		set @ErrorMes = 'Ошибка процедуры WmsShipmentOrderDocumentEdit! ' + @err;
		return 1
	end catch

end
