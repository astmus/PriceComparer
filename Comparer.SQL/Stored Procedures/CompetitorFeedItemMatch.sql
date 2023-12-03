create proc CompetitorFeedItemMatch
(
	@ItemId			int,					-- Идентификатор позиции из фида
	@ProductId		uniqueidentifier,		-- Идентификатор товара из каталога
	@AuthorId		uniqueidentifier,		-- Идентификатор автора
	@ErrorMes		nvarchar(4000) out		-- Сообщение об ошибке
) as
begin
	
	begin try

		-- Проверяем связь на существование
		if exists (select 1 from CompetitorsFeedProductLinks l where l.FeedItemId = @ItemId and l.ProductId = @ProductId)
		begin
			set @ErrorMes = 'Связь уже существует!'
			return 1
		end

		-- Создаем связь
		insert CompetitorsFeedProductLinks (FeedItemId, ProductId) values (@ItemId, @ProductId)

		-- Сохраняем действие в историю
		insert CompetitorsFeedItemsHistory (OperationId, FeedItemId, ProductId, AuthorId)
		values (1, @ItemId, @ProductId, @AuthorId)

		return 0
	end try
	begin catch
		set @ErrorMes = error_message()
		return 1
	end catch 

end
