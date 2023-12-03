create proc CompetitorsFeedsAnalyse
(	
	@AuthorId			uniqueidentifier,			-- Идентификатор автора
	-- Выходные параметры
	@ErrorMes			nvarchar(4000) out			-- Сообщение об ошибках
) as
begin

	set @ErrorMes = ''
	set nocount on
		
	-- Таблица для промежуточных результатов
	create table #items
	(
		ProductId		uniqueidentifier	not null,
		CompetitorId	int					not null,
		CurrencyId		int					not null,
		Price			decimal(14,2)		not null,
		RowNo			int					not null,
		primary key (ProductId, CompetitorId, RowNo)
	)
		--create index ix_CompetitorsFeedsAnalyse_items on #items (ProductId, CompetitorId)
				
	begin try
		
		-- Заполняем таблицу с промежуточными результатами
		insert #items (ProductId, CompetitorId, CurrencyId, Price, RowNo)
		select
			l.ProductId, c.Id, 1, i.Price,
			row_number() over (partition by l.ProductId order by i.Price)
		from
			Competitors c
			join CompetitorsFeeds f on f.CompetitorId = c.Id and c.IsActive = 1 and f.IsActive = 1
			join CompetitorsFeedItems i on i.FeedId = f.Id and i.Deleted = 0 and i.IsUsed = 1
			join CompetitorsFeedProductLinks l on l.FeedItemId = i.Id
		where
			i.Price > 0
			
		-- Если данных нет
		if not exists (select 1 from #items) 
		begin
			set @ErrorMes = 'Нет данных для анализа!'
			return 1
		end
		
	end try 
	begin catch 
		set @ErrorMes = error_message()
		return 1
	end catch

	declare @trancount int
	select @trancount = @@trancount

	-- Выполняем обновление результатов анализ
	begin try

		if @trancount = 0
			begin transaction

		-- Очищаем таблицу результатов анализа
		truncate table ClosestCompetitors

		-- Вставляем записи для конкурентов с первой (минимальной) ценой
		insert ClosestCompetitors 
		(
			ProductId, CompetitorId1, Price1
		)
		select
			i.ProductId, i.CompetitorId, i.Price
		from 
			#items i
		where
			 i.RowNo = 1

		-- Обновляем записи для конкурентов со второй ценой
		update c
		set
			c.CompetitorId2	= i.CompetitorId,
			c.Price2		= i.Price
		from 
			ClosestCompetitors c
				join #items i on i.ProductId = c.ProductId
		where 
			i.RowNo = 2

		-- Обновляем записи для конкурентов с третьей ценой
		update c
		set
			c.CompetitorId2	= i.CompetitorId,
			c.Price2		= i.Price
		from 
			ClosestCompetitors c
				join #items i on i.ProductId = c.ProductId
		where 
			i.RowNo = 3

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
