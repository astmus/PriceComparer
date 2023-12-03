create proc ComplectingDocumentEdit
(
	@Operation			int,					-- Операция: 1 - создание, 2 - корректировка, 3 - удаление
	@WarehouseId		int,					-- Идентификатор склада
	@DocId				bigint,					-- Идентификатор документа
	@Number				varchar(32),			-- Номер документа
	@DocType			bit,					-- Тип документа 
												-- 1 - Комплектация
												-- 2 - Разукомплектации
	@IsDeleted			bit,					-- Пометка на удаление
	@AuthorId			uniqueidentifier,		-- Идентификатор автора
	-- Выходные параметры
	@NewId				int out,				-- Идентификатор созданного документа
	@ErrorMes			nvarchar(4000) out		-- Сообщение об ошибках
) as
begin

	set nocount on
	
	set @NewId = -1;
	set @ErrorMes = ''
		
	declare 
		@result			int				= 0,
		@archiveId		int				= 0,
		@err			nvarchar(4000)	= ''

	declare @trancount int
	select @trancount = @@trancount

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

		-- Создаем все необходимые временные таблицы --------------------------------------------------------------------

		-- Если создание документа
		if @Operation = 1 begin
	
			-- Если требуется удалить ранее созданный документ
			if @IsDeleted = 1 begin

				-- Выполняем корректировку остатков по соответствующим товарным позициям				
				exec @result = ComplectingDocumentEdit 3, @WarehouseId, @DocId, @Number, @DocType, @IsDeleted, @AuthorId, @NewId out, @err out
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
			if exists (select 1 from ComplectingDocuments where WarehouseId = @WarehouseId and Id = @DocId) begin

				-- Выполняем корректировку остатков по соответствующим товарным позициям				
				exec @result = ComplectingDocumentEdit 2, @WarehouseId, @DocId, @Number, @DocType, @IsDeleted, @AuthorId, @NewId out, @err out
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
			insert 
				ComplectingDocuments (Number, DocType, IsDeleted, AuthorId)	
			values
				(@Number, @DocType, 0, @AuthorId)

			set @NewId = @@Identity
				
			-- Если таблица поступившего товара не пуста
			if exists (select 1 from #complectingsDocumentItems) begin

				-- Определяем артикулы товаров
				update i
				set i.Sku = p.SKU
				from #complectingsDocumentItems i 
					join PRODUCTS p with (nolock) on p.ID = i.ProductId

				-- Создаем записи в таблице Товары по документу
				insert ComplectingDocumentsItems (DocId, BalanceType, ProductId, Quantity, QualityId)
				select @NewId, i.BalanceType, i.ProductId, i.Quantity, i.QualityId
				from #complectingsDocumentItems i
					
				-- Уменьшение остатков на складе
				-- Заполняем временную таблицу для артикулов, остатки по которым требуют корректировки 
				insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)
				select ProductId, Sku, QualityId, 0, sum(Quantity)
				from #complectingsDocumentItems i
				where i.BalanceType = 2
				group by ProductId, Sku, QualityId
				
				-- Выполняем корректировку остатков по соответствующим товарным позициям
				exec CorrectInstockForSkus_v3 @WarehouseId, 2, 6, @NewId

				-- Очищаем временную таблицу
				delete #skusForInstockCorrect

				-- Увеличение остатков на складе
				-- Заполняем временную таблицу для артикулов, остатки по которым требуют корректировки 
				insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)
				select ProductId, Sku, QualityId, 0, sum(Quantity)
				from #complectingsDocumentItems i
				where i.BalanceType = 1
				group by ProductId, Sku, QualityId

				-- Выполняем корректировку остатков по соответствующим товарным позициям
				exec CorrectInstockForSkus_v3 @WarehouseId, 1, 6, @NewId
				
			end

		end else

		-- Если изменение документа
		if @Operation = 2 begin

			-- Если требуется удалить ранее созданный документ
			if @IsDeleted = 1 begin

				-- Выполняем корректировку остатков по соответствующим товарным позициям				
				exec @result = ComplectingDocumentEdit 3, @WarehouseId, @DocId, @Number, @DocType, @IsDeleted, @AuthorId, @NewId out, @err out
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

			-- Проверяем, есть ли в базе данных уже такой документ
			if not exists (select 1 from ComplectingDocuments where WarehouseId = @WarehouseId and Id = @DocId) begin

				-- Выполняем создание документа				
				exec @result = ComplectingDocumentEdit 1, @WarehouseId, @DocId, @Number, @DocType, @IsDeleted, @AuthorId, @NewId out, @err out
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

			-- Объявляем таблицу, для получения списка ранее загруженных позиций
			declare @oldItems table 
			(				
				ProductId			uniqueidentifier	not null,	-- Идентификатор товара
				Sku					int					not null,	-- Артикул товара
				Quantity			int					not null,	-- Количество товарных позиций	
				QualityId			int					not null,	-- Качество
				BalanceType			bit					not null	-- Тип измения остатка:
																	-- 0 - Приход
																	-- 1 - Списание
				primary key (Sku, QualityId)
			)

			-- Получаем список ранее загруженных позиций
			insert @oldItems (ProductId, Sku, QualityId, Quantity, BalanceType)
			select i.ProductId, p.SKU, i.QualityId, sum(i.Quantity), i.BalanceType
			from ComplectingDocumentsItems i
				join PRODUCTS p with (nolock) on p.ID = i.ProductId
			where i.DocId = @DocId 
			group by i.ProductId, p.SKU, i.BalanceType, i.QualityId

			-- Архивируем устаревший Документ
			insert ComplectingDocumentsArchive (DocId, PublicId, Number, DocType, CreateDate, WarehouseId, IsDeleted, ChangeDate, AuthorId)	
			select Id, PublicId, Number, DocType, CreateDate, WarehouseId, IsDeleted, ChangeDate, AuthorId
			from ComplectingDocuments 
			where Id = @DocId

			set @archiveId = @@Identity
			
			-- Архивируем Товарные позиции по устаревшему Документу
			insert ComplectingDocumentsItemsArchive (ArchiveDocId, DocId, BalanceType, ProductId, Quantity, QualityId, CreateDate)
			select @archiveId, DocId, BalanceType, ProductId, Quantity, QualityId, CreateDate
			from ComplectingDocumentsItems
			where DocId = @DocId

			-- Удаляем Товарные позиции по устаревшему Документу
			delete ComplectingDocumentsItems where DocId = @DocId

			-- Обновляем текущий Документ
			update 
				ComplectingDocuments
			set 
				Number		= @Number,
				DocType		= @DocType,
				WarehouseId = @WarehouseId,
				IsDeleted	= @IsDeleted,
				ChangeDate  = getdate(), 
				AuthorId	= @AuthorId
			where 
				Id = @DocId
			
			-- Корректировка остатков по старым позициям

			-- Списание товаров
			-- Заполняем временную таблицу для артикулов, остатки по которым необходимо списать
			insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)
			select oi.ProductId, oi.Sku, oi.QualityId, 0, oi.Quantity
			from @oldItems oi 
			where oi.BalanceType = 1
								
			-- Выполняем корректировку остатков по соответствующим товарным позициям
			exec CorrectInstockForSkus_v3 @WarehouseId, 2, 6, @DocId

			-- Очищаем временную таблицу 
			delete #skusForInstockCorrect

			-- Оприходование товаров
			-- Заполняем временную таблицу для артикулов, остатки по которым необходимо увеличить
			insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)
			select oi.ProductId, oi.Sku, oi.QualityId, 0, oi.Quantity
			from @oldItems oi 
			where oi.BalanceType = 2
								
			-- Выполняем корректировку остатков по соответствующим товарным позициям
			exec CorrectInstockForSkus_v3 @WarehouseId, 1, 6, @DocId

			-- Очищаем временную таблицу 
			delete #skusForInstockCorrect

			-- Если таблица поступившего товара не пуста
			if exists (select 1 from #complectingsDocumentItems) begin

				-- Определяем артикулы товаров
				update i
				set i.Sku = p.SKU
				from 
					#complectingsDocumentItems i 
					join PRODUCTS p with (nolock) on p.ID = i.ProductId
				
				-- Создаем записи в таблице Товары по документу
				insert ComplectingDocumentsItems (DocId, BalanceType, ProductId, Quantity, QualityId)
				select @DocId, i.BalanceType, i.ProductId, i.Quantity, i.QualityId
				from #complectingsDocumentItems i
								
				-- Корректировка остатков по новым позициям

				-- Уменьшение остатков на складе

				-- Заполняем временную таблицу для артикулов, остатки по которым требуют корректировки 
				insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)
				select ProductId, Sku, QualityId, 0, sum(Quantity)
				from #complectingsDocumentItems i
				where i.BalanceType = 2
				group by ProductId, Sku, QualityId

				-- Выполняем корректировку остатков по соответствующим товарным позициям
				exec CorrectInstockForSkus_v3 @WarehouseId, 2, 6, @DocId

				-- Очищаем временную таблицу
				delete #skusForInstockCorrect

				-- Увеличение остатков на складе

				-- Заполняем временную таблицу для артикулов, остатки по которым требуют корректировки 
				insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)
				select ProductId, Sku, QualityId, 0, sum(Quantity)
				from #complectingsDocumentItems i
				where i.BalanceType = 1
				group by ProductId, Sku, QualityId

				-- Выполняем корректировку остатков по соответствующим товарным позициям
				exec CorrectInstockForSkus_v3 @WarehouseId, 1, 6, @DocId
					
			end

		end else

		-- Если удаление документа
		if @Operation = 3 begin

			-- Проверяем, есть ли в базе данных такой документ
			if not exists (select 1 from ComplectingDocuments where WarehouseId = @WarehouseId and Id = @DocId) begin

				if @trancount = 0
					commit transaction
				return 0

			end

			-- Объявляем таблицу, для получения списка ранее загруженных позиций
			declare @items table 
			(				
				ProductId			uniqueidentifier	not null,	-- Идентификатор товара
				Sku					int					not null,	-- Артикул товара
				Quantity			int					not null,	-- Количество товарных позиций	
				QualityId			int					not null,	-- Качество
				BalanceType			bit					not null	-- Тип измения остатка:
																	-- 0 - Приход
																	-- 1 - Списание
				primary key (ProductId, QualityId)
			)

			-- Получаем список ранее загруженных позиций
			insert @items (ProductId, Sku, QualityId, Quantity, BalanceType)
			select i.ProductId, p.SKU, i.QualityId, sum(i.Quantity), i.BalanceType
			from ComplectingDocumentsItems i
				join PRODUCTS p with (nolock) on p.ID = i.ProductId
			where i.DocId = @DocId 
			group by i.ProductId, p.SKU, i.BalanceType, i.QualityId

			-- Архивируем устаревший Документ
			insert ComplectingDocumentsArchive (DocId, PublicId, Number, DocType, CreateDate, WarehouseId, IsDeleted, ChangeDate, AuthorId)	
			select Id, PublicId, Number, DocType, CreateDate, WarehouseId, IsDeleted, ChangeDate, AuthorId
			from ComplectingDocuments 
			where Id = @DocId

			set @archiveId = @@Identity
			
			-- Архивируем Товарные позиции по устаревшему Документу
			insert ComplectingDocumentsItemsArchive (ArchiveDocId, DocId, BalanceType, ProductId, Quantity, QualityId, CreateDate)
			select @archiveId, DocId, BalanceType, ProductId, Quantity, QualityId, CreateDate
			from ComplectingDocumentsItems
			where DocId = @DocId

			-- Удаляем Товарные позиции по устаревшему Документу
			delete ComplectingDocumentsItems where DocId = @DocId

			-- Обновляем текущий Документ
			update 
				ComplectingDocuments
			set 
				Number		= @Number,
				DocType		= @DocType,
				WarehouseId = @WarehouseId,
				IsDeleted	= 1,
				ChangeDate  = getdate(), 
				AuthorId	= @AuthorId
			where 
				Id = @DocId
			
			-- Корректировка остатков по старым позициям

			-- Списание товаров
			-- Заполняем временную таблицу для артикулов, остатки по которым необходимо списать
			insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)
			select i.ProductId, i.Sku, i.QualityId, 0, i.Quantity
			from @items i 
			where i.BalanceType = 1
								
			-- Выполняем корректировку остатков по соответствующим товарным позициям
			exec CorrectInstockForSkus_v3 @WarehouseId, 2, 6, @DocId

			-- Очищаем временную таблицу 
			delete #skusForInstockCorrect

			-- Оприходование товаров
			-- Заполняем временную таблицу для артикулов, остатки по которым необходимо увеличить
			insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)
			select i.ProductId, i.Sku, i.QualityId, 0, i.Quantity
			from @items i 
			where i.BalanceType = 2
								
			-- Выполняем корректировку остатков по соответствующим товарным позициям
			exec CorrectInstockForSkus_v3 @WarehouseId, 1, 6, @DocId

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
