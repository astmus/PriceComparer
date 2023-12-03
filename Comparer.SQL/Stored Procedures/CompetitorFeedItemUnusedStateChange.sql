create proc CompetitorFeedItemUnusedStateChange
(
	@UsedState		bit,					-- Использется / Не используется	
	@ItemId			int,					-- Идентификатор позиции из фида
	@AuthorId		uniqueidentifier,		-- Идентификатор автора
	@ErrorMes		nvarchar(4000) out		-- Сообщение об ошибке
) as
begin
	
	begin try

		-- Обновляем состояние
		update CompetitorsFeedItems set IsUsed = @UsedState where Id = @ItemId

		-- Сохраняем действие в историю
		insert CompetitorsFeedItemsHistory (OperationId, FeedItemId, ProductId, AuthorId)
		values (case when @UsedState = 1 then 4 else 3 end, @ItemId, null, @AuthorId)

		return 0
	end try
	begin catch
		set @ErrorMes = error_message()
		return 1
	end catch 

end
