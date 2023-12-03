create proc SUZPurchaseTaskCheck
(
	@TaskId				int,					-- Идентификатор задания на закупку
	-- Out-параметры
	@ErrorMes			nvarchar(4000) out		-- Сообщение об ошибках
)
as
begin

	set nocount on;
	set @ErrorMes = ''

	begin try
	
		-- Проверяем, ожидается ли немаркированный товар
		if exists (
			select 1
			from PurchasesTasksContent c
			where
				c.CODE				= @TaskId	and
				c.ARCHIVE			= 0			and
				c.DataMatrixState	= 3			-- Ожидаем немаркированный товар
		) begin

			declare
				@res	int	= -1

			-- Добавляем заказ в очередь
			exec @res = SUZPurchaseTaskCreate @TaskId, @ErrorMes out
			
			return @res

		end

		return 0

	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

end
