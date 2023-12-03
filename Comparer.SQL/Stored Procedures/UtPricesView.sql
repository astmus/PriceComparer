create proc UtPricesView(
	@DocumentId			int			-- ID документа
) as
begin
	
	select
		Id,
		ProductId,
		Price,
		1,
		CreatedDate
	from
		UtPrices
	where
		Id = @DocumentId

end
