create proc SetWeightForOrder (
	@OrderId		uniqueidentifier,	-- Идентификатор заказа
	@Weight			int,				-- Вес (в граммах)
	@AuthorId		uniqueidentifier	-- Идентификатор автора
) as
begin	

	update CLIENTORDERS set WEIGHT = @Weight where ID = @OrderId

end
