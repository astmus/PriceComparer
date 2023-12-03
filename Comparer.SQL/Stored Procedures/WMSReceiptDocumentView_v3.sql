create proc WMSReceiptDocumentView_v3
(
	@Id			bigint,				-- Идентификатор документа
	@PublicId	uniqueidentifier	-- Публичный идентификатор документа
) as
begin

	declare
		@DocId	bigint	= @Id

	if @Id is null
		select @DocId = Id from WmsReceiptDocuments where PublicId = @PublicId

	-- Документ
	select
		d.Id					as 'Id',
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
		 WmsReceiptDocuments d
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
		i.Price					as 'Price',
		m.[NAME]				as 'BrandName',
		'p.FullName'				as 'ProductName'
	from
		WmsReceiptDocumentsItems i
		join PRODUCTS p on i.ProductId = p.ID			
		join MANUFACTURERS m on m.ID = p.MANID
		left join WarehouseProductQuality q on q.Id = i.QualityId
	where 
		i.DocId = @DocId
	order by 
		m.[NAME]

	-- Маркировки
	select
		dm.ProductId		as 'ProductId',
		dm.DataMatrix		as 'DataMatrix'
	from 
		 WmsReceiptDocumentsItemDataMatrixes dm 
	where 
		dm.DocId = @DocId

end
