create proc WmsShipmentOrderDocumentsView
(
	@Number			varchar(50),			-- Номер документа
	@DateFrom		date,					-- Дата создания с
	@DateTo			date,					-- Дата создания до
	@Direction		int,					-- Направление отгрузки
	@Status			int						-- Статус
) as
begin

	-- Если указан номер документа
	if @Number is not null begin
		
		select	d.Id as 'DocId', d.Number as 'Number', d.CreateDate as 'CreateDate', d.ReportDate as 'ReportDate',
				d.DocStatus as 'StatusId', d.ShipmentDirection as 'DirectionId', d.AuthorId as 'AuthorId',
				d.Comments as 'Comments', d.ClientId as 'ClientId', d.ImportanceLevel as 'ImportanceLevel',
				d.IsDeleted as 'IsDeleted', d.IsPartial as 'IsPartial', d.IsShipped as 'IsShipped',
				d.RouteId as 'RouteId', d.ShipmentDate as 'ShipmentDate', d.OrderSource as 'OrderSource', d.PublicId as 'PublicId',
				st.Name as 'StatusName', dir.Name as 'DirectionName', a.NAME as 'AuthorName'
		from WmsShipmentOrderDocuments d
			join WmsShipmentOrderDocumentDirections dir on d.ShipmentDirection = dir.Id
			join WmsShipmentOrderDocumentStatuses st on d.DocStatus = st.Id
			join USERS a on d.AuthorId = a.ID
		where d.Number like ('%' + @Number + '%')

	end else begin

		select	d.Id as 'DocId', d.Number as 'Number', d.CreateDate as 'CreateDate', d.ReportDate as 'ReportDate',
				d.DocStatus as 'StatusId', d.ShipmentDirection as 'DirectionId', d.AuthorId as 'AuthorId',
				d.Comments as 'Comments', d.ClientId as 'ClientId', d.ImportanceLevel as 'ImportanceLevel',
				d.IsDeleted as 'IsDeleted', d.IsPartial as 'IsPartial', d.IsShipped as 'IsShipped',
				d.RouteId as 'RouteId', d.ShipmentDate as 'ShipmentDate', d.OrderSource as 'OrderSource', d.PublicId as 'PublicId',
				st.Name as 'StatusName', dir.Name as 'DirectionName', a.NAME as 'AuthorName'
		from WmsShipmentOrderDocuments d
			join WmsShipmentOrderDocumentDirections dir on d.ShipmentDirection = dir.Id
			join WmsShipmentOrderDocumentStatuses st on d.DocStatus = st.Id
			join USERS a on d.AuthorId = a.ID
		where	(@DateFrom is null or (@DateFrom is not null and d.CreateDate >= @DateFrom))			and
				(@DateTo is null or (@DateTo is not null and d.CreateDate <= @DateTo))					and
				(@Direction is null or (@Direction is not null and d.ShipmentDirection = @Direction))	and
				(@Status is null or (@Status is not null and d.DocStatus = @Status))
		order by d.CreateDate desc

	end
		
end
