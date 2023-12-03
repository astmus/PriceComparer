create proc WmsVerificationDocumentsView_v3
(
	@WarehouseId	int,					-- Идентификатор склада
	@PublicId		uniqueidentifier,		-- Публичный идентификатор документа
	@Number			varchar(36),			-- Номер документа
	@DocType		int,					-- Тип документа
											-- 1 - Оприходование
											-- 2 - Списание
											-- 3 - Изменение качества
	@IsDeleted		bit,					-- Удален
	@DateFrom		date,					-- Дата создания с
	@DateTo			date					-- Дата создания по	
) as
begin

	create table #ids
	(	
		Id		int		not null,
		primary key(Id)
	)

	-- Если указан идентификатор документа
	if @PublicId is not null begin

		insert into #ids (Id)
			select d.Id from WmsVerificationDocuments d where d.PublicId = @PublicId and d.WarehouseId = @WarehouseId

	end else
	if @Number is not null begin

		insert into #ids (Id)
			select d.Id from WmsVerificationDocuments d where d.WarehouseId = @WarehouseId and d.Number like ('%' + @Number + '%')

	end else begin
 
		insert into #ids (Id)
			select
				d.Id
			from
				WmsVerificationDocuments d
			where
				d.WarehouseId = @WarehouseId
				and (@DateFrom is null or (@DateFrom is not null and cast(d.CreateDate as date) >= @DateFrom))						
				and	(@DateTo is null or (@DateTo is not null and cast(d.CreateDate as date) <= @DateTo))
				and (@DocType is null or (@DocType is not null and d.DocType = @DocType))
				and (@IsDeleted is null or (@IsDeleted is not null and d.Operation = 3))
	end

	select
		d.Id							as 'Id', 
		d.WarehouseId					as 'WarehouseId',
		d.PublicId						as 'PublicId', 
		d.Number						as 'Number',
		d.DocType						as 'DocType', 
		case d.DocType
			when 1 then 'Оприходование'
			when 2 then 'Списание'
			when 3 then 'Изменение качества'
			else '?'
		end								as 'DocTypeName',
		d.CreateDate					as 'CreateDate',
		d.Operation						as 'Operation'
	from
		#ids t
		join WmsVerificationDocuments d on t.Id = d.Id
	order by 
		d.CreateDate desc
		
end
