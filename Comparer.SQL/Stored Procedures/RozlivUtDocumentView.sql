create proc RozlivUtDocumentView
(
	@DocId			int			-- Идентификатор документа
) as
begin
	
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
		Id = @DocId
		
	select
		rdi.Id,
		rdi.DocId,
		rdi.ProductId,
		rdi.Quantity
	from
		RozlivUtDocumentItems rdi
	where
		rdi.DocId = @DocId

end
