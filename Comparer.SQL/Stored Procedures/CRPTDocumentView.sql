create proc CRPTDocumentView
(
	@Id			int				-- Идентификатор документа
)
as
begin

	-- 1.Документ

	select
		
		d.Id							as 'Id',
		-- ЦРПТ
		d.CRPTNumber					as 'CRPTNumber', 
		d.CRPTInput						as 'CRPTInput', 
		d.CRPTCreatedDate				as 'CRPTCreatedDate', 
		d.CRPTType						as 'CRPTType', 
		isnull(dt.Name, '')				as 'CRPTTypeName', 
		d.CRPTStatus					as 'CRPTStatus', 
		isnull(ds.Name, '')				as 'CRPTStatusName', 
		-- Документ
		d.DocNumber						as 'DocNumber', 
		d.DocDate						as 'DocDate', 
		isnull(d.DocAction, '')			as 'DocAction',
		isnull(d.DocActionDate, '')		as 'DocActionDate',
		isnull(d.DocPrimaryType, '')	as 'DocPrimaryType',
		isnull(d.DocTypeName, '')		as 'DocTypeName',
		-- Внутренняя информация
		d.SenderId						as 'SenderId', 
		isnull(d.ReceiverId,0)			as 'ReceiverId', 
		d.StatusId						as 'StatusId', 
		-- Аннулирование
		d.IsCRPTCancelled				as 'IsCRPTCancelled',
		d.CancellationCRPTNumber		as 'CancellationCRPTNumber', 
		d.CancellationDocDate			as 'CancellationDocDate',
		-- Служебная информация
		isnull(d.Comments, '')			as 'Comments', 
		isnull(d.Error, '')				as 'Error',
		d.CreatedDate					as 'CreatedDate',
		d.ChangedDate					as 'ChangedDate',
		-- Получатель
		isnull(r.Inn,'')				as 'ReceiverInn',
		isnull(r.ShortName, '')			as 'ReceiverName',
		-- Отправитель
		s.Inn							as 'SenderInn',
		isnull(s.ShortName, '')			as 'SenderName'
	from
		CRPTDocuments d
			left join Contractors r on r.Id = d.ReceiverId
			left join Contractors s on s.Id = d.SenderId
			left join CRPTDocumentStatuses ds on d.CRPTStatus = ds.Value
			left join CRPTDocumentTypes dt on d.CRPTType = dt.Value
	where
		d.Id = @Id

	-- 2. Содержимое

	select
		-- Позиция в документе
		di.Id							as 'Id',
		di.Barcode						as 'Barcode',
		di.DataMatrix					as 'DataMatrix',
		di.ProductId					as 'ProductId',
		-- Товар
		m.ID							as 'BrandId',
		m.NAME							as 'BrandName',
		ltrim(p.NAME + ' ' + p.CHILDNAME)
										as 'ProductName',
		di.ProductName					as 'CRPTProductName'
	from 
		CRPTDocumentItems di
			left join PRODUCTS p on p.ID = di.ProductId
			left join MANUFACTURERS m on m.ID = p.MANID
	where
		di.DocId = @Id
	order by
		m.NAME,
		p.NAME,
		p.CHILDNAME,
		di.DataMatrix

	-- 3. Связанный документ из ЭДО
	select
		d.Id			as 'Id',
		d.Number		as 'Number',
		case d.DocStatus	
			when 1 then 'Подписан'
			when 2 then 'На согласовании'
			when 4 then 'Анулирован'
			else '?'
		end	
						as 'Status',
		d.ChangedDate	as 'ChangedDate'
	--from
	--	CRPTWithEDODocumentLinks l
	--		join EdoInvoices d on d.Id = l.EDODocId
	--where
	--	l.CRPTDocId = @Id
	from DocumentEdoCRPTLinks l
			join EdoInvoices d on d.Id = l.DocumentEdoId
	where
		l.DocumentCRPTId = @Id

	-- 4. Связанный связанные задания на закупку
	select
		-- Задание на закупку
		t.CODE				as 'Code',
		t.PURCHASEDATE		as 'Date',
		t.TASK_TYPE			as 'TypeId',
		t.DISTRIBUTORID		as 'DistributorId',
		t.USER_ID			as 'PurchaserId',
		case t.TaskStatus
			when 1 then 'В работе'
			when 2 then 'Подтверждено'
			when 3 then 'Закрыто'
			else '?'
		end
							as 'Status',
		-- Поставщик
		isnull(d.NAME,'?')	as 'DistributorName',
		-- Закупщик
		isnull(u.NAME,'?')	as 'PurchaserName'
	from
	(
		select 
			t.*,
			row_number() over (partition by t.CODE order by t.TaskStatus desc) as 'RowNum'
		from
		(
				select 
					t.CODE,
					t.PURCHASEDATE,
					t.TASK_TYPE,
					t.DISTRIBUTORID,
					t.USER_ID,
					t.TaskStatus
				from
					CRPTDocumentWithPurchaseTaskLinks l
						join PurchasesTasks t on t.CODE = l.TaskId and l.CRPTDocId = @Id
				union
				select 
					t.CODE,
					t.PURCHASEDATE,
					t.TASK_TYPE,
					t.DISTRIBUTORID,
					t.USER_ID,
					t.TaskStatus				
				from
					CRPTDocumentWithPurchaseTaskLinks l
						join PurchasesTasksArchive t on t.CODE = l.TaskId and l.CRPTDocId = @Id
			) t
	) t
		left join DISTRIBUTORS d on d.ID = t.DISTRIBUTORID
		left join USERS u on u.ID = t.USER_ID
	where
		t.RowNum = 1

end
