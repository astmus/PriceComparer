CREATE PROC WmsVerificationDocumentItemsView
(
	@DocId		bigint		-- Идентификатор документа	
) AS
BEGIN
			
	SELECT
		i.Id as 'Id', i.DocId as 'DocId', i.ProductId as 'ProductId', 
		i.Sku as 'Sku', i.Quantity as 'Quantity', 
		m.NAME as 'BrandName',
		RTrim(p.NAME + ' ' + p.CHILDNAME) as 'ProductName'
	FROM
		WmsVerificationDocumentsItems i
		join PRODUCTS p on i.ProductId = p.ID			
		join MANUFACTURERS m on m.ID = p.MANID
	where i.DocId = @DocId
	order by m.NAME, p.NAME, p.CHILDNAME
				
END
