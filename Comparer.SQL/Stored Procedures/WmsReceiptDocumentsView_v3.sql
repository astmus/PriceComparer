create proc WmsReceiptDocumentsView_v3
(
	@WarehouseId	int,					-- Идентификатор склада
	@PublicId		uniqueidentifier,		-- Публичный идентификатор документа
	@Number			varchar(50),			-- Номер документа
	@DocSource		int,					-- Идентификатор источника поступления
	@IsDeleted		bit,					-- Удален
	@DateFrom		date,					-- Дата создания с
	@DateTo			date					-- Дата создания до
) AS
BEGIN

	create table #ids
	(	
		Id		int		not null,
		primary key(Id)
	)

	-- Если указан идентификатор документа
	if @PublicId is not null begin

		insert into #ids (Id)
			select d.Id from WmsReceiptDocuments d where d.WarehouseId = @WarehouseId and d.PublicId = @PublicId

	end else
	-- Если указан номер документа
	if @Number is not null begin

		insert into #ids (Id)
			select d.Id FROM WmsReceiptDocuments d where d.WarehouseId = @WarehouseId and d.Number like ('%' + @Number + '%')

	end else begin

		insert into #ids (Id)
			select
				d.Id
			from
				WmsReceiptDocuments d
			where
				d.WarehouseId = @WarehouseId
				and (@DateFrom is null or (@DateFrom is not null and cast(d.CreateDate as date) >= @DateFrom))						
				and	(@DateTo is null or (@DateTo is not null and cast(d.CreateDate as date) <= @DateTo))
				and (@DocSource is null or (@DocSource is not null and d.DocSource = @DocSource))
				and (@IsDeleted is null or (@IsDeleted is not null and d.Operation = 3))

	end

	select
		d.Id					as 'Id', 
		d.WarehouseId			as 'WarehouseId',
		d.PublicId				as 'PublicId', 
		d.Number				as 'Number',
		d.CreateDate			as 'CreateDate', 
		d.WmsCreateDate			as 'WmsCreateDate',
		d.DocSource				as 'DocSource',
		case d.DocSource
			when 1 then 'Приемка от поставщиков'
			when 2 then 'Приемка возвратов от клиентов'
			when 3 then 'Перемещение из оптовой точки'
			when 4 then 'Приемка парфюмерных пробников в зоне розлива'
			else '?'
		end						as 'DocSourceName',
		d.Comments				as 'Comments', 
		d.IsDeleted				as 'IsDeleted'
	from
		#ids t
		JOIN WmsReceiptDocuments d ON t.Id = d.Id
	order by 
	d.CreateDate desc
		
end
