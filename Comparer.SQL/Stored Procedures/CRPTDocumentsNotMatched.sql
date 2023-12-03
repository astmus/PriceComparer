create proc CRPTDocumentsNotMatched
as
begin
			
	-- Получаем идентификаторы
	create table #DocIds
	(
		Id					int	not null
		primary key (Id)
	)
	insert #DocIds (Id)
	select
		distinct d.Id
	from CRPTDocuments d
		join CRPTDocumentItems di on d.Id = di.DocId 
		join DataMatrixes dm on dm.DataMatrix = di.DataMatrix 
		join Contractors cr on cr.Id = d.ReceiverId and cr.TypeId = 1
		left join BarcodeProductIdLinks l on dbo.AddBarCodeTo14(l.Barcode) = dm.Gtin
	where
		d.CRPTType not in ('LP_SHIP_GOODS','LP_INTRODUCE_OST','LP_SHIP_GOODS_XML','LK_RECEIPT')
		and (di.ProductId is null and l.ProductId is null)

	--1.0 Информация по документу
	select distinct 
		d.Id					as 'DocId',
		d.CRPTNumber			as 'CRPTNumber',
		d.CRPTCreatedDate		as 'CRPTCreatedDate',
		
		d.DocNumber				as 'DocNumber',
		d.DocDate				as 'DocDate',

		cs.Id					as 'SenderId',
		cs.ShortName			as 'SenderName',

		cr.Id					as 'ReceiverId',
		cr.ShortName			as 'ReceiverName' 
	from CRPTDocuments d
		join #DocIds i on d.Id = i.Id
		left join Contractors cs on cs.Id = d.SenderId
		left join Contractors cr on cr.Id = d.ReceiverId					
	order by 
		d.CRPTCreatedDate

	-- 2.0 Информация о поставщиках
	select distinct 
		doc.Id												as 'DocId',
		isnull(d.Id,'00000000-0000-0000-0000-000000000000')	as 'Id',
		isnull(d.Name,'')									as 'Name'
	from 
		CRPTDocuments doc
			join Contractors s on s.Id = doc.SenderId
			join #DocIds i on doc.Id = i.Id
			left join ContractorDistributorLinks cd on cd.ContraсtorId=s.Id 
			left join Distributors  d on d.Id=cd.DistributorId 

end
