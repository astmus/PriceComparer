create proc WmsShipmentOrderDocumentHistoryView
(
	@DocId			bigint			-- Идентификатор документа
) as
begin
		
	select	d.Id as 'DocId', d.Number as 'Number', d.CreateDate as 'CreateDate', d.ReportDate as 'ChangedDate',
			d.DocStatus as 'StatusId', d.ShipmentDirection as 'DirectionId', d.AuthorId as 'AuthorId',			
			d.IsDeleted as 'IsDeleted', d.IsPartial as 'IsPartial', d.IsShipped as 'IsShipped',
			st.Name as 'StatusName', dir.Name as 'DirectionName', a.NAME as 'AuthorName'
	from WmsShipmentOrderDocumentsArchive d
		join WmsShipmentOrderDocumentDirections dir on d.ShipmentDirection = dir.Id
		join WmsShipmentOrderDocumentStatuses st on d.DocStatus = st.Id
		join USERS a on d.AuthorId = a.ID
	where d.Id = @DocId
	order by d.ArchiveDate desc
		
end
