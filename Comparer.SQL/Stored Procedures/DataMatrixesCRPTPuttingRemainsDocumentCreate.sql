create proc DataMatrixesCRPTPuttingRemainsDocumentCreate
(
	@ContractorId				int,					-- Идентификатор контрагента
	
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

		-- 0.1 Подготавливаем Info данные документа
	declare
		@ActionId					int				= 1		-- Причина ввода маркировки в оборот 
	

	declare @trancount int
	select @trancount = @@trancount

	begin try

		-- 0.2 Удаляем маркировку, которая уже находится в обороте, согласно ЦРПТ
		delete dm
		from #dataMatrixesForCRPTPutting dm
			join _DataMatrixesApi dmapi on dm.DataMatrix = dmapi.DataMatrix
		where dmapi.Status = 'INTRODUCED'

		if not exists (select 1 from #dataMatrixesForCRPTPutting) begin

			set @ErrorMes = 'Все полученные маркировки уже в обороте в ЦРПТ!'
			return 1
		end

	end try
	begin catch
		set @ErrorMes = error_message()
		return 1
	end catch

	begin try

		if @trancount = 0
			begin transaction

	-- 1.0 Создание документа на ввод маркировки в оборот
		insert DataMatrixCRPTPuttingDocuments (
			ActionId,
			ContractorId, 
			StatusId,
			CRPTType,
			AuthorId
			)
		select distinct
			@ActionId, 
			@ContractorId, 
			2,
			'LP_INTRODUCE_OST',
			@AuthorId
		from 
			#dataMatrixesForCRPTPutting temp

		set @NewId = @@identity

	-- 2.0 Создание позиций документа ввода маркировки в оборот
		insert DataMatrixCRPTPuttingDocumentItems ( DocumentId, ProductId, DataMatrix)
		select @NewId, oi.ProductId, dm.DataMatrix
		from #dataMatrixesForCRPTPutting dm
			join SUZOrderItemDataMatrixes oidm on dm.DataMatrix = oidm.DataMatrix
			join SUZOrderItems oi on oi.Id = oidm.ItemId

	-- 3.0 Проверяем, что имеются несопоставленные позиции, помечаем наличие таких позиций
		update d
		set 
			d.StatusId = 3,
			d.Comments = 'Некоторые маркировки не сопоставленны с товарами!'
		from 
			DataMatrixCRPTPuttingDocuments d
		where
			d.ID = @NewId and 
			exists (
				select 1 from DataMatrixCRPTPuttingDocumentItems i where i.DocumentId = @NewId and i.ProductId is null
			)

	-- 4.0 Сносим маркировки из очереди на ввод в архив
		insert DataMatrixCRPTPuttingQueueArchive (QueueId, DataMatrix)
		select q.Id, q.DataMatrix
		from #dataMatrixesForCRPTPutting dm
			join DataMatrixCRPTPuttingQueue q on q.DataMatrix = dm.DataMatrix

	-- 4.1 Удаляем маркировки из очереди на ввод в архив
		delete q
		from #dataMatrixesForCRPTPutting dm
			join DataMatrixCRPTPuttingQueue q on q.DataMatrix = dm.DataMatrix


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
