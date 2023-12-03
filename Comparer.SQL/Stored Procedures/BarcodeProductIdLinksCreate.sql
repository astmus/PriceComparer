create procedure BarcodeProductIdLinksCreate
(
	@ErrorMes		nvarchar(4000) out
) as
begin

	set nocount on
	set @ErrorMes = ''
	
	if not exists (select 1 from #Links) 
		return 0

	
	create table #LinksForMatch
	(	
		ProductId	uniqueidentifier,
		Barcode		nvarchar(14)
	)

	-- Подготовительный процесс
	begin try 

		-- Связи, которые нужно будет обновить во всех таблицах
		insert #LinksForMatch (ProductId, Barcode)
		select
			distinct b.ProductId, b.Barcode
		from #Links b
			left join BarcodeProductIdLinks l on b.Barcode = l.Barcode 
 		where 
			l.ProductId is null 
		union
		select
			distinct b.ProductId, b.Barcode
		from #Links b
			join BarcodeProductIdLinks l on b.Barcode = l.Barcode 
 		where 
			b.ProductId <> l.ProductId

	end try
	begin catch 
		return 1
	end catch 

	declare @trancount int
	select @trancount = @@trancount

	begin try  
		
		if @trancount = 0
			begin transaction
		
		-- Вставляем новые записи, если их еще нет
		insert BarcodeProductIdLinks (ProductId, Barcode)
	 	select 
			distinct b.ProductId, b.Barcode
		from #Links b
			left join BarcodeProductIdLinks l on b.Barcode = l.Barcode 
 		where 
			l.ProductId is null 

		-- Обновляем существующие записи
		update BarcodeProductIdLinks
		set 
			ProductId		= b.ProductId,
			ChangedDate		= getdate()
		from #Links b
			join BarcodeProductIdLinks l on b.Barcode = l.Barcode 
 		where 
			b.ProductId <> l.ProductId

		-- Если есть связи для обновления
		if exists (select 1 from #LinksForMatch) begin

			delete #Links

			insert #Links (ProductId, Barcode)
			select ProductId, Barcode
			from #LinksForMatch

			declare @Res int = -1
			exec @Res = DataMatrixMatchSave_v2 '87123EAD-3F71-4BDA-ACFD-361011C99CEB' /*Андрей*/, @ErrorMes out
			if @Res = 1 begin
				if @trancount = 0
					rollback transaction
				return 1
			end

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
