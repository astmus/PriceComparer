create proc SuzDataMatrixSave
(   
	@OrderId					int,				-- ИД заказа 
	@GTIN						nvarchar(14),		-- GTIN
	-- Выходные параметры
	@ErrorMes					nvarchar(4000) out	-- Сообщение об ошибке
) as
begin	

	set nocount on
	set @ErrorMes = '' 

	declare 
		@ItemId int

	begin try
	
		-- Определяем идентификатор позиции
		select 
			@ItemId = i.Id 
		from
			SUZOrderItems i
		where
			i.OrderId = @OrderId and
			i.GTIN = @GTIN

		if @ItemId is null begin
			set @ErrorMes = 'Не удалось определить позицию в заказе для GTIN=' + @GTIN + '!'
			return 1
		end

		-- Добавляем маркировки
		insert SUZOrderItemDataMatrixes 
			(ItemId, DataMatrix)
		select
			@ItemId, dm.DataMatrix
		from
			#SUZDataMatrixes dm
			left join SUZOrderItemDataMatrixes e on e.DataMatrix = dm.DataMatrix
		where
			e.DataMatrix is null

		return 0
			
	end try
	begin catch
		set @ErrorMes = error_message()
		return 1
	end catch

end
