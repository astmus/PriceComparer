create proc WmsVerificationDocumentEdit_v2 (
	@Operation			int,					-- Операция: 1 - создание, 2 - корректировка, 3 - удаление
	@PublicId			uniqueidentifier,		-- Идентификатор обмена
	@Number				varchar(32),			-- Номер документа
	@DocType			int,					-- Тип документа
												-- 1 - Оприходование
												-- 2 - Списание
												-- 3 - Изменение качества
	@CreateDate			datetime,				-- Дата создания	
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
	
		if @trancount = 0
			begin transaction
		
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

		-- Временная таблица для номеров Заказов клиентов, по которым выполнена отгрузка
		if (not object_id('tempdb..#orderNumbersForCorrectOrdersInstocQuantity') is null) drop table #orderNumbersForCorrectOrdersInstocQuantity
		create table #orderNumbersForCorrectOrdersInstocQuantity (
			Number		int		not null,
			primary key (Number)
		)

		-- Создаем все необходимые временные таблицы --------------------------------------------------------------------
				
		-- Если создание документа
		if @Operation = 1 begin

			-- Проверяем, есть ли в базе данных уже такой документ
			if exists (select 1 from WmsVerificationDocuments where PublicId = @PublicId) begin

				-- Получаем тип документа
				--declare @OldDocType int = (select DocType from WmsVerificationDocuments where PublicId = @PublicId)

				-- Если тип документа не изменился
				--if @OldDocType = @DocType begin
				
					-- Выполняем корректировку остатков по соответствующим товарным позициям				
					exec @result = WmsVerificationDocumentEdit_v2 2, @PublicId, @Number, @DocType, @CreateDate, @AuthorId, @err out
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

				/*end else 
				-- Если тип документа изменился
				begin

					-- Удаляем существующий документ
					exec @result = WmsVerificationDocumentEdit_v2 3, @PublicId, @Number, @DocType, @CreateDate, @AuthorId, @err out
					-- Если не удалось удалить
					if @result = 1 begin
						if @trancount = 0
							rollback transaction
						set @ErrorMes = @err
						return 1
					end

				end*/

			end

			-- Вставляем запись в таблицу Документов
			insert WmsVerificationDocuments (PublicId, Number, DocType, Operation, CreateDate, AuthorId)	
			values(@PublicId, @Number, @DocType, @Operation, @CreateDate, @AuthorId)

			set @newDocId = @@Identity
		
			-- Если таблица товаров не пуста
			if exists (select 1 from #wmsVerificationDocumentItems) begin

				-- Определяем артикулы товаров
				update i
				set i.Sku = p.SKU
				from #wmsVerificationDocumentItems i join PRODUCTS p with (nolock) on p.ID = i.ProductId

				-- Создаем записи в таблице Товары по документу
				insert WmsVerificationDocumentsItems (DocId, ProductId, Sku, Quantity, QualityId, OldQualityId)
				select @newDocId, ProductId, Sku, Quantity, QualityId, OldQualityId
				from #wmsVerificationDocumentItems
								
				-- Если оприходование
				if @DocType = 1 begin

					-- Заполняем временную таблицу для артикулов, остатки по которым требуют увеличить
					insert #skusForInstockCorrect(ProductId, Sku, QualityId, Quantity)
					select ProductId, Sku, QualityId, sum(Quantity) 
					from #wmsVerificationDocumentItems 
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
					
				end

				-- Если Списание
				if @DocType = 2 begin

					-- Заполняем временную таблицу для артикулов, остатки по которым требуют уменьшить
					insert #skusForInstockCorrect(ProductId, Sku, QualityId, Quantity)
					select ProductId, Sku, QualityId, sum(Quantity) 
					from #wmsVerificationDocumentItems 
					group by ProductId, Sku, QualityId
				
					-- Выполняем корректировку остатков по соответствующим товарным позициям
					exec @result = CorrectInstockForSkus_v2 2
					-- Если корректировка закончилась неудачей, делаем rollback транзакции
					if @result = 1 begin
						if @trancount = 0
							rollback transaction
						set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры CorrectInstockForSkus_v2 (2)!'
						return 1
					end
				
				end

				-- Если Изменение качества
				if @DocType = 3 begin

					-- Заполняем временную таблицу для артикулов, остатки по которым требуют уменьшить
					insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)
					select ProductId, Sku, QualityId, OldQualityId, Quantity
					from #wmsVerificationDocumentItems
				
					-- Выполняем корректировку остатков по соответствующим товарным позициям
					exec @result = CorrectInstockForSkus_v2 3
					-- Если корректировка закончилась неудачей, делаем rollback транзакции
					if @result = 1 begin
						if @trancount = 0
							rollback transaction
						set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры CorrectInstockForSkus_v2 (3)!'
						return 1
					end
				
				end
				
			end

		end else

		-- Если изменение документа
		if @Operation = 2 begin

			-- Получаем идентификатор документа
			set @oldDocId = (select Id from WmsVerificationDocuments where PublicId = @PublicId)

			-- Объявляем таблицу, для получения списка ранее загруженных позиций
			declare @oldItems table (				
				ProductId			uniqueidentifier	not null,	-- Идентификатор товара
				Sku					int					not null,	-- Артикул товара
				Quantity			int					not null,	-- Количество товарных позиций	
				QualityId			int					not null,	-- Качество
				OldQualityId		int					null		-- Качество, из которого перешел товар
			)
			-- Получаем список ранее загруженных позиций
			insert @oldItems (ProductId, Sku, QualityId, OldQualityId, Quantity)
			select ProductId, Sku, QualityId, OldQualityId, sum(Quantity)
			from WmsVerificationDocumentsItems
			where DocId = @oldDocId
			group by ProductId, Sku, QualityId, OldQualityId
			
			--select * from @oldItems

			-- Архивируем устаревший Документ
			insert WmsVerificationDocumentsArchive (Id, PublicId, Number, DocType, Operation, CreateDate, AuthorId)	
			select Id, PublicId, Number, DocType, Operation, CreateDate, AuthorId
			from WmsVerificationDocuments where Id = @oldDocId
			
			-- Архивируем Товарные позиции по устаревшему Документу
			insert WmsVerificationDocumentsItemsArchive (Id, DocId, ProductId, Sku, Quantity, QualityId, OldQualityId, CreateDate)
			select Id, DocId, ProductId, Sku, Quantity, QualityId, OldQualityId, CreateDate
			from WmsVerificationDocumentsItems where DocId = @oldDocId

			-- Удаляем Товарные позиции по устаревшему Документу
			delete WmsVerificationDocumentsItems where DocId = @oldDocId

			-- Обновляем текущий Документ
			update WmsVerificationDocuments
			set Operation = @Operation,				
				AuthorId = @AuthorId
			where Id = @oldDocId

			-- Если таблица товаров не пуста
			if exists (select 1 from #wmsVerificationDocumentItems) begin

				-- Определяем артикулы товаров
				update i
				set i.Sku = p.SKU
				from #wmsVerificationDocumentItems i join PRODUCTS p with (nolock) on p.ID = i.ProductId
				
				-- Объявляем таблицу, для получения текущего списка позиций
				declare @newItems table (				
					ProductId			uniqueidentifier	not null,	-- Идентификатор товара
					Sku					int					not null,	-- Артикул товара
					Quantity			int					not null,	-- Количество товарных позиций	
					QualityId			int					not null,	-- Качество
					OldQualityId		int					null		-- Качество, из которого перешел товар
				)
				-- Получаем список текущих позиций
				insert @newItems (ProductId, Sku, QualityId, OldQualityId, Quantity)
				select ProductId, Sku, QualityId, OldQualityId, sum(Quantity)
				from #wmsVerificationDocumentItems 
				group by ProductId, Sku, QualityId, OldQualityId

				--select * from @newItems

				-- Создаем записи в таблице Товары по документу
				insert WmsVerificationDocumentsItems (DocId, ProductId, Sku, Quantity, QualityId, OldQualityId)				
				select @oldDocId, ProductId, Sku, Quantity, QualityId, OldQualityId
				from #wmsVerificationDocumentItems i

				-- Если оприходование
				if @DocType = 1 begin

					-- Заполняем временную таблицу для артикулов, остатки по которым необходимо списать
					insert #skusForInstockCorrect(ProductId, Sku, QualityId, Quantity)
					select	oi.ProductId, oi.Sku, oi.QualityId, 
							case when ni.Quantity is null then oi.Quantity else oi.Quantity - ni.Quantity  end
					from @oldItems oi 
						left join @newItems ni on oi.Sku = ni.Sku and oi.QualityId = ni.QualityId
					where (ni.Quantity is not null and oi.Quantity > ni.Quantity) or ni.Quantity is null
					
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
					select ni.ProductId, ni.Sku, ni.QualityId, case when oi.Quantity is null then ni.Quantity else ni.Quantity - oi.Quantity end
					from @newItems ni 
						left join @oldItems oi on ni.Sku = oi.Sku and oi.QualityId = ni.QualityId
					where (oi.Quantity is not null and ni.Quantity > oi.Quantity) or oi.Quantity is null
								
					-- Выполняем корректировку остатков по соответствующим товарным позициям
					exec @result = CorrectInstockForSkus_v2 1
					-- Если корректировка закончилась неудачей, делаем rollback транзакции
					if @result = 1 begin
						if @trancount = 0
							rollback transaction
						set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры CorrectInstockForSkus_v2 (1)!'
						return 1
					end

				end

				-- Если списание
				if @DocType = 2 begin

					-- Заполняем временную таблицу для артикулов, остатки по которым необходимо списать
					insert #skusForInstockCorrect(ProductId, Sku, QualityId, Quantity)
					select	oi.ProductId, oi.Sku, oi.QualityId, 
							case when ni.Quantity is null then oi.Quantity else oi.Quantity - ni.Quantity  end
					from @oldItems oi 
						left join @newItems ni on oi.Sku = ni.Sku and oi.QualityId = ni.QualityId
					where (ni.Quantity is not null and oi.Quantity > ni.Quantity) or ni.Quantity is null
							
					--select * from #skusForInstockCorrect
								
					-- Выполняем корректировку остатков по соответствующим товарным позициям
					exec @result = CorrectInstockForSkus_v2 1
					-- Если корректировка закончилась неудачей, делаем rollback транзакции
					if @result = 1 begin
						if @trancount = 0
							rollback transaction
						set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры CorrectInstockForSkus_v2 (1)!'
						return 1
					end

					-- Очищаем временную таблицу 
					delete #skusForInstockCorrect

					-- Заполняем временную таблицу для артикулов, остатки по которым необходимо увеличить
					insert #skusForInstockCorrect(ProductId, Sku, QualityId, Quantity)
					select	ni.ProductId, ni.Sku, ni.QualityId,
							case when oi.Quantity is null then ni.Quantity else ni.Quantity - oi.Quantity end
					from @newItems ni 
						left join @oldItems oi on ni.Sku = oi.Sku and oi.QualityId = ni.QualityId
					where (oi.Quantity is not null and ni.Quantity > oi.Quantity) or oi.Quantity is null
								
					--select * from #skusForInstockCorrect

					-- Выполняем корректировку остатков по соответствующим товарным позициям
					exec @result = CorrectInstockForSkus_v2 2
					-- Если корректировка закончилась неудачей, делаем rollback транзакции
					if @result = 1 begin
						if @trancount = 0
							rollback transaction
						set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры CorrectInstockForSkus_v2 (2)!'
						return 1
					end

				end

				-- Если Изменение качества
				if @DocType = 3 begin
								
					-- Заполняем временную таблицу	
					insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)					
					select t.ProductId, t.Sku, t.QualityId, t.OldQualityId, sum(t.Quantity)
					from
					(
						-- Если есть старая, но нет новой или есть старая и есть новая, но кол-во новой меньше
						select	oi.ProductId, oi.Sku, oi.OldQualityId as 'QualityId', oi.QualityId as 'OldQualityId',
								case when ni.Quantity is null then oi.Quantity else oi.Quantity - ni.Quantity end as 'Quantity'
						from @oldItems oi 
							left join @newItems ni on oi.Sku = ni.Sku and oi.QualityId = ni.QualityId and oi.OldQualityId = ni.OldQualityId
						where (ni.Quantity is not null and oi.Quantity > ni.Quantity) or ni.Quantity is null
						union all
						-- Если есть старая и есть новая, но кол-во новой больше
						select	oi.ProductId, oi.Sku, oi.QualityId as 'QualityId', oi.OldQualityId as 'OldQualityId',
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
				
					--select * from #skusForInstockCorrect

					-- Выполняем корректировку остатков по соответствующим товарным позициям
					exec @result = CorrectInstockForSkus_v2 3
					-- Если корректировка закончилась неудачей, делаем rollback транзакции
					if @result = 1 begin
						if @trancount = 0
							rollback transaction
						set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры CorrectInstockForSkus_v2 (3)!'
						return 1
					end
				
				end
				
			end

		end else

		-- Если удаление документа
		if @Operation = 3 begin

			-- Получаем идентификатор документа
			set @oldDocId = (select Id from WmsVerificationDocuments where PublicId = @PublicId)

			if @oldDocId is null begin
				if @trancount = 0
					rollback transaction
				set @ErrorMes = 'Удаляемый акт не найден!'
				return 0
			end
			
			-- Архивируем устаревший Документ
			insert WmsVerificationDocumentsArchive (Id, PublicId, Number, DocType, Operation, CreateDate, AuthorId)	
			select Id, PublicId, Number, DocType, Operation, CreateDate, AuthorId
			from WmsVerificationDocuments 
			where Id = @oldDocId
			
			-- Обновляем текущий Документ
			update WmsVerificationDocuments
			set Operation = @Operation,				
				AuthorId = @AuthorId
			where Id = @oldDocId

			-- Если таблица товаров не пуста
			if exists (select 1 from WmsVerificationDocumentsItems where DocId = @oldDocId) begin
	
				-- Изменение качества
				if @DocType = 3 begin

					-- Заполняем временную таблицу для артикулов, остатки по которым требуют скорректировать
					insert #skusForInstockCorrect(ProductId, Sku, QualityId, OldQualityId, Quantity)
					select i.ProductId, i.Sku, i.OldQualityId, i.QualityId, sum(i.Quantity)
					from WmsVerificationDocumentsItems i
					where i.DocId = @oldDocId
					group by i.ProductId, i.Sku, i.QualityId, i.OldQualityId

					-- Выполняем корректировку остатков в разрезе качества
					exec @result = CorrectInstockForSkus_v2 3
					-- Если корректировка закончилась неудачей, делаем rollback транзакции
					if @result = 1 begin
						if @trancount = 0
							rollback transaction
						set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры CorrectInstockForSkus_v2 (3)!'
						return 1
					end

				end else begin
					
					-- Заполняем временную таблицу для артикулов, остатки по которым требуют скорректировать
					insert #skusForInstockCorrect(ProductId, Sku, QualityId, Quantity)
					select i.ProductId, i.Sku, i.QualityId, sum(i.Quantity) 
					from WmsVerificationDocumentsItems i 
					where i.DocId = @oldDocId
					group by i.ProductId, i.Sku, i.QualityId

					-- Если оприходование
					if @DocType = 1 begin

						-- Выполняем корректировку остатков по соответствующим товарным позициям
						exec @result = CorrectInstockForSkus_v2 2
						-- Если корректировка закончилась неудачей, делаем rollback транзакции
						if @result = 1 begin
							if @trancount = 0
								rollback transaction
							set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры CorrectInstockForSkus_v2 (2)!'
							return 1
						end

					end 
					-- Если Списание
					if @DocType = 2 begin

						-- Выполняем корректировку остатков по соответствующим товарным позициям
						exec @result = CorrectInstockForSkus_v2 1
						-- Если корректировка закончилась неудачей, делаем rollback транзакции
						if @result = 1 begin
							if @trancount = 0
								rollback transaction
							set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры CorrectInstockForSkus_v2 (1)!'
							return 1
						end
				
					end

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
		set @ErrorMes = 'Ошибка во время выполнения хранимой процедуры WmsVerificationDocumentEdit_v2!'
		return 1
	end catch

end
