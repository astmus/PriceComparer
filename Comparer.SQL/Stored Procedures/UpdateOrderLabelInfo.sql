create proc UpdateOrderLabelInfo 
( 
	@OrderId		uniqueidentifier,	-- Идентификатор заказ
	@LabelId		nvarchar(100)		-- Идентификатор этикетки
) as
begin

	declare @trancount int
	select @trancount = @@TRANCOUNT

	begin try
		if @trancount = 0
			begin transaction
		 
		-- Изменяем запись во вспомогательной таблице
		update ApiDeliveryServiceOrdersInfo 
		set	
			LabelId = @LabelId
		where InnerId = @OrderId

		if @trancount = 0
			commit transaction
		return 0
	end try
	begin catch
		if @trancount = 0
			rollback transaction
		return 1
	end catch

end
