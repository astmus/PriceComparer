create proc CRPTDocumentsView_v3
(
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
	@DataMatrix					nvarchar(128)		-- Маркировка по документу
)
as
begin

	if @CRPTNumber is not null begin

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
			isnull(d.Comments,'')			as 'Comments', 
			isnull(d.Error,'')				as 'Error',
			-- Получатель
			isnull(r.ShortName, '')			as 'ReceiverName',
			-- Отправитель
			isnull(s.ShortName, '')			as 'SenderName',
			-- Марикровки
			count(di.DataMatrix) over (partition by d.Id)	as 'DataMatrixCount'
		from
			CRPTDocuments d
				join CRPTDocumentItems di on d.Id = di.DocId
				left join Contractors r on r.Id = d.SenderId
				left join Contractors s on s.Id = d.ReceiverId
		where
			d.CRPTNumber = @CRPTNumber
		order by d.Id
			

	end else begin

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
			isnull(d.Comments,'')			as 'Comments', 
			isnull(d.Error,'')				as 'Error',
			-- Получатель
			isnull(r.ShortName, '')			as 'ReceiverName',
			-- Отправитель
			isnull(s.ShortName, '')			as 'SenderName',
			-- Марикровки
			count(di.DataMatrix) over (partition by d.Id)	as 'DataMatrixCount'

		from
			CRPTDocuments d
				join CRPTDocumentItems di on d.Id = di.DocId
				left join Contractors r on r.Id = d.SenderId
				left join Contractors s on s.Id = d.ReceiverId
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
			(@Id			is null or (@Id				is not null and d.Id			= @Id))						and
			(@DocNumber		is null or (@DocNumber		is not null and d.DocNumber like '%' + @DocNumber + '%'))	and
			(@DataMatrix	is null or (@DataMatrix		is not null and di.DataMatrix = @DataMatrix))
		order by
			d.CRPTCreatedDate desc, d.Id

	end

end
