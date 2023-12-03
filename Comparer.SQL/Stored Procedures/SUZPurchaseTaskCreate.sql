create proc SUZPurchaseTaskCreate
(
	@TaskId				int,					-- Идентификатор задания на закупку
	-- @ExpectedDate		date,					-- Дата поступления товара на склад
	-- Out-параметры
	@ErrorMes		nvarchar(4000) out			-- Сообщение об ошибках
)
as
begin

	set nocount on;
	
	set @ErrorMes = ''

	declare
		@ExistsTaskId		int,
		@ExistsDate			date,
		@ExpectedDate		date,
		@needDelete			bit = 0
	
	-- Предварительные проверки
	begin try

		-- Определяем дату поступления по заданию на закупку
		select 
			@ExpectedDate = ExpectedDate 
		from 
			PurchasesTasks t 
		where 
			t.CODE = @TaskId

		-- Определяем, есть ли задание уже в очереди
		-- и дату поступления согласно очереди
		select 
			@ExistsTaskId	= t.TaskId,
			@ExistsDate		= t.ExpectedDate
		from 
			SUZPurchaseTasks t
		where
			t.TaskId = @TaskId

		if @ExistsTaskId is not null begin

			if @ExistsDate <> @ExpectedDate begin
				select @needDelete = 1
			end else begin
				return 0
			end

		end

	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch


	declare @trancount int
	select @trancount = @@trancount

	declare
		@OrderNum int = 0

	begin try

		if @trancount = 0
			begin transaction

		-- Определяем очередной порядковый номер
		select @OrderNum = max(OrderNum) from SUZPurchaseTasks t with(updlock) where t.ExpectedDate = @ExpectedDate
		
		if @needDelete = 1 begin
			delete SUZPurchaseTasks where TaskId = @TaskId
		end

		if @OrderNum is null
			select @OrderNum = 1
		else
			select @OrderNum = @OrderNum + 1
			
		-- Вставляем задание
		insert SUZPurchaseTasks (TaskId, ExpectedDate, OrderNum) 
		values (@TaskId, @ExpectedDate, @OrderNum)
				
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
