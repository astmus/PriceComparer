create proc WMSShipmentDocumentView_v3
(
	@Id			bigint,				-- Идентификатор документа
	@PublicId	uniqueidentifier	-- Публичный идентификатор документа
) as
begin
	
	declare
		@DocId	bigint	= @Id

	if @Id is null
		select @DocId = Id from WmsShipmentDocuments where PublicId = @PublicId

	-- Документ
	select
		d.Id						as 'Id',
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
		st.[Name]					as 'StatusName',
		dir.[Name]					as 'DirectionName'
	from
		WmsShipmentDocuments d 
		join WmsShipmentOrderDocumentDirections dir on d.ShipmentDirection = dir.Id
		join WmsShipmentOrderDocumentStatuses st on d.DocStatus = st.Id
	where 
		d.Id = @DocId

	-- Позиции			
	select
		i.Id					as 'Id',
		i.DocId					as 'DocId',
		i.ProductId				as 'ProductId', 
		i.Sku					as 'Sku',
		i.Quantity				as 'Quantity', 
		i.QualityId				as 'QualityId',
		isnull(q.[Name], '?')	as 'QualityName',
		m.[NAME]				as 'BrandName',
		'p.FullName'				as 'ProductName'
	from
		WmsShipmentDocumentsItems i
		join PRODUCTS p on i.ProductId = p.ID			
		join MANUFACTURERS m on m.ID = p.MANID
		left join WarehouseProductQuality q on q.Id = i.QualityId
	where 
		i.DocId = @DocId
	order by 
		m.[NAME]--, p.FullName

	-- Маркировки
	select
		dm.ProductId		as 'ProductId',
		dm.DataMatrix		as 'DataMatrix'
	from 
		 WmsShipmentDocumentsItemsDataMatrixes dm 
	where 
		dm.DocId = @DocId

end
