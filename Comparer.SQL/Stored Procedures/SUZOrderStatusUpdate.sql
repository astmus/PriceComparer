create proc SUZOrderStatusUpdate
(
	@Id				int,					-- Идентификатор заказа в ShopBase
	@PublicId		nvarchar(64),			-- Идентификатор заказа в СУЗ
	@StatusId		int,					-- Идентификатор статуса
	@Error			nvarchar(4000),			-- Ошибка

	@AuthorId		uniqueidentifier,		-- Идентификатор автора
	-- Out-параметры
	@ErrorMes		nvarchar(4000) out		-- Сообщение об ошибках
)
as
begin

	set nocount on;

	set @ErrorMes = ''

	begin try

		-- Заказ
		update 
			SUZOrders 
		set 
			StatusId	= @StatusId,
			PublicId	= @PublicId,
			Error		= @Error
		where
			Id = @Id

		return 0

	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

end
