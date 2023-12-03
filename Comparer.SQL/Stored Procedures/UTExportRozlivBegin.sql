create proc UTExportRozlivBegin (@SessionId bigint out) as
begin

	set nocount on
	declare @trancount int
	select @trancount = @@TRANCOUNT
	set @SessionId = 0

	-- Таблица для сохранения изменившихся и созданных объектов
	create table #objTable 
	(
		Id			bigint					not null,
		DocId		int						not null,
		Operation	int						not null,
		primary key(Id)
	)

	begin try

		if @trancount = 0
			begin transaction
		
		-- "Захватываем" таблицу ExportRozliv и запоминаем список брендов
		insert #objTable (Id, DocId, Operation)
		select Id, DocId, Operation
		from ExportRozliv with(updlock)

		-- Если изменившиеся или созданные объекты есть
		if exists(select 1 from #objTable) begin
									
			-- Создаем новую сессию		
			insert ExportRozlivSessions(CreatedDate) values(default)

			-- Запоминаем идентификатор сессии
			set @SessionId = @@IDENTITY

			select @SessionId as SessionId

			-- Сохраняем записи
			insert ExportRozlivSessionItems (SessionId, Id)
			select @SessionId, Id from #objTable

			-- Выгружаем документы
			select distinct 
				r.PublicId			as 'DocId', 
				r.Number			as 'Number',
				u.[NAME]			as 'Author',
				c.PUBLICNUMBER		as 'PublicNumber',
				r.CreatedDate		as 'CreatedDate'
			from #objTable o
				join RozlivUtDocuments r  on r.Id = o.DocId	
				join CLIENTORDERS c on c.ID = r.OrderId
				join USERS u on u.ID = r.AuthorId
			where 
				r.ConfirmedByUt = 0		
				
			-- Выгружаем товары		
			select distinct 
				r.PublicId		as 'DocId', 
				i.ProductId		as 'ProductId', 
				p.Sku			as 'Sku',  
				i.Quantity		as 'Quantity',
				''				as 'Comment'
			from #objTable o
				join RozlivUtDocuments r on r.Id = o.DocId			
				join RozlivUtDocumentItems i on i.DocId = r.Id
				join Products p on p.Id = i.ProductId
			where 
				r.ConfirmedByUt = 0					
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
