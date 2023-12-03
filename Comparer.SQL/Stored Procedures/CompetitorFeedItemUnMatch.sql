create proc CompetitorFeedItemUnMatch
(
	@ItemId			int,					-- Идентификатор позиции из фида
	@ProductId		uniqueidentifier,		-- Идентификатор товара из каталога
	@AuthorId		uniqueidentifier,		-- Идентификатор автора
	@ErrorMes		nvarchar(4000) out		-- Сообщение об ошибке
) as
begin
	
	begin try

		-- Проверяем связь на существование
		if not exists (select 1 from CompetitorsFeedProductLinks l where l.FeedItemId = @ItemId and l.ProductId = @ProductId)
		begin
			set @ErrorMes = 'Связь уже удалена!'
			return 1
		end

		-- Создаем связь
		delete CompetitorsFeedProductLinks where FeedItemId = @ItemId and ProductId = @ProductId

		-- Сохраняем действие в историю
		insert CompetitorsFeedItemsHistory (OperationId, FeedItemId, ProductId, AuthorId)
		values (2, @ItemId, @ProductId, @AuthorId)

		return 0
	end try
	begin catch
		set @ErrorMes = error_message()
		return 1
	end catch 

end
