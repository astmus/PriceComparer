create proc UtPriceDocumentArchive
(
	@Id				int,					-- Идентификатор документа
	-- Out-параметры
	@ErrorMes		nvarchar(4000) out		-- Сообщение об ошибках
) as
begin
	
	set nocount on
	set @ErrorMes = ''
	
	declare @now datetime = getdate()

	declare @trancount int
	select @trancount = @@trancount

	begin try

		if @trancount = 0
			begin transaction
			
		-- Архивируем документ
		insert UtPriceDocumentsArchive 
			(DocId, PublicId, Number, [Date], [Type], IsCancelled, CreatedDate, ChangedDate, ArchivedDate)
		select
			Id, PublicId, Number, [Date], [Type], IsCancelled, CreatedDate, ChangedDate, @now
		from
			UtPriceDocuments
		where
			Id = @Id
		
		-- Архивируем цены
		insert UtPricesArchive
			(DocId, ProductId, Price, PriceTypeId, CurrencyId, ArchivedDate)
		select
			DocId, ProductId, Price, PriceTypeId, CurrencyId, @now
		from
			UtPrices
		where
			DocId = @Id

		-- Удаляем цены
		delete UtPrices where DocId = @Id

		if @trancount = 0
			commit transaction

		return 0
	end try
	begin catch		
		if @trancount = 0
			rollback transaction
		set @ErrorMes = error_message()
		return 1
	end catch

end
