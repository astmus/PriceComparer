create proc UtPriceDocumentCreate
(
	@PublicId			nvarchar(64),			-- Публичный идентификатор
	-- Документ
	@Number				nvarchar(64),			-- Номер документа в УТ
	@Date				datetime,				-- Дата документа в УТ
	@Type				int,					-- Тип документа
	@IsCancelled		bit,					-- Документ отменен
	-- Out-параметры
	@NewId				int out,				-- Идентификатор созданного документа
	@ErrorMes			nvarchar(4000) out		-- Сообщение об ошибках
) as
begin
	
	set nocount on
	set @ErrorMes = ''
	set @NewId = -1
		
	-- Идентификатор существующего документа
	declare 
		@ExistsId			int			 = null,
		@ExistsPublicId		nvarchar(64) = null

	-- Доп. переменные
	declare
		@res	int				= -1,
		@err	nvarchar(4000)	= ''

	begin try

		select 
			@ExistsId = Id,
			@ExistsPublicId = @PublicId 
		from 
			UtPriceDocuments 
		where 
			PublicId = @PublicId

		---- Если документ не существует и список позиций пуст - выходим
		--if not exists (select 1 from #Prices) and @ExistsPublicId is null
		--if @ExistsPublicId is null
		--	return 0

		---- Если документ не существует и у документа есть признак отмены - выходим
		--if @IsCancelled = 1 and @ExistsPublicId is null
 	--	   return 0

	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

	declare @trancount int
	select @trancount = @@trancount

	begin try

		if @trancount = 0
			begin transaction

		-- Если документ с таким номером уже существует
		if @ExistsPublicId is not null begin

			-- Архивируем существующий документ
			exec @res = UtPriceDocumentArchive @ExistsId, @err out
			if @res = 1 begin
				if @trancount = 0
					rollback transaction
				set @ErrorMes = @err
				return 1
			end

			-- Обновляем существующий документ
			update d
			set
				d.Number			= @Number, 
				d.[Date]			= @Date, 
				d.[Type]			= @Type, 
				d.IsCancelled		= @IsCancelled,

				d.ChangedDate		= getdate()
			from
				UtPriceDocuments d
			where
				d.Id = @ExistsId

			-- Создаем цены
			insert UtPrices
				(DocId, ProductId, Price, PriceTypeId, CurrencyId)
			select
				@ExistsId, p.ID, pr.Price, isnull(pt.Id, 0),
				case pr.Currency
					when 'RUB' then 1
					when 'USD' then 2
					else 0
				end
			from
				#Prices pr
				join PRODUCTS p on p.SKU = pr.Sku
				left join UTPriceTypes pt ON pr.PriceTypeId = pt.OuterId

			-- Создаем событие изменения документа
			--declare
			--	@ActionObj varchar(100) = '{"DocId":"' + cast(@ExistsId as nvarchar(11)) + '"}'
			--	exec ActionsProcessingQueuePut @ExistsId, 2, 1202, @ActionObj, 2, '4966E5F3-3A47-433D-872C-E525BE1DC096'

		end else begin

			-- Создаем документ
			insert UtPriceDocuments 
				(PublicId, Number, [Date], [Type], IsCancelled)
			values 
				(@PublicId, @Number, @Date, @Type, @IsCancelled)

			select @NewId = @@identity

			-- Создаем цены
			insert UtPrices
				(DocId, ProductId, Price, PriceTypeId, CurrencyId)
			select
				@NewId, p.ID, pr.Price, isnull(pt.Id, 0),
				case pr.Currency
					when 'RUB' then 1
					when 'USD' then 2
					else 0
				end
			from
				#Prices pr
				join PRODUCTS p on p.SKU = pr.Sku
				left join UTPriceTypes pt ON pr.PriceTypeId = pt.OuterId

			-- Создаем событие создания документа
			declare
				@ActionObj varchar(100) = '{"DocId":"' + cast(@NewId as nvarchar(11)) + '"}'
				exec ActionsProcessingQueuePut @NewId, 1, 1201, @ActionObj, 2, '4966E5F3-3A47-433D-872C-E525BE1DC096'

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
