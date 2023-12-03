create proc UtPriceDocumentProcess
(
	@Id					int,					-- Идентификатор документа
	-- Out-параметры
	@HasDoubtfulPrices	bit out,				-- Документ содержит позиции с сомнительными ценами
	@ErrorMes			nvarchar(4000) out		-- Сообщение об ошибках
) as
begin
	
	set nocount on
	set @ErrorMes = ''
	set @HasDoubtfulPrices = 0
	
	begin try

		-- Если документ уже отмечен как "Сомнительный"
		if exists (select 1 from UtDoubtfulPriceDocuments where DocId = @Id) 
		begin
			return 0
		end

		declare 
			@DIFF float = 0.5	-- превышение цены более, чем на 50%

		-- Содержимое документа
		create table #items
		(
			ProductId			uniqueidentifier, 
			Price				float,
			PriceId				int,
			TypeId				int,
			LastPrice			float,
			LastDocId			int,
			HasDoubtfulPrice	bit default (0)	
		)

		-- Загружаем товарные позиции
		insert into #items (ProductId, Price, PriceId, TypeId)
			select ProductId, Price, Id, PriceTypeId from UtPrices where DocId = @Id

		-- Определяем цены в последних дукументах
		update i
		set 
			i.LastPrice		= t.Price,
			i.LastDocId		= t.DocId
		from
			#items i
			join
				(
					select
						p.ProductId		as 'ProductId', 
						pd.Id			as 'DocId',
						utp.Price		as 'Price',
						row_number() over (partition by p.ProductId order by pd.[Date] desc) 
										as 'RowNo'
					from
						#items p
						JOIN UtPrices utp		 on p.ProductId = utp.ProductId and p.TypeId = utp.PriceTypeId
						JOIN UtPriceDocuments pd on utp.DocId = pd.Id
					where
						pd.Id <> @Id
				) t on i.ProductId = t.ProductId and t.RowNo = 1

		-- Обновляем признак "Сомнительная цена"
		update i
		set 
			i.HasDoubtfulPrice = 1
		from
			#items i
		where
			(i.Price >= i.LastPrice and (i.LastPrice / i.Price) > @DIFF)
			or
			(i.Price < i.LastPrice and (i.Price / i.LastPrice) > @DIFF)
					
		-- Если "Сомнительные" цены есть
		if exists (select 1 from #items where HasDoubtfulPrice = 1)
		begin

			set @HasDoubtfulPrices = 1

			-- Вставляем запись в таблицу "Сомнительных" документов
			insert UtDoubtfulPriceDocuments
				(DocId, ReasonId)
			values
				(@Id, 1)
				
			-- Вставляем записи в таблицу "Сомнительных" цен
			insert UtDoubtfulPrices
				(DocId, ProductId, ReasonId, LastDocId)
			select
				@Id, i.ProductId, 1, LastDocId
			from
				#items i
			where
				i.HasDoubtfulPrice = 1

		end

		return 0

	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

end
