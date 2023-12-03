create proc CRPTDocumentsView_v5
(
	@Operation					int,				-- Операция
														-- 1 - общее число строк
														-- 2 - вывод документов
	@Id							int,				-- Идентификатор документа
	-- Базовый документ
	@CRPTNumber					nvarchar(500),		-- Номер документа в ЦРПТ
	@CRPTInput					bit,				-- Входящий документ
	@CRPTType					varchar(128),		-- Тип документа в ЦРПТ
	-- Документ
	@DocNumber					nvarchar(128),		-- Неомер документа
	@DocDateFrom				date,				-- Дата документа с
	@DocDateTo					date,				-- Дата документа по
	@ChangedDateFrom			date,				-- Дата изм. документа с
	@ChangedDateTo				date,				-- Дата изм. документа по
	-- Внутренняя информация
	@SenderId					int,				-- Идентификатор контрагента-отправителя
	@ReceiverId					int,				-- Идентификатор контрагента-получателя
	@StatusId					int,				-- Статус документа
	@DataMatrix					nvarchar(128),		-- Маркировка по документу
	@PurchaseTaskId				int,				-- Задание на закупку
	-- Постраничная навигация
	@Limit						int,				-- Предел вывода количества строк
	@Offset						int					-- Индекс - смещение начальной строки

)
as
begin

	if (@Offset is null) 
		set @Offset = 0

	if (@Limit is null) 
		set @Limit = 100

	-- Установка дат на начало дня
	select	@DocDateFrom = cast(cast(@DocDateFrom as date) as datetime),
			@DocDateTo = cast(cast(dateadd(d, 1, @DocDateTo) as date) as datetime)

	--1.0 Выборка идентификаторов документов по критерию 
	create table #tempIds
	(
		Id					int			not null,   -- Идентификатор документа
		DataMatrixCount		int			not null,	-- Количество маркировок
		--RowNumber			int			not null	-- Номер ряда выборки
		primary key(Id)
	)
	
	-- 1.1 задан @CRPTNumber
	if @CRPTNumber is not null begin

		insert #tempIds (Id, DataMatrixCount)
		select distinct
			-- Документ
			d.Id							as 'Id',					
			-- Марикровки
			count(di.DataMatrix) over (partition by d.Id)	as 'DataMatrixCount'
		from
			CRPTDocuments d
				left join CRPTDocumentItems di on d.Id = di.DocId
		where	d.CRPTNumber = @CRPTNumber
			
	-- 1.2 задан @DocNumber
	end else begin
		if (@DocNumber is not null) begin
			
			insert #tempIds (Id, DataMatrixCount)
			select distinct
				-- Документ
				d.Id							as 'Id',					
				-- Марикровки
				count(di.DataMatrix) over (partition by d.Id)	as 'DataMatrixCount'
			from
				CRPTDocuments d
					left join CRPTDocumentItems di on d.Id = di.DocId
			where	d.DocNumber = @DocNumber

		-- 1.3 задан @DataMatrix
		end else begin
			if (@DataMatrix is not null) begin

				insert #tempIds (Id, DataMatrixCount)
				select distinct
					-- Документ
					d.Id							as 'Id',					
					-- Марикровки
					count(di.DataMatrix) over (partition by d.Id)	as 'DataMatrixCount'
				from
					CRPTDocuments d
						left join CRPTDocumentItems di on d.Id = di.DocId
				where	di.DataMatrix = @DataMatrix
			end else begin
			-- 1.4 Задан PurchaseTaskId 
			if (@PurchaseTaskId	 is not null) begin

				insert #tempIds (Id, DataMatrixCount)
				select distinct
					-- Документ
					d.Id							as 'Id',					
					count(di.DataMatrix) over (partition by d.Id)	as 'DataMatrixCount'
				from
					CRPTDocuments d
						left join CRPTDocumentItems di on d.Id = di.DocId
						left join CRPTDocumentWithPurchaseTaskLinks cl on d.Id = cl.CRPTDocId
				where  cl.TaskId  = @PurchaseTaskId
			-- 1.5 Общий случай
			end else begin
					
					insert #tempIds (Id, DataMatrixCount)
					select distinct
						-- Документ
							d.Id										as 'Id',
						-- Марикровки
						count(di.DataMatrix) over (partition by d.Id)	as 'DataMatrixCount'
					from
						CRPTDocuments d
							left join CRPTDocumentItems di on d.Id = di.DocId
					where
						(@CRPTInput		is null or (@CRPTInput		is not null and d.CRPTInput		= @CRPTInput))				and
						(@CRPTType		is null or (@CRPTType		is not null and d.CRPTType		= @CRPTType))				and
						(@SenderId		is null or (@SenderId		is not null and d.SenderId		= @SenderId))				and
						(@ReceiverId	is null or (@ReceiverId		is not null and d.ReceiverId	= @ReceiverId))				and
						(@StatusId		is null or (@StatusId		is not null and d.StatusId		= @StatusId))				and
						(@DocDateFrom	is null or (@DocDateFrom	is not null and d.CRPTCreatedDate >= @DocDateFrom))			and
						(@DocDateTo		is null or (@DocDateTo		is not null and d.CRPTCreatedDate <= @DocDateTo))			and
						(@ChangedDateFrom	is null or (@ChangedDateFrom	is not null and d.ChangedDate >= @ChangedDateFrom))			and
						(@ChangedDateTo		is null or (@ChangedDateTo		is not null and d.ChangedDate <= @ChangedDateTo))			and
						(@Id			is null or (@Id				is not null and d.Id			= @Id))						

			end
		end
	end
	end

			-- 2.0 Выводим общее количество записей
			if (@Operation = 1) begin
				select 
					count (distinct t.Id) 	as 'TotalCount'
				from #tempIds t 
			end

			
			--3.0 Делаем выборку записей
			if (@Operation = 2) begin
				select
							*
				from (
						select distinct
							-- Документ
							d.Id							as 'Id',
							d.CRPTNumber					as 'CRPTNumber', 
							d.CRPTInput						as 'CRPTInput', 
							d.CRPTCreatedDate				as 'CRPTCreatedDate', 
							d.CRPTType						as 'CRPTType', 
							d.CRPTStatus					as 'CRPTStatus', 
							d.DocNumber						as 'DocNumber', 
							d.DocDate						as 'DocDate', 
							d.SenderId						as 'SenderId', 
							isnull(d.ReceiverId,0)			as 'ReceiverId', 
							d.StatusId						as 'StatusId', 

							d.IsCRPTCancelled				as 'IsCRPTCancelled',
							d.CancellationCRPTNumber		as 'CancellationCRPTNumber', 

							isnull(d.Comments,'')			as 'Comments', 
							isnull(d.Error,'')				as 'Error',
							-- Получатель
							isnull(r.ShortName, '')			as 'ReceiverName',
							-- Отправитель
							isnull(s.ShortName, '')			as 'SenderName',
							-- Маркировки
							t.DataMatrixCount				as 'DataMatrixCount',

							row_number() over(order by t.Id desc)	
															as 'RowNumber',
							iif(c.CRPTDocId is null, cast(0 as bit), cast(1 as bit))	
															as 'Matched',
							cast(0 as bit)					as 'HasUnmatched',
							c.Name							as 'MatchingAuthorName'
							
						from #tempIds t 
							join CRPTDocuments d on t.Id = d.Id
							left join Contractors r on r.Id = d.SenderId
							left join Contractors s on s.Id = d.ReceiverId 
							left join (
								select   CRPTDocId, max(u.[NAME]) as 'Name'
								from CRPTDocumentWithPurchaseTaskLinks l
									left join USERS u on u.ID = l.TaskId
									group by CRPTDocId
								) c on c.CRPTDocId = d.Id 
					) r
				where r.RowNumber > @Offset and r.RowNumber <= (@Offset + @Limit)
				order by r.CRPTCreatedDate desc, r.Id desc
			end


end
