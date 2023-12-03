create proc UTExportOrdersEnd 
(
	@SessionId		bigint, 
	@Status			int, 
	@Comment		nvarchar(500)
) as
begin

	set nocount on
	declare @trancount int
	
	-- Если сессии с указанным Id нет в таблице - выходим из процедуры
	if not exists (select 1 from UTExportOrdersSessions where SessionId = @SessionId) 
		return 1

	begin try

		if @trancount = 0
			begin transaction
		
		-- Проверяем, есть ли более поздние сессии
		-- Если есть, считаем указанную сессию не актуальной и сносим ее в архив со статусом 3 - "Брошенная сессия"
		if exists (select 1 from UTExportOrdersSessions where SessionId > @SessionId) begin
		
			-- Сносим в архив отработанные объеты
			insert UTExportOrdersSessionItemsArchive (SessionId, Id, OrderId, ReportDate, Operation, IsPartial, OrderState)
			select 
				@SessionId, o.Id, o.OrderId, o.ReportDate, o.Operation, o.IsPartial, o.OrderState
			from 
				UTExportOrdersSessionItems i
				join UTExportOrders o on o.Id = i.Id and i.SessionId = @SessionId
			
			-- Удаляем записи сессии
			delete UTExportOrdersSessionItems where SessionId = @SessionId
			
			-- Сносим в архив сессию со статусом 3 - брошенная сессия
			insert ExportOrdersSessionsArchive (SessionId, CreatedDate, ArchiveSatus, Comment)
			select 
				SessionId, CreatedDate, 3, 'Сессия отмечена как "Брошенная", так как в момент закрытия данной сессии были открыты новые сессии!' 
			from 
				UTExportOrdersSessions 
			where 
				SessionId = @SessionId

			-- Удаляем отработанную сессию
			delete UTExportOrdersSessions where SessionId = @SessionId

		end else begin	-- Если указанная сессия актуальна

			-- Если статус сессии = 1 - "Успешно выполнена"
			if @Status = 1 begin

				-- Сносим в архив отработанные объеты
				insert UTExportOrdersSessionItemsArchive (SessionId, Id, OrderId, ReportDate, Operation, IsPartial, OrderState)
				select 
					@SessionId, o.Id, o.OrderId, o.ReportDate, o.Operation, o.IsPartial, o.OrderState
				from 
					UTExportOrdersSessionItems i
					join UTExportOrders o on o.Id = i.Id and i.SessionId = @SessionId

				-- Удаляем отработанные объеты
				delete p
				from UTExportOrdersSessionItems i 
					join UTExportOrders p on p.Id = i.Id and i.SessionId = @SessionId

				-- Удаляем записи сессии
				delete UTExportOrdersSessionItems where SessionId = @SessionId

				-- Сносим в архив сессию
				insert ExportOrdersSessionsArchive (SessionId, CreatedDate, ArchiveSatus, Comment)
				select 
					SessionId, CreatedDate, @Status, @Comment
				from 
					UTExportOrdersSessions 
				where 
					SessionId = @SessionId

				-- Удаляем отработанную сессию
				delete UTExportOrdersSessions where SessionId = @SessionId

				-- Проверяем отмененные заказы
				if exists 
				(	
					select 1 
					from 
						WmsShipmentOrderDocuments d 
						join UTExportOrdersSessionItemsArchive i on i.SessionId = @SessionId and d.PublicId = i.OrderId and d.DocStatus = 11
				) begin

					-- Архивируем отмененные документы в таблице WmsShipmentOrderDocuments
					insert WmsShipmentOrderDocumentsArchive 
					(
						Id, PublicId, ClientId, Number, DocStatus, WmsCreateDate, ShipmentDate, ShipmentDirection, RouteId, 
						IsPartial, IsShipped, IsDeleted, Comments, Operation, AuthorId, CreateDate, ReportDate
					)	
					select 
						d.Id, d.PublicId, d.ClientId, d.Number, d.DocStatus, d.WmsCreateDate, d.ShipmentDate, d.ShipmentDirection, d.RouteId, 
						d.IsPartial, d.IsShipped, d.IsDeleted, d.Comments, d.Operation, d.AuthorId, d.CreateDate, d.ReportDate
					from 
						WmsShipmentOrderDocuments d
						join UTExportOrdersSessionItemsArchive i on i.SessionId = @SessionId and d.PublicId = i.OrderId and d.DocStatus = 11

					-- Удаляем отмененные документы
					delete d
					from 
						WmsShipmentOrderDocuments d
						join UTExportOrdersSessionItemsArchive i on i.SessionId = @SessionId and d.PublicId = i.OrderId and d.DocStatus = 11

				end
				
			end else
			-- Если статус сессии = 2 - "Выполнение сессии закончилось неудачей"
			if @Status = 2 begin

				-- Сносим в архив отработанные объеты
				insert UTExportOrdersSessionItemsArchive (SessionId, Id, OrderId, ReportDate, Operation, IsPartial, OrderState)
				select 
					@SessionId, o.Id, o.OrderId, o.ReportDate, o.Operation, o.IsPartial, o.OrderState
				from 
					UTExportOrdersSessionItems i
					join UTExportOrders o on o.Id = i.Id and i.SessionId = @SessionId

				-- Удаляем записи сессии
				delete UTExportOrdersSessionItems where SessionId = @SessionId

				-- Сносим сессию в архив со статусом 2 - "Выполнение сессии закончилось неудачей"
				insert ExportOrdersSessionsArchive (SessionId, CreatedDate, ArchiveSatus, Comment)
				select 
					SessionId, CreatedDate, @Status, @Comment 
				from 
					UTExportOrdersSessions 
				where 
					SessionId = @SessionId

				-- Удаляем отработанную сессию
				delete UTExportOrdersSessions where SessionId = @SessionId

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
