create proc UTOrderInvoiceSummaryCreate 
(
	@InvoicePublicId			uniqueidentifier,		-- Идентификатор УПД / накладной в ЛК ЭДО
	@OrderId					uniqueidentifier,		-- Идентификатор заказа

	-- Out-параметры
	@NewId						int out,				-- Идентификатор созданного документа
	@ErrorMes					nvarchar(4000) out		-- Сообщение об ошибках
) as
begin
	
	set @ErrorMes = ''
	set @NewId = -1

	declare @trancount int
	select @trancount = @@trancount

	begin try

		if exists (select 1 from ExportOrderInvoiceSummary s where s.InvoicePublicId = @InvoicePublicId) begin
			set 
				@ErrorMes = 'Ошибка! УПД с InvoicePublicId = ' + cast(@InvoicePublicId as nvarchar(64)) + ' уже поставлен в очередь для экспрота сводки по заказу!'
		
			return 1
		end

	end try
	begin catch
		set @ErrorMes = error_message()
		return 1
	end catch

	begin try		
		
		if @trancount = 0
			begin transaction

			insert ExportOrderInvoiceSummary (InvoicePublicId, OrderId)
			values (@InvoicePublicId, @OrderId)

			select @NewId = @@identity

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
