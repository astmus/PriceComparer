create proc UTExportRozlivEnd (
	@SessionId bigint,			-- Идентификатор сессии
	@Status int,				-- Статус завершения сессии: 1 - "Успешно выполнена", 2 - "Завершилась неудачей"
	@Comment nvarchar(500)		-- Комментарий
) as
begin

	set nocount on
	declare @trancount int
	
	-- Если сессии с указанным Id нет в таблице - выходим из процедуры
	if not exists (select 1 from ExportRozlivSessions where SessionId = @SessionId) 
		return 1

	begin try
		if @trancount = 0
			begin transaction
		
		-- Проверяем, есть ли более поздние сессии
		-- Если есть, считаем указанную сессию не актуальной и сносим ее в архив со статусом 3 - "Брошенная сессия"
		if exists (select 1 from ExportRozlivSessions where SessionId > @SessionId) begin
		
			-- Сносим в архив отработанные объеты
			insert ExportRozlivSessionItemsArchive (SessionId, Id, DocId, ReportDate, Operation)
			select @SessionId, r.Id, r.DocId, r.ReportDate, r.Operation
			from ExportRozlivSessionItems i
				join ExportRozliv r on r.Id = i.Id and i.SessionId = @SessionId
			
			-- Удаляем записи сессии
			delete ExportRozlivSessionItems where SessionId = @SessionId
			
			-- Сносим в архив сессию со статусом 3 - брошенная сессия
			insert ExportRozlivSessionsArchive (SessionId, CreatedDate, ArchiveSatus, Comment)
			select SessionId, CreatedDate, 3, 'Ссессия отмечена как "Брошенная", так как в момент закрытия данной сессии были открыты новые сессии!' 
			from ExportRozlivSessions where SessionId = @SessionId

			-- Удаляем отработанную сессию
			delete ExportRozlivSessions where SessionId = @SessionId

		end else begin	-- Если указанная сессия актуальна

			-- Если статус сессии = 1 - "Успешно выполнена"
			if @Status = 1 begin

				-- Сносим в архив отработанные объеты
				insert ExportRozlivSessionItemsArchive (SessionId, Id, DocId, ReportDate, Operation)
				select @SessionId, r.Id, r.DocId, r.ReportDate, r.Operation
				from ExportRozlivSessionItems i
					join ExportRozliv r on r.Id = i.Id and i.SessionId = @SessionId

				-- Удаляем отработанные объеты
				delete r
				from ExportRozlivSessionItems i 
					join ExportRozliv r on r.Id = i.Id and i.SessionId = @SessionId

				-- Удаляем записи сессии
				delete ExportRozlivSessionItems where SessionId = @SessionId

				-- Сносим в архив сессию
				insert ExportRozlivSessionsArchive (SessionId, CreatedDate, ArchiveSatus, Comment)
				select SessionId, CreatedDate, @Status, @Comment
				from ExportRozlivSessions where SessionId = @SessionId

				-- Удаляем отработанную сессию
				delete ExportRozlivSessions where SessionId = @SessionId

			end else
			-- Если статус сессии = 2 - "Выполнение сессии закончилось неудачей"
			if @Status = 2 begin

				-- Сносим в архив отработанные объеты
				insert ExportRozlivSessionItemsArchive (SessionId, Id, DocId, ReportDate, Operation)
				select @SessionId, r.Id, r.DocId, r.ReportDate, r.Operation
				from ExportRozlivSessionItems i
					join ExportRozliv r on r.Id = i.Id and i.SessionId = @SessionId

				-- Удаляем записи сессии
				delete ExportRozlivSessionItems where SessionId = @SessionId

				-- Сносим сессию в архив со статусом 2 - "Выполнение сессии закончилось неудачей"
				insert ExportRozlivSessionsArchive (SessionId, CreatedDate, ArchiveSatus, Comment)
				select SessionId, CreatedDate, @Status, @Comment 
				from ExportRozlivSessions where SessionId = @SessionId

				-- Удаляем отработанную сессию
				delete ExportRozlivSessions where SessionId = @SessionId

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
