create proc WmsShipmentDocumentsView_v3
(
	@WarehouseId	int,					-- Идентификатор склада
	@PublicId		uniqueidentifier,		-- Публичный идентификатор документа
	@Number			varchar(50),			-- Номер документа
	@StatusId		int,					-- Идентификатор статуса
	@DirectionId	int,					-- Идентификатор направления отгрузки
	@IsDeleted		bit,					-- Удален
	@DateFrom		date,					-- Дата создания с
	@DateTo			date					-- Дата создания до
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
			select d.Id from WmsShipmentDocuments d where d.WarehouseId = @WarehouseId and d.PublicId = @PublicId

	end else
	-- Если указан номер документа
	if @Number is not null begin

		insert into #ids (Id)
			select d.Id from WmsShipmentDocuments d where d.WarehouseId = @WarehouseId and d.Number like ('%' + @Number + '%')

	end else begin

		insert into #ids (Id)
			select
				d.Id
			from
				WmsShipmentDocuments d
			where
				d.WarehouseId = @WarehouseId
				and (@DateFrom is null or (@DateFrom is not null and cast(d.CreateDate as date) >= @DateFrom))			
				and	(@DateTo is null or (@DateTo is not null and cast(d.CreateDate as date) <= @DateTo))
				and (@DirectionId is null or (@DirectionId is not null and d.ShipmentDirection = @DirectionId))
				and (@StatusId is null or (@StatusId is not null and d.DocStatus = @StatusId))
				and (@IsDeleted is null or (@IsDeleted is not null and d.Operation = 3))

	end

	select
		d.Id						as 'Id', 
		d.WarehouseId				as 'WarehouseId',
		d.PublicId					as 'PublicId', 
		d.Number					as 'Number',
		d.CreateDate				as 'CreateDate', 
		d.WmsCreateDate				as 'WmsCreateDate', 
		d.ShipmentDate				as 'ShipmentDate',
		d.ShipmentDirection			as 'DirectionId', 
		d.DocStatus					as 'StatusId', 
		d.RouteId					as 'RouteId',
		d.Comments					as 'Comments', 
		d.IsDeleted					as 'IsDeleted',
		isnull(st.[Name], '?')		as 'StatusName',
		isnull(dir.[Name], '?')		as 'DirectionName'
	from
		#ids t
		join WmsShipmentDocuments d on t.Id = d.Id
		left join WmsShipmentOrderDocumentDirections dir on d.ShipmentDirection = dir.Id
		left join WmsShipmentOrderDocumentStatuses st on d.DocStatus = st.Id
	order by 
		d.CreateDate desc
				
end
