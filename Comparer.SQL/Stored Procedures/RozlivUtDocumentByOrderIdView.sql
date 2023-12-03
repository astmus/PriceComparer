create proc RozlivUtDocumentByOrderIdView
(
	@OrderId			uniqueidentifier			-- Идентификатор заказа
) as
begin

	-- Объявляем таблицу, в которую сохраним
	create table #Docs
	(
		DocId		int		not null,				-- Идентификатор документа
		Primary key (DocId)
	)

	insert #Docs (DocId)
	select
		rd.Id
	from
		RozlivUtDocuments rd
	where
		rd.OrderId = @OrderId

	select
		rd.Id,
		rd.PublicId,
		rd.Number,
		rd.CreatedDate,
		rd.OrderId,
		rd.AuthorId,
		rd.ConfirmedByUt
	from
		RozlivUtDocuments rd
	where
		rd.OrderId = @OrderId
		
	select
		rdi.Id,
		rdi.DocId,
		rdi.ProductId,
		p.SKU,
		p.NAME				as 'Name',
		m.NAME				as 'Brand',
		rdi.PurchasePrice,
		rdi.Quantity
	from
		#Docs d
		join RozlivUtDocumentItems rdi on rdi.DocId = d.DocId
		join PRODUCTS p on p.ID = rdi.ProductId
		join MANUFACTURERS m on m.ID = p.MANID

end
