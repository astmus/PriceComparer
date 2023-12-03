create proc WmsShipmentOrderDocumentItemsView
(
	@DocId			bigint				-- Идентификатор документа	
) as
begin
			
		select
			i.Id								as 'Id',
			i.DocId								as 'DocId',
			i.ProductId							as 'ProductId', 
			i.Sku								as 'Sku', 
			i.Quantity							as 'Quantity',
			i.Price								as 'Price',
			m.NAME								as 'BrandName',
			rtrim(p.NAME + ' ' + p.CHILDNAME)	as 'ProductName'
		from WmsShipmentOrderDocumentsItems i
			join PRODUCTS p on i.ProductId = p.ID			
			join MANUFACTURERS m on m.ID = p.MANID
		where i.DocId = @DocId
		order by m.NAME, p.NAME, p.CHILDNAME
				
end
