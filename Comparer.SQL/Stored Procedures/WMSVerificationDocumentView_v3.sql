create proc WMSVerificationDocumentView_v3
(
	@Id			bigint,				-- Идентификатор документа
	@PublicId	uniqueidentifier	-- Публичный идентификатор документа
) as
begin
	
	declare
		@DocId	bigint	= @Id

	if @Id is null
		select @DocId = Id from WmsVerificationDocuments where PublicId = @PublicId

	-- Документ
	select
		d.Id					as 'Id',
		d.PublicId				as 'PublicId',
		d.Number				as 'Number',
		d.DocType				as 'DocType',
		IIF(d.DocType = 1, 'Оприходование', 'Списание') 
								as 'DocTypeName',
		d.CreateDate			as 'CreateDate',
		d.Operation				as 'Operation'
	from 
		WmsVerificationDocuments d 
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
		i.OldQualityId			as 'OldQualityId',
		isnull(oq.[Name], '?')	as 'OldQualityName',
		m.[NAME]				as 'BrandName',
		'p.FullName'				as 'ProductName'
	from
		WmsVerificationDocumentsItems i
		join PRODUCTS p on i.ProductId = p.ID			
		join MANUFACTURERS m on m.ID = p.MANID
		left join WarehouseProductQuality q on q.Id = i.QualityId
		left join WarehouseProductQuality oq on oq.Id = i.OldQualityId
	where 
		i.DocId = @DocId
	order by 
		m.[NAME]

end
