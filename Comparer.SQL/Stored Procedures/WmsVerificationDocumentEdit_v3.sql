create proc WmsVerificationDocumentEdit_v3 
(
	@Operation			int,					-- Операция: 1 - создание, 2 - корректировка, 3 - удаление
	@WarehouseId		int,					-- Идентификатор склада
	@PublicId			uniqueidentifier,		-- Идентификатор обмена
	@Number				varchar(32),			-- Номер документа
	@DocType			int,					-- Тип документа
												-- 1 - Оприходование
												-- 2 - Списание
												-- 3 - Изменение качества
	@CreateDate			datetime,				-- Дата создания	
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
	select @trancount = @@TRANCOUNT

	declare @result int = 0	
	declare @oldDocId bigint = 0
	declare @err nvarchar(255) = ''

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

		-- Временная таблица для номеров Заказов клиентов, по которым выполнена отгрузка
		if (not object_id('tempdb..#orderNumbersForCorrectOrdersInstocQuantity') is null) drop table #orderNumbersForCorrectOrdersInstocQuantity
		create table #orderNumbersForCorrectOrdersInstocQuantity 
		(
			Number		int		not null,
			primary key (Number)
		)

		-- Создаем все необходимые временные таблицы --------------------------------------------------------------------
				
		-- Если создание документа
		if @Operation = 1 begin

			-- Проверяем, есть ли в базе данных уже такой документ
			if exists (select 1 from WmsVerificationDocuments where WarehouseId = @WarehouseId and PublicId = @PublicId) begin

				-- Выполняем корректировку остатков по соответствующим товарным позициям				
				exec @result = WmsVerificationDocumentEdit_v3 2, @WarehouseId, @PublicId, @Number, @DocType, @CreateDate, @AuthorId, @NewId out, @err out
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
			insert WmsVerificationDocuments (WarehouseId, PublicId, Number, DocType, Operation, CreateDate, AuthorId)	
			values(@WarehouseId, @PublicId, @Number, @DocType, @Operation, @CreateDate, @AuthorId)

			set @NewId = @@Identity
		
			-- Если таблица товаров не пуста
			if exists (select 1 from #wmsVerificationDocumentItems) begin

				-- Определяем артикулы товаров
				update i
				set i.Sku = p.SKU
				from #wmsVerificationDocumentItems i join PRODUCTS p with (nolock) on p.ID = i.ProductId

				-- Создаем записи в таблице Товары по документу
				insert WmsVerificationDocumentsItems (DocId, ProductId, Sku, Quantity, QualityId, OldQualityId)
				select @NewId, t.ProductId, t.Sku, t.Quantity, t.QualityId, t.OldQualityId
				from 
				(
					select i.ProductId, i.Sku, i.QualityId, i.OldQualityId, sum(i.Quantity) as 'Quantity'
					from #wmsVerificationDocumentItems i
					group by i.ProductId, i.Sku, i.QualityId, i.OldQualityId
				) t
				
				-- Если оприходование
				if @DocType = 1 begin

					-- Заполняем временную таблицу для артикулов, остатки по которым требуют увеличить
					insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)
					select ProductId, Sku, QualityId, 0, sum(Quantity) 
					from #wmsVerificationDocumentItems 
					group by ProductId, Sku, QualityId
				
					-- Выполняем корректировку остатков по соответствующим товарным позициям
					 exec CorrectInstockForSkus_v3 @WarehouseId, 1, 5, @NewId

				end 
				-- Если Списание
				if @DocType = 2 begin

					-- Заполняем временную таблицу для артикулов, остатки по которым требуют уменьшить
					insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)
					select ProductId, Sku, QualityId, 0, sum(Quantity) 
					from #wmsVerificationDocumentItems 
					group by ProductId, Sku, QualityId
				
					-- Выполняем корректировку остатков по соответствующим товарным позициям
					exec CorrectInstockForSkus_v3 @WarehouseId, 2, 5, @NewId
					
				end

				-- Если Изменение качества
				if @DocType = 3 begin

					-- Заполняем временную таблицу для артикулов, остатки по которым требуют уменьшить
					insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)
					select ProductId, Sku, QualityId, isnull(OldQualityId, 0), sum(Quantity)
					from #wmsVerificationDocumentItems
					group by ProductId, Sku, QualityId, isnull(OldQualityId, 0)
				
					-- Выполняем корректировку остатков по соответствующим товарным позициям
					exec CorrectInstockForSkus_v3 @WarehouseId, 3, 5, @NewId
				
				end
				
			end

		end else

		-- Если изменение документа
		if @Operation = 2 begin

			-- Получаем идентификатор документа
			set @oldDocId = (select Id from WmsVerificationDocuments where WarehouseId = @WarehouseId and PublicId = @PublicId)

			set @NewId = @oldDocId

			-- Объявляем таблицу, для получения списка ранее загруженных позиций
			declare @oldItems table 
			(				
				ProductId			uniqueidentifier	not null,				-- Идентификатор товара
				Sku					int					not null,				-- Артикул товара
				Quantity			int					not null,				-- Количество товарных позиций	
				QualityId			int					not null,				-- Качество
				OldQualityId		int					not null default(0)		-- Качество, из которого перешел товар
				primary key (Sku, QualityId, OldQualityId)
			)
			-- Получаем список ранее загруженных позиций
			insert @oldItems (ProductId, Sku, QualityId, OldQualityId, Quantity)
			select ProductId, Sku, QualityId, isnull(OldQualityId, 0), sum(Quantity)
			from WmsVerificationDocumentsItems
			where DocId = @oldDocId
			group by ProductId, Sku, QualityId, isnull(OldQualityId, 0)

			-- Архивируем устаревший Документ
			insert WmsVerificationDocumentsArchive (Id, WarehouseId, PublicId, Number, DocType, Operation, CreateDate, AuthorId)	
			select Id, WarehouseId, PublicId, Number, DocType, Operation, CreateDate, AuthorId
			from WmsVerificationDocuments 
			where Id = @oldDocId
			
			-- Архивируем Товарные позиции по устаревшему Документу
			insert WmsVerificationDocumentsItemsArchive (Id, DocId, ProductId, Sku, Quantity, QualityId, OldQualityId, CreateDate)
			select Id, DocId, ProductId, Sku, Quantity, QualityId, OldQualityId, CreateDate
			from WmsVerificationDocumentsItems 
			where DocId = @oldDocId
			-- Удаляем Товарные позиции по устаревшему Документу
			delete WmsVerificationDocumentsItems where DocId = @oldDocId

			-- Обновляем текущий Документ
			update 
				WmsVerificationDocuments
			set 
				Operation = @Operation,				
				AuthorId = @AuthorId
			where 
				Id = @oldDocId

			-- Если таблица товаров не пуста
			if exists (select 1 from #wmsVerificationDocumentItems) begin

				-- Определяем артикулы товаров
				update i
				set i.Sku = p.SKU
				from #wmsVerificationDocumentItems i join PRODUCTS p with (nolock) on p.ID = i.ProductId
				
				-- Объявляем таблицу, для получения текущего списка позиций
				declare @newItems table 
				(
					ProductId			uniqueidentifier	not null,				-- Идентификатор товара
					Sku					int					not null,				-- Артикул товара
					Quantity			int					not null,				-- Количество товарных позиций	
					QualityId			int					not null,				-- Качество
					OldQualityId		int					not null default(0)		-- Качество, из которого перешел товар
					primary key (Sku, QualityId, OldQualityId)
				)
				-- Получаем список текущих позиций
				insert @newItems (ProductId, Sku, QualityId, OldQualityId, Quantity)
				select ProductId, Sku, QualityId, isnull(OldQualityId, 0), sum(Quantity)
				from #wmsVerificationDocumentItems 
				group by ProductId, Sku, QualityId, isnull(OldQualityId, 0)

				-- Создаем записи в таблице Товары по документу
				insert WmsVerificationDocumentsItems (DocId, ProductId, Sku, Quantity, QualityId, OldQualityId)
				select @oldDocId, t.ProductId, t.Sku, t.Quantity, t.QualityId, t.OldQualityId
				from 
				(
					select i.ProductId, i.Sku, sum(i.Quantity) as 'Quantity', QualityId, OldQualityId
					from #wmsVerificationDocumentItems i
					group by i.ProductId, i.Sku, i.QualityId, i.OldQualityId
				) t

				-- Если оприходование
				if @DocType = 1 begin

					-- Заполняем временную таблицу для артикулов, остатки по которым необходимо списать
					insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)
					select oi.ProductId, oi.Sku, oi.QualityId, 0, 
						case when ni.Quantity is null then oi.Quantity else oi.Quantity - ni.Quantity  end
					from @oldItems oi 
						left join @newItems ni on oi.Sku = ni.Sku and oi.QualityId = ni.QualityId
					where 
						(ni.Quantity is not null and oi.Quantity > ni.Quantity) or ni.Quantity is null
								
					-- Выполняем корректировку остатков по соответствующим товарным позициям
					exec CorrectInstockForSkus_v3 @WarehouseId, 2, 5, @oldDocId

					-- Очищаем временную таблицу 
					delete #skusForInstockCorrect

					-- Заполняем временную таблицу для артикулов, остатки по которым необходимо увеличить
					insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)
					select 
						ni.ProductId, ni.Sku, ni.QualityId, 0,
						case when oi.Quantity is null then ni.Quantity else ni.Quantity - oi.Quantity end
					from @newItems ni 
						left join @oldItems oi on ni.Sku = oi.Sku and oi.QualityId = ni.QualityId
					where (oi.Quantity is not null and ni.Quantity > oi.Quantity) or oi.Quantity is null
								
					-- Выполняем корректировку остатков по соответствующим товарным позициям
					exec CorrectInstockForSkus_v3 @WarehouseId, 1, 5, @oldDocId

				end

				-- Если списание
				if @DocType = 2 begin

					-- Заполняем временную таблицу для артикулов, остатки по которым необходимо списать
					insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)
					select	
						oi.ProductId, oi.Sku, oi.QualityId, 0,
						case when ni.Quantity is null then oi.Quantity else oi.Quantity - ni.Quantity  end
					from 
						@oldItems oi 
						left join @newItems ni on oi.Sku = ni.Sku and oi.QualityId = ni.QualityId
					where 
						(ni.Quantity is not null and oi.Quantity > ni.Quantity) or ni.Quantity is null
								
					-- Выполняем корректировку остатков по соответствующим товарным позициям
					exec CorrectInstockForSkus_v3 @WarehouseId, 1, 5, @oldDocId

					-- Очищаем временную таблицу 
					delete #skusForInstockCorrect

					-- Заполняем временную таблицу для артикулов, остатки по которым необходимо увеличить
					insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)
					select	
						ni.ProductId, ni.Sku, ni.QualityId, 0,
						case when oi.Quantity is null then ni.Quantity else ni.Quantity - oi.Quantity end
					from 
						@newItems ni 
						left join @oldItems oi on ni.Sku = oi.Sku and oi.QualityId = ni.QualityId
					where 
						(oi.Quantity is not null and ni.Quantity > oi.Quantity) or oi.Quantity is null
								
					-- Выполняем корректировку остатков по соответствующим товарным позициям
					exec CorrectInstockForSkus_v3 @WarehouseId, 2, 5, @oldDocId

				end

				-- Если Изменение качества
				if @DocType = 3 begin
								
					-- Заполняем временную таблицу	
					insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)					
					select t.ProductId, t.Sku, t.QualityId, t.OldQualityId, sum(t.Quantity)
					from
					(
						-- Если есть старая, но нет новой или есть старая и есть новая, но кол-во новой меньше
						select	
							oi.ProductId, oi.Sku, oi.OldQualityId as 'QualityId', oi.QualityId as 'OldQualityId',
							case when ni.Quantity is null then oi.Quantity else oi.Quantity - ni.Quantity end as 'Quantity'
						from @oldItems oi 
							left join @newItems ni on oi.Sku = ni.Sku and oi.QualityId = ni.QualityId and oi.OldQualityId = ni.OldQualityId
						where (ni.Quantity is not null and oi.Quantity > ni.Quantity) or ni.Quantity is null
						union all
						-- Если есть старая и есть новая, но кол-во новой больше
						select	
							oi.ProductId, oi.Sku, oi.QualityId as 'QualityId', oi.OldQualityId as 'OldQualityId',
							ni.Quantity - oi.Quantity as 'Quantity'
						from @oldItems oi 
							join @newItems ni on oi.Sku = ni.Sku and oi.QualityId = ni.QualityId and oi.OldQualityId = ni.OldQualityId
						where oi.Quantity < ni.Quantity
						union all
						-- Новые позиции
						select	ni.ProductId, ni.Sku, ni.QualityId as 'QualityId', ni.OldQualityId as 'OldQualityId',
								ni.Quantity as 'Quantity'
						from @newItems ni 
							left join @oldItems oi on oi.Sku = ni.Sku and oi.QualityId = ni.QualityId and oi.OldQualityId = ni.OldQualityId
						where oi.ProductId is null
					) t
					group by t.ProductId, t.Sku, t.QualityId, t.OldQualityId

					-- Выполняем корректировку остатков по соответствующим товарным позициям
					exec CorrectInstockForSkus_v3 @WarehouseId, 3, 5, @oldDocId
				
				end

			end

		end else

		-- Если удаление документа
		if @Operation = 3 begin

			-- Получаем идентификатор документа
			set @oldDocId = (select Id from WmsVerificationDocuments where WarehouseId = @WarehouseId and PublicId = @PublicId)

			set @NewId = @oldDocId

			if @oldDocId is null begin
				if @trancount = 0
					rollback transaction
				set @ErrorMes = 'Удаляемый акт не найден!'
				return 0
			end
			
			-- Объявляем таблицу, для получения списка ранее загруженных позиций
			declare @delItems table 
			(				
				ProductId			uniqueidentifier	not null,				-- Идентификатор товара
				Sku					int					not null,				-- Артикул товара
				Quantity			int					not null,				-- Количество товарных позиций	
				QualityId			int					not null,				-- Качество
				OldQualityId		int					not null default(0)		-- Качество, из которого перешел товар
				primary key (Sku, QualityId, OldQualityId)
			)
			-- Получаем список ранее загруженных позиций
			insert @delItems (ProductId, Sku, QualityId, OldQualityId, Quantity)
			select ProductId, Sku, QualityId, isnull(OldQualityId, 0), sum(Quantity)
			from WmsVerificationDocumentsItems
			where DocId = @oldDocId
			group by ProductId, Sku, QualityId, isnull(OldQualityId, 0)

			-- Архивируем устаревший Документ
			insert WmsVerificationDocumentsArchive (Id, WarehouseId, PublicId, Number, DocType, Operation, CreateDate, AuthorId)	
			select Id, WarehouseId, PublicId, Number, DocType, Operation, CreateDate, AuthorId
			from WmsVerificationDocuments 
			where Id = @oldDocId
			
			-- Обновляем текущий Документ
			update 
				WmsVerificationDocuments
			set 
				Operation = @Operation,				
				AuthorId = @AuthorId
			where 
				Id = @oldDocId

			-- Архивируем Товарные позиции по устаревшему Документу
			insert WmsVerificationDocumentsItemsArchive (Id, DocId, ProductId, Sku, Quantity, QualityId, OldQualityId, CreateDate)
			select Id, DocId, ProductId, Sku, Quantity, QualityId, OldQualityId, CreateDate
			from WmsVerificationDocumentsItems 
			where DocId = @oldDocId
			-- Удаляем Товарные позиции по устаревшему Документу
			delete WmsVerificationDocumentsItems where DocId = @oldDocId

			-- Если таблица товаров не пуста
			if exists (select 1 from #wmsVerificationDocumentItems) begin
	
				-- Определяем артикулы товаров
				update i
				set i.Sku = p.SKU
				from #wmsVerificationDocumentItems i join PRODUCTS p with (nolock) on p.ID = i.ProductId

				-- Создаем записи в таблице Товары по документу
				insert WmsVerificationDocumentsItems (DocId, ProductId, Sku, Quantity, QualityId, OldQualityId)
				select @oldDocId, t.ProductId, t.Sku, t.Quantity, t.QualityId, t.OldQualityId
				from 
				(
					select i.ProductId, i.Sku, sum(i.Quantity) as 'Quantity', QualityId, OldQualityId
					from #wmsVerificationDocumentItems i
					group by i.ProductId, i.Sku, i.QualityId, i.OldQualityId
				) t

			end

			-- Изменение качества
			if @DocType = 3 begin

				-- Заполняем временную таблицу для артикулов, остатки по которым необходимо списать
				insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)
				select	
					i.ProductId, i.Sku, i.OldQualityId, i.QualityId, i.Quantity
				from 
					@delItems i						

				-- Выполняем корректировку остатков в разрезе качества
				exec CorrectInstockForSkus_v3 @WarehouseId, 3, 5, @oldDocId

			end else begin

				-- Заполняем временную таблицу для артикулов, остатки по которым требуют скорректировать
				/*insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)
				select i.ProductId, i.Sku, i.QualityId, 0, sum(i.Quantity) 
				from WmsVerificationDocumentsItems i 
				where i.DocId = @oldDocId
				group by i.ProductId, i.Sku, i.QualityId
				*/
				insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)
				select	
					i.ProductId, i.Sku, i.QualityId, 0, i.Quantity						
				from 
					@delItems i	

				-- Если оприходование
				if @DocType = 1 begin

					-- Выполняем корректировку остатков по соответствующим товарным позициям
					exec CorrectInstockForSkus_v3 @WarehouseId, 2, 5, @oldDocId

				end 
				-- Если Списание
				if @DocType = 2 begin

					-- Выполняем корректировку остатков по соответствующим товарным позициям
					exec CorrectInstockForSkus_v3 @WarehouseId, 1, 5, @oldDocId
				
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
		set @ErrorMes = error_message()
		return 1
	end catch

end
