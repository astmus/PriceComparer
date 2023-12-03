create proc ProductMatchFromCRPTView_v2
as
begin

	select distinct
		d.Id				as 'DocumentId',
		d.CreatedDate		as 'CreatedDate',	
		d.SenderId			as 'ContractorId', 
		di.ProductName		as 'Name',	
		di.DataMatrix		as 'DataMatrix'
	from CRPTDocuments d
		join #Ids ids on ids.Id = d.Id
		join CRPTDocumentItems di on di.DocId = d.Id
		--join DataMatrixesReceive r  on di.DataMatrix = r.DataMatrix and r.ProductId is null
	where
		d.CRPTType <> 'LP_SHIP_GOODS'
		and di.ProductId is null
	order by
		d.Id

end
