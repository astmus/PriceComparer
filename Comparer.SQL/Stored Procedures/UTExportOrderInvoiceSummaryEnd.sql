create proc  UTExportOrderInvoiceSummaryEnd(
	@SessionId bigint, 
	@Status int, 
	@Comment nvarchar(500)
) as
begin

	set nocount on
	declare @trancount int
	
	-- Если сессии с указанным Id нет в таблице - выходим из процедуры
	if not exists (select 1 from ExportOrderInvoiceSummarySessions where SessionId = @SessionId) 
		return 1

	begin try

		if @trancount = 0
			begin transaction
		
		-- Проверяем, есть ли более поздние сессии
		-- Если есть, считаем указанную сессию не актуальной и сносим ее в архив со статусом 3 - "Брошенная сессия"
		if exists (select 1 from ExportOrderInvoiceSummarySessions where SessionId > @SessionId) begin
		
			-- Сносим в архив отработанные объеты
			insert ExportOrderInvoiceSummarySessionItemsArchive (SessionId, Id, InvoicePublicId, OrderId, ReportDate)
			select @SessionId, o.Id, o.InvoicePublicId, o.OrderId, o.ReportDate
			from ExportOrderInvoiceSummarySessionItems i
				join ExportOrderInvoiceSummary o on o.Id = i.Id and i.SessionId = @SessionId
			
			-- Удаляем записи сессии
			delete ExportOrderInvoiceSummarySessionItems where SessionId = @SessionId
			
			-- Сносим в архив сессию со статусом 3 - брошенная сессия
			insert ExportOrderInvoiceSummarySessionsArchive (SessionId, CreatedDate, ArchiveSatus, Comment)
			select SessionId, CreatedDate, 3, 'Сессия отмечена как "Брошенная", так как в момент закрытия данной сессии были открыты новые сессии!' 
			from ExportOrderInvoiceSummarySessions where SessionId = @SessionId

			-- Удаляем отработанную сессию
			delete ExportOrderInvoiceSummarySessions where SessionId = @SessionId

		end else begin	-- Если указанная сессия актуальна

			-- Если статус сессии = 1 - "Успешно выполнена"
			if @Status = 1 begin

				-- Сносим в архив отработанные объеты
				insert ExportOrderInvoiceSummarySessionItemsArchive (SessionId, Id, InvoicePublicId, OrderId, ReportDate)
				select @SessionId, o.Id, o.InvoicePublicId, o.OrderId, o.ReportDate
				from ExportOrderInvoiceSummarySessionItems i
					join ExportOrderInvoiceSummary o on o.Id = i.Id and i.SessionId = @SessionId

				-- Удаляем отработанные объеты
				delete p
				from ExportOrderInvoiceSummarySessionItems i 
					join ExportOrderInvoiceSummary p on p.Id = i.Id and i.SessionId = @SessionId

				-- Удаляем записи сессии
				delete ExportOrderInvoiceSummarySessionItems where SessionId = @SessionId

				-- Сносим в архив сессию
				insert ExportOrderInvoiceSummarySessionsArchive (SessionId, CreatedDate, ArchiveSatus, Comment)
				select SessionId, CreatedDate, @Status, @Comment
				from ExportOrderInvoiceSummarySessions where SessionId = @SessionId

				-- Удаляем отработанную сессию
				delete ExportOrderInvoiceSummarySessions where SessionId = @SessionId

			end else
			-- Если статус сессии = 2 - "Выполнение сессии закончилось неудачей"
			if @Status = 2 begin

				-- Сносим в архив отработанные объеты
				insert ExportOrderInvoiceSummarySessionItemsArchive (SessionId, Id, InvoicePublicId, OrderId, ReportDate)
				select @SessionId, o.Id, o.InvoicePublicId, o.OrderId, o.ReportDate
				from ExportOrderInvoiceSummarySessionItems i
					join ExportOrderInvoiceSummary o on o.Id = i.Id and i.SessionId = @SessionId

				-- Удаляем записи сессии
				delete ExportOrderInvoiceSummarySessionItems where SessionId = @SessionId

				-- Сносим сессию в архив со статусом 2 - "Выполнение сессии закончилось неудачей"
				insert ExportOrderInvoiceSummarySessionsArchive (SessionId, CreatedDate, ArchiveSatus, Comment)
				select SessionId, CreatedDate, @Status, @Comment 
				from ExportOrderInvoiceSummarySessions where SessionId = @SessionId

				-- Удаляем отработанную сессию
				delete ExportOrderInvoiceSummarySessions where SessionId = @SessionId

			end

		end
		
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
