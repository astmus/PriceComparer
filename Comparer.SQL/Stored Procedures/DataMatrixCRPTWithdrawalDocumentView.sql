create proc DataMatrixCRPTWithdrawalDocumentView
(  
    @Id			int			-- Идентификатор документа
)
as
begin
	
	-- Документ
	select 
		d.Id,
		
		d.PublicId,
		
		d.ActionId,
		d.ActionDate,
		
		d.PrimaryDocumentDate,
		d.PrimaryDocumentNumber,
		d.PrimaryDocumentTypeId,
		d.PrimaryDocumentName, 
		d.PdfFile, 

		c.Inn, 
		c.Id as		'ContractorId',
		d.KKTId,
				
		d.CRPTStatusId,
		d.CRPTStatus,
		d.StatusId,

		d.RegTryCount, 
		d.Error,

		d.Comments, 
		d.AuthorId,	

		d.CreatedDate, 
		d.ChangedDate
	from 
		DataMatrixCRPTWithdrawalDocuments d 
		join Contractors c on d.ContractorId=c.Id
	where 
		@Id = d.Id 
			
	-- Товары с маркировкой
	select distinct
		--i.Id,
		i.DocumentId,

		i.ProductId, 
		i.ProductCost,
		i.DataMatrix, 

		i.PrimaryDocumentDate, 
		i.PrimaryDocumentTypeId,

		isnull(i.PrimaryDocumentNumber, '')					as 'PrimaryDocumentNumber',
		isnull(i.PrimaryDocumentName, '')					as 'PrimaryDocumentName',
		isnull(dm.DocStatus, 1)								as 'EdoDocStatusId',
		
		cast(iif(r.DataMatrix is null , 0, 1) as bit)		as 'DataMatrixConfirmed'
	from 
		DataMatrixCRPTWithdrawalDocumentItems i
			left join 
			(
				select 
					d.DocStatus,
					dm.DataMatrix,
					row_number() over (partition by dm.DataMatrix order by d.DocStatus) as 'RowNum'
				from
					DataMatrixCRPTWithdrawalDocumentItems i
						left join EdoInvoiceItemDataMatrixes dm on dm.DataMAtrix = i.Datamatrix
						left join EdoInvoiceItems ei on ei.Id = dm.ItemId
						left join EdoInvoices d on d.Id = ei.InvoiceId
			) dm on dm.DataMatrix = i.DataMatrix and dm.RowNum = 1
			left join 
			(
				select distinct DataMatrix
				from
				(
					select DataMatrix
					from DataMatrixesReceive
					union
					select DataMatrix
					from DataMatrixesShipment
				) t
			) r on r.DataMatrix = i.DataMatrix
	where
		i.DocumentId = @Id

end
