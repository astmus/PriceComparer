create proc MatchCRPTItemsSave_v2
(
	@DocId						int,					-- Идентификатор накладной
	@AuthorId					uniqueidentifier,		-- Автор сопоставления 
	-- Out-параметры
	@ErrorMes					nvarchar(4000) out		-- Сообщение об ошибках
) as
begin

	set nocount on
	set @ErrorMes = ''

	declare @EmptyGuid uniqueidentifier
	set @EmptyGuid = (select cast(cast(0 as binary) as uniqueidentifier))

	declare @trancount int				-- Кол-во открытых транзакций
	select @trancount = @@trancount

	begin try

		-- Открыли транзакцию, если еще не открыта
		if @trancount = 0
			begin transaction

		-- Обновляем ссылки на ProductId
		update i 
		set i.ProductId = l.ProductId
		from #Items l
			join CRPTDocumentItems i on l.Barcode = i.Barcode and i.DocId = @DocId

/*
		update bp
		set 
			ProductId = i.ProductId
		from 
			BarcodeProductIdLinks bp
		join #Items i on i.Barcode = bp.Barcode and i.ProductId is not null and i.ProductId != @EmptyGuid

		insert BarcodeProductIdLinks(Barcode, ProductId)
		select i.Barcode, i.ProductId
		from #Items i 
			left join BarcodeProductIdLinks bp on i.Barcode = bp.Barcode 
		where i.ProductId is not null and bp.BarCode is null and i.ProductId != @EmptyGuid

		delete bp 
		from BarcodeProductIdLinks bp
			join #Items i on i.Barcode = bp.Barcode and i.ProductId = @EmptyGuid
*/	  
			
		-- Вставляем записи в BarcodeProductIdLinks
		create table #Links
		(	
			ProductId	uniqueidentifier,
			Barcode		nvarchar(14)
		)
		insert #Links (ProductId, Barcode)
		select 
			distinct i.ProductId, i.Barcode
		from 
			#Items i
		where
			i.Barcode is not null and
			i.ProductId is not null

		declare @Res int = -1
		exec @Res = BarcodeProductIdLinksCreate @ErrorMes out 
		if @Res = 1 begin
			if @trancount = 0
				rollback transaction
			return 1
		end

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
