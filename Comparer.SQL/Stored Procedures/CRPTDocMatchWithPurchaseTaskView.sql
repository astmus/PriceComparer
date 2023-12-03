create proc CRPTDocMatchWithPurchaseTaskView
(
	@DocId				int			-- Идентификатор накладной
) as
begin
			
	-- Накладная	
	select 
		i.Id							as 'Id',
		i.CRPTNumber					as 'PublicId',

		i.DocNumber						as 'Number',
		i.DocDate						as 'DocCreatedDate',
		i.CRPTCreatedDate				as 'InvoiceCreatedDate',
		
		i.SenderId						as 'SenderId',
		s.Name							as 'SenderName',
		i.ReceiverId					as 'RecieverId',
		r.Name							as 'RecieverName', 

		i.StatusId						as 'StatusId',
		case 
			when i.StatusId = 1 then 'В обороте'
			when i.StatusId = 3 then 'В обработке'
			when i.StatusId = 2 then 'Выбыл'
			when i.StatusId = 4 then 'Ошибка'
		end								as 'StatusName',
		
		i.CRPTType						as 'TypeId',
		t.Name							as 'TypeName',
		i.PurchaseTaskMatched			as 'Matched', 

		i.CreatedDate					as 'CreatedDate',
		i.ChangedDate					as 'ChangedDate'
	from 
		CRPTDocuments i
		join Contractors s on s.Id = i.SenderId
		join Contractors r on r.Id = i.ReceiverId
		--join Currencies cr on cr.CURRENCYID = i.CurrencyId
		join CRPTDocumentTypes t on t.Value = i.CRPTType
	where i.Id = @DocId

	-- Товары в накладной
	select
		isnull(i.OutSku,'')	as 'OutSku', 
		i.OutName			as 'OutName',
		isnull(i.ProductId, bp.ProductId)
							as 'ProductId',
		i.Quantity			as 'Quantity',
		p.SKU				as 'ProductSku',
		rtrim('(' + m.NAME + ') ' + p.NAME + ' ' + p.CHILDNAME)
							as 'ProductName'
	from 
		(select 
		isnull(i.Barcode,'')as 'OutSku', 
		i.ProductName		as 'OutName',
		i.ProductId			as 'ProductId',
		COUNT (1)			as 'Quantity'
		from CRPTDocumentItems i
		where i.DocId = @DocId
		group by 
			i.Barcode, i.ProductName, i.ProductId
		) i
		left join PRODUCTS p on p.ID = i.ProductId
		left join Manufacturers m on m.ID = p.MANID
		left join BarcodeProductIdLinks bp on bp.Barcode = i.OutName
	order by i.OutName

	select 
		i.Barcode as 'OutSku',
		i.DataMatrix as 'DataMatrix'
	from CRPTDocumentItems i
	where i.DocId = @DocId

	-- Привязки к заданиям на закупку
	select 
		t.Code				as 'Code', 
		t.PurchaseDate		as 'Date', 
		t.TaskStatus		as 'StatusId',
		case t.TaskStatus
			when 1 then 'В работе'
			when 2 then 'Подтверждено'
			when 3 then 'Закрыто'
			else '?'
		end
							as 'Status',
		t.DistributorId		as 'DistributorId',
		d.Name				as 'DistributorName',
		t.USER_ID			as 'PurchaserId',
		u.NAME				as 'PurchaserName'
	from CRPTDocumentWithPurchaseTaskLinks l
		join (
			select Code, PurchaseDate, TaskStatus, DistributorId, t.USER_ID from PurchasesTasks t
			union
			select Code, PurchaseDate, TaskStatus, DistributorId, t.USER_ID from PurchasesTasksArchive t where t.Archive = 0
		) t on t.CODE = l.TaskId and l.CRPTDocId = @DocId
		join DISTRIBUTORS d on d.ID = t.DistributorId
		join USERS u on u.ID = t.USER_ID
	order by PurchaseDate desc

end
