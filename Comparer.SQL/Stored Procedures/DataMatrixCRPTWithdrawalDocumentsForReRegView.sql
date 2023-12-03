create proc DataMatrixCRPTWithdrawalDocumentsForReRegView
as
begin 

	declare 
		@now  date = getdate()

	-- Документы
	select 
		d.Id					 as 'DocumentId',
		d.PublicId				 as 'PublicId',
		c.Id					 as 'ContractorId',
		c.ShortName				 as 'ContractorName',	
		d.StatusId				 as 'Status',	
		d.CRPTStatus			 as 'CRPTStatus',
		cast(0 as bit)			 as 'HasReceiptForOrder',
		d.PrimaryDocumentTypeId	 as 'PrimaryDocumentTypeId',
		d.PrimaryDocumentNumber	 as 'PrimaryDocumentNumber',
		d.RegTryCount			 as 'RegTryCount', 
		d.Error					 as 'Error',
		d.Comments				 as 'Comments',
		row_number() over (order by d.CreatedDate) as 'RowNo'
	from
		DataMatrixCRPTWithdrawalDocuments d 
		join Contractors c on d.ContractorId = c.Id		
	where 
		cast(d.CreatedDate as date) >= dateadd(day, -2, @now) and 
		cast(d.CreatedDate as date) <= @now and	
		not exists (select 1 from OrderReceipts r where r.OrderId = d.OrderId and r.StatusId = 1) and
		d.StatusId = 3 and
		(
			d.Error like '[[]1004]%' 
			or  
			d.Error like '[[]1002]%'
		) and
		d.RegTryCount < 3
	
end
