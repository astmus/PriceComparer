create proc MatchCRPTItemsSave
(
	@DocId		int,					-- Идентификатор накладной

	@AuthorId		uniqueidentifier		-- Автор сопоставления
) as
begin

	declare @trancount int				-- Кол-во открытых транзакций
	select @trancount = @@trancount

	begin try

		-- Открыли транзакцию, если еще не открыта
		if @trancount = 0
			begin transaction
	

		-- обновляем ссылки на  ProductId
		update CRPTDocumentItems 
		set ProductId=l.ProductId
		from #Items l
		join CRPTDocumentItems i on l.ItemId=i.Id and i.DocId=@DocId


		if @trancount = 0
			commit transaction

		return 0
	end try
	begin catch
		if @trancount = 0
			rollback transaction
		return 1
	end catch

end
