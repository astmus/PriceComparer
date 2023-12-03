create proc CRPTDocumentCreate
(
	-- Базовый документ
	@CRPTNumber					nvarchar(500),		-- Номер документа в ЦРПТ
	@CRPTInput					bit,				-- Входящий документ
	@CRPTCreatedDate			dateTime,			-- Дата создания документа в ЦРПТ
	@CRPTType					varchar(128),		-- Тип документа в ЦРПТ
	@CRPTStatus					varchar(128),		-- Статус документа в ЦРПТ
	@SenderInn					varchar(20),		-- ИНН отправителя
	@ReceiverInn				varchar(20),		-- ИНН получателя
	-- Документ
	@DocNumber					nvarchar(128),		-- Номер документа
	@DocDate					date,				-- Дата документа
	@DocAction					nvarchar(128),		-- Причина вывода из оборота (для типа документов LK_RECEIPT)
	@DocActionDate				dateTime,			-- Дата вывода из оборота
	@DocPrimaryType				nvarchar(64),		-- Тип первичного документа
	@DocTypeName				nvarchar(255),		-- Наименование типа документа в случае, если DocPrimaryType = OTHER (к примру, Заказ)
	-- Внутренняя информация
	@SenderId					int,				-- Идентификатор контрагента-отправителя
	@ReceiverId					int,				-- Идентификатор контрагента-получателя
	@StatusId					int,				-- Статус документа
	@Comments					nvarchar(255),		-- Комментарий
	-- Служебная информация	
	@Error					    nvarchar(4000),		-- Сообщение об ошибке
	@AuthorId					uniqueidentifier,	-- Идентификатор автора
	-- Out-параметры
	@NewId						int out,			-- Идентификатор созданного документа
	@ErrorMes					nvarchar(4000) out	-- Сообщение об ошибках
)
as
begin

	set nocount on

	set @ErrorMes = ''
	set @NewId = -1

	declare @res int= -1

	declare @trancount int
	select @trancount = @@trancount
	
	-- 0.1.1 Создаем временную таблицу для передачи маркировки
		
	create table #Recs
	(	
		SourceId			int,
		SourceDocumentId	varchar(64),
		ContractorId		int,
		DataMatrix			nvarchar(128),
		ProductId			uniqueidentifier,
		IsInWMS				bit,
		Comments			nvarchar(1000)
	)

	begin try

		-- 1. Подготовительный этап

		-- 0.1 Если идентификатор отправителя не определен

		if @SenderId is null and @SenderInn is not null begin

			select @SenderId = Id from Contractors c where c.Inn = @SenderInn

		end

		-- 0.2 Если идентификатор получателя не определен

		if @ReceiverId is null and @ReceiverInn is not null begin

			select @ReceiverId = Id from Contractors c where c.Inn = @ReceiverInn

		end

		if @SenderInn is null
			select @SenderInn = ''

		if @ReceiverInn is null
			select @ReceiverInn = ''

	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch
	
	-- 1.1 Проверяем существует ли документ

	if exists (select 1 from CRPTDocuments d where d.CRPTNumber = @CRPTNumber) begin

		if exists (
				select 1 
				from 
					CRPTDocuments d 
				where 
					d.CRPTNumber = @CRPTNumber and (d.CRPTStatus <> @CRPTStatus or d.Error <> @Error) 
				) 
		begin

			begin try

				if @trancount = 0
					begin transaction

					-- 1.1 Обновление документа
					update d
					set
						d.CRPTStatus	= @CRPTStatus,
						d.StatusId		= @StatusId,
						d.Error			= @Error,
						d.ChangedDate	= getdate()
					from CRPTDocuments d
					where
						d.CRPTNumber = @CRPTNumber

					/*if (@StatusId = 1) begin

						if (@CRPTType in ('LP_ACCEPT_GOODS', 'LP_INTRODUCE_OST')
							or (@CRPTType = 'UNIVERSAL_TRANSFER_DOCUMENT' and exists (select 1 from Contractors c where c.Id = @ReceiverId and c.TypeId = 1)) 
							) begin


							-- 2.1 Добавляем маркировку на остатки

							-- 2.1.2 Получаем идентификатор документа
							declare @curInvoiceId int = (select Id from CRPTDocuments where CRPTNumber = @CRPTNumber)

							-- 2.1.3 Заполняем временную таблицу для передачи маркировки

							insert #Recs 
							(
								SourceId, SourceDocumentId, ContractorId, 
								DataMatrix, ProductId, 
								IsInWMS, Comments
							)
							select
								4, cast(@curInvoiceId as varchar(64)), iif(@CRPTInput = 1, @SenderId, @SenderId),
								i.DataMatrix, i.ProductId,
								null, null
							from 
								#Items i

							-- 2.2.3 Выполняем создание маркировки на остатках (таблица DataMatrixesReceive)
							exec @res = DataMatrixesReceiveCreate @AuthorId, @ErrorMes out
							if @res = 1 begin
								if @trancount = 0
									rollback transaction
								return 1
							end
						end

					end*/
			
				if @trancount = 0
					commit transaction

			end try
			begin catch		
				if @trancount = 0
					rollback transaction
				set @ErrorMes = error_message()
				return 1
			end catch

		end else begin

			set @ErrorMes = 'Документ с указанным номером уже существует!'

		end
			
		return 0

	end

	begin try

		-- 1.2 Проверяем, что уже получен первичный документ из ЭДО
		declare @DocumentEdoId int  = null
		select @DocumentEdoId = Id from EdoInvoices i where i.FileId = @CRPTNumber

		-- 1.3 Проверяем есть ли записи
		/*
		if not exists (select 1 from #Items) begin
				set @ErrorMes = 'Отсутствует содержимое документа!'
			return 1

		end
		*/

		-- 1.4 Проверяем есть ли записи с ProductId = NULL

		if exists (select 1 from #Items where ProductId is null) begin

			-- 1.3.1 Создаем временную таблицу для передачи штрих-кодов

			create table #Barcodes
			(	
				Barcode				nvarchar (128)		not null		-- Штрих-код
			)
			
			-- 1.3.2 Заполняем таблицу штрих-кодами

			insert #Barcodes (Barcode)
			select 
				dbo.ParseBarCodeFromDataMatrix(i.DataMatrix)
			from 
				#Items i
			where 
				i.ProductId is null

			-- 1.3.3 Создаем временную таблицу для 
			-- получения штрих-кодов и идентификаторов товаров

			create table #BarcodesWithProductIds
			(	
				Barcode				nvarchar (128)		not null,		-- Штрих-код
				ProductId			uniqueidentifier		null,		-- Идентификатор товара
			)

			-- 1.3.4 Выполняем поиск идентификаторов товаров

			exec ProductIdsByBarcodesView

			-- 1.3.5 Если идентификоры товаров найдены,
			-- обновляем ProductId

			if exists (select 1 from #BarcodesWithProductIds) begin

				update i
				set
					i.ProductId = p.ProductId
				from
					#Items i
						join #BarcodesWithProductIds p on p.Barcode = dbo.ParseBarCodeFromDataMatrix(i.DataMatrix)

			end
		end

	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

	-- 2. Выполнение операций
	
	begin try

		if @trancount = 0
			begin transaction
			
		-- 2.1 Создаем документ

		insert CRPTDocuments 
		(
			CRPTNumber, CRPTInput, CRPTCreatedDate, CRPTType, CRPTStatus, 
			SenderInn, ReceiverInn, 
			DocNumber, DocDate, DocAction, DocActionDate, DocPrimaryType, DocTypeName, 
			SenderId, ReceiverId, 
			StatusId, Comments, Error, 
			AuthorId
		)
		values
		(
			@CRPTNumber, @CRPTInput, @CRPTCreatedDate, @CRPTType, @CRPTStatus,
			@SenderInn, @ReceiverInn,
			@DocNumber, @DocDate, @DocAction, @DocActionDate, @DocPrimaryType, @DocTypeName,
			@SenderId, @ReceiverId,
			@StatusId, @Comments, @Error,
			@AuthorId
		)
			
		set @NewId = @@identity

		-- 2.2 Создаем содержимое

		if exists (select 1 from #Items) begin

			insert CRPTDocumentItems (DocId, ProductId, ProductName, DataMatrix)
			select @NewId, i.ProductId, isnull(i.ProductName,'?'), i.DataMatrix
			from #Items i

		end

		-- 2.3 Если к данному документу Первичный документ - это УПД из ЭДО
		-- Устанавливаем связь между документом Edo и CRPT
		if (@DocumentEdoId is not null) begin

			insert DocumentEdoCRPTLinks (DocumentEdoId, DocumentCRPTId)
			values (@DocumentEdoId, @NewId)

		end
		
		-- Если документ успешно обработан

		if @StatusId = 1 begin
			
			if (@CRPTType in ('LP_ACCEPT_GOODS', 'LP_SHIP_GOODS', 'LP_SHIP_GOODS_XML', 'LP_INTRODUCE_OST')
				or (@CRPTType = 'UNIVERSAL_TRANSFER_DOCUMENT' and exists (select 1 from Contractors c where c.Id = @ReceiverId and c.TypeId = 1)) 
				) begin

				-- 2.3 Добавляем маркировку на остатки

				-- 2.3.1 Заполняем временную таблицу для передачи маркировки

				insert #Recs 
				(
					SourceId, SourceDocumentId, ContractorId, 
					DataMatrix, ProductId, 
					IsInWMS, Comments
				)
				select
					4, cast(@NewId as varchar(64)), iif(@CRPTInput = 1, @SenderId, @SenderId),
					i.DataMatrix, i.ProductId,
					null, null
				from 
					#Items i

				-- 2.3.2 Выполняем создание маркировки на остатках (таблица DataMatrixesReceive)
				exec @res = DataMatrixesReceiveCreate @AuthorId, @ErrorMes out
				if @res = 1 begin
					if @trancount = 0
						rollback transaction
					return 1
				end
			end
		
		end

		--  Записываем маркировки в очередь
		create table #DataMatrixes
		(	
			DataMatrix		nvarchar (128)		not null		-- Маркировка
		)
		
		insert #DataMatrixes (DataMatrix)
		select i.DataMatrix
		from #Items i
		
		set @res = -1		
		exec @res = DataMatrixesToStatusQueuePut @ErrorMes out
		if @res = 1 begin
			if @trancount = 0
				rollback transaction
			set @ErrorMes = 'DataMatrixesToStatusQueuePut exec error!'
			return 1
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
