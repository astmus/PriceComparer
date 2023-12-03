create proc WmsExpectedReceiptDocumentsView_v3
(
	@WarehouseId			int,					-- Идентификатор склада
	@PublicId				uniqueidentifier,		-- Публичный идентификатор документа
	@Number					varchar(36),			-- Номер документа	
	@DocSource				int,					-- Источник поступления товара
	@DocStatus				int,					-- Статус документа
	@DateFrom				date,					-- Дата создания с
	@DateTo					date,					-- Дата создания до
	@ReturnedOrderNumber	varchar(36),			-- Публичный номер возвращенного заказа
	@PurchaseCode			bigint					-- Номер задания на закупку
) as
begin

	create table #ids
	(	
		Id		int		not null
		primary key(Id)
	)

	-- Если указан Идентификатор документа
	if @PublicId is not null begin

		insert into #ids (Id)
			select d.Id from WmsExpectedReceiptDocuments d where d.WarehouseId = @WarehouseId and d.PublicId = @PublicId

	end else
	-- Если указан Номер документа
	if @Number is not null begin

		insert into #ids (Id)
			select d.Id FROM WmsExpectedReceiptDocuments d where d.WarehouseId = @WarehouseId and d.Number like ('%' + @Number + '%')

	end else
	-- Если указан Публичный номер возвращенного заказа
	if @ReturnedOrderNumber is not null begin

		declare
			@ReturnedOrderId uniqueidentifier = null
		
		select @ReturnedOrderId = o.ID from CLIENTORDERS o where o.PUBLICNUMBER = @ReturnedOrderNumber

		insert into #ids (Id)
			select d.Id from WmsExpectedReceiptDocuments d where d.WarehouseId = @WarehouseId and d.SourceDocumentId = @ReturnedOrderId
	
	end else
	-- Если указан Номер задания на закупку
	if @PurchaseCode is not null begin

		insert into #ids (Id)
			select d.Id from WmsExpectedReceiptDocuments d where d.WarehouseId = @WarehouseId and d.Number = 'crm-' + cast(@PurchaseCode as varchar(25))
			
	end else begin

		insert into #ids (Id)
			select
				d.Id
			from
				WmsExpectedReceiptDocuments d
			where
				d.WarehouseId = @WarehouseId
				and (@DateFrom is null or (@DateFrom is not null and cast(d.CreateDate as date) >= @DateFrom))						
				and	(@DateTo is null or (@DateTo is not null and cast(d.CreateDate as date) <= @DateTo))
				and (@DocSource is null or (@DocSource is not null and d.DocSource = @DocSource))
				and (@DocStatus is null or (@DocStatus is not null and d.DocStatus = @DocStatus))

	end

	select
		d.Id							as 'Id', 
		d.PublicId						as 'PublicId',
		d.Number						as 'Number',
		d.CreateDate					as 'CreateDate', 
		d.WmsCreateDate					as 'WmsCreateDate',
		d.DocSource						as 'DocSource',
		case d.DocSource
			when 1 then 'Приемка от поставщиков'
			when 2 then 'Приемка возвратов от клиентов'
			when 3 then 'Перемещение из оптовой точки'
			when 4 then 'Приемка парфюмерных пробников в зоне розлива'
			else '?'
		end								as 'SourceName',
		d.Comments						as 'Comments', 
		d.DocStatus						as 'DocStatus',
		case d.DocStatus
			when 1 then 'Новая'
			when 2 then 'К выполнению'
			when 3 then 'В работе'
			when 4 then 'Принята'
			when 5 then 'Заблокирована'
			when 6 then 'Размещена'
			else '?'
		end								as 'DocStatusName',
		d.IsDeleted						as 'IsDeleted'
	from
		#ids t
		join WmsExpectedReceiptDocuments d on t.Id = d.Id
	order by 
		d.CreateDate desc

		
end
