create proc DataMatrixesCRPTPuttingReturnsDocumentCreate
(
	@PublicDocId				uniqueidentifier,		-- Идентификатор документа "Приемка (возврата)"
	@AuthorId					uniqueidentifier,		-- Идентификатор автора
	-- Out-параметры
	@NewId						int out,				-- Идентификатор созданного документа
	@ErrorMes					nvarchar(4000) out		-- Сообщение об ошибках
)
as
begin

	set nocount on

	set @ErrorMes = ''
	set @NewId = -1
		
	declare
		@ActionId					int					= 2,	-- Причина ввода маркировки в оборот (возврат)
		@ReturnedOrderId			uniqueidentifier,	
		@ContractorId				int					= 1,	-- ООО Мегапарфюме
		@WmsDocId					bigint,						-- Идентификатор документа приемки в WMS
		@PrimaryDocumentDate 		datetime,					-- Дата первичного документа 
		@PrimaryDocumentNumber		nvarchar(128),				-- Номер первичного документа 
		@PrimaryDocumentTypeId		int,						-- Тип первичного документа 
		@PrimaryDocumentName		nvarchar(255)				-- Наименование первичного документа !!! Обязательно, если в поле «Вид первичного документа» указано "Прочее"(3) !!!

	-- 1. Выполняем проверку
	begin try
	
		-- Если документ не найден	
		if not exists (select 1 from WmsReceiptDocuments d where d.DocSource = 2 and d.PublicId = @PublicDocId) begin

			set @ErrorMes = 'Receipt is not found!'
			return 1

		end
		
		select 
			@ReturnedOrderId		= d.ReturnedOrderId,
			@WmsDocId				= d.Id,	
			@PrimaryDocumentDate	= d.WmsCreateDate,
			@PrimaryDocumentNumber	= d.Number
		from 
			WmsReceiptDocuments d
		where 
			d.PublicId = @PublicDocId

		-- Если заказ не определен
		if @ReturnedOrderId is null or @ReturnedOrderId = '00000000-0000-0000-0000-000000000000' begin

			set @ErrorMes = 'OrderId is undefined!'
			return 1

		end

		set @PrimaryDocumentTypeId	= 3  --  'OTHER' (У нас проходит приемка возврата)
		set @PrimaryDocumentName = 'Возврат заказа ' + @PrimaryDocumentNumber

		-- Если нет маркировки, которую необходимо ввести в оборот
		create table #puttingDataMatrixes
		(
			DataMatrix			nvarchar(31)			not null,				-- Маркировка	
			ProductId			uniqueidentifier		not null,				-- Идентификатор товара
			primary key (DataMatrix)	
		)
		insert #puttingDataMatrixes (DataMatrix, ProductId)
		select distinct dm.DataMatrix, d.ProductId
			from 
				WmsReceiptDocumentsItemDataMatrixes d
					join DataMatrixes dm on dm.DataMatrix = substring(d.DataMatrix, 1, 31)
					left join SUZOrderItemDataMatrixes s on d.DataMatrix = substring(s.DataMatrix, 1, 31)
					left join DataMatrixCRPTPuttingDocuments pd on d.DocId = pd.WMSDocumentId
					left join DataMatrixCRPTPuttingDocumentItems pdi on pdi.DocumentId = pd.Id and pdi.ProductId = d.ProductId
																	and pdi.DataMatrix = dm.DataMatrix -- смотрим, что маркировка не вводилась документами в оборот
					left join #puttingDataMatrixes pm on pm.ProductId = d.ProductId and pm.DataMatrix = dm.DataMatrix
			where 
				d.DocId = @WmsDocId
				and dm.StatusId = 2  -- Выбыл
				and s.Id is null
				and pdi.DataMatrix is null
				and pm.DataMatrix is null


		if not exists (select 1 from #puttingDataMatrixes) 
		begin
			delete b
			from WmsReceiptDocumentsItemDataMatrixes idm
				join DataMatrixes dm on idm.DataMatrix = dm.DataMatrix
				join DataMatrixesBuffer b on idm.DataMatrix = b.DataMatrix
			where
				b.DataMatrix is not null
				and dm.StatusId = 1
				
			--set @ErrorMes = 'There are no dataMatrixes to input!'
			return 0

		end

	end try
	begin catch
		set @ErrorMes = error_message()
		return 1
	end catch

	declare @trancount int
	select @trancount = @@trancount

	-- 2. Создание документа на ввод маркировки в оборот
	begin try

		if @trancount = 0
			begin transaction
	
		-- Документ
		insert DataMatrixCRPTPuttingDocuments 
		(
			ActionId,	
			PrimaryDocumentDate,
		    PrimaryDocumentNumber,
		    PrimaryDocumentTypeId,
		    PrimaryDocumentName, 	
			WMSDocumentId,

			ContractorId, 
			StatusId,
			CRPTType,

			AuthorId
		)
		values
		(
			@ActionId, 
			@PrimaryDocumentDate, 
			@PrimaryDocumentNumber, 
			@PrimaryDocumentTypeId, 
			@PrimaryDocumentName, 		
			@WmsDocId,
				
			@ContractorId, 
			2,
			'LP_RETURN',

			@AuthorId
		)

		set @NewId = @@identity

		-- Позиции
		insert DataMatrixCRPTPuttingDocumentItems (DocumentId, ProductId, DataMatrix)
		select
			@NewId, pdm.ProductId, pdm.DataMatrix
		from 
			#puttingDataMatrixes pdm

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
