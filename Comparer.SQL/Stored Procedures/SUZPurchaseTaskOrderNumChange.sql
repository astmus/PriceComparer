create proc SUZPurchaseTaskOrderNumChange
(
	@TaskId				int,					-- Идентификатор задания на закупку
	@NewOrderNum		int,					-- Новый порядковый номер
	-- Out-параметры
	@ErrorMes		nvarchar(4000) out			-- Сообщение об ошибках
)
as
begin

	set nocount on;
	
	set @ErrorMes = ''

	declare		
		@OrderNum		int,
		@ExpectedDate	date
	
	declare @trancount int
	select @trancount = @@trancount
	
	begin try

		if @trancount = 0
			begin transaction

		-- Определяем очередной порядковый номер
		select 
			@OrderNum		= OrderNum,
			@ExpectedDate	= ExpectedDate
		from 
			SUZPurchaseTasks t with(updlock) 
		where 
			t.TaskId = @TaskId
		
		if @NewOrderNum > @OrderNum begin

			update 
				SUZPurchaseTasks 
			set 
				OrderNum = OrderNum - 1
			where
				ExpectedDate = @ExpectedDate	and
				OrderNum <= @NewOrderNum		and
				OrderNum > @OrderNum

		end else if @NewOrderNum < @OrderNum begin

			update 
				SUZPurchaseTasks 
			set 
				OrderNum = OrderNum + 1
			where
				ExpectedDate = @ExpectedDate	and
				OrderNum < @OrderNum			and
				OrderNum >= @NewOrderNum

		end
			
		update 
			SUZPurchaseTasks 
		set 
			OrderNum = @NewOrderNum
		where
			TaskId = @TaskId
				
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
