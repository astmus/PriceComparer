create proc WmsShipmentOrderDocumentView
(
	@DocId			bigint,					-- Идентификатор документа
	@OrderId		uniqueidentifier		-- Идентификатор заказа
) as
begin

	-- Если указан номер документа
	if @DocId is not null begin
		
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
		where d.Id = @DocId

	end else 
	if @OrderId is not null begin

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
		where d.PublicId = @OrderId

	end
		
end
