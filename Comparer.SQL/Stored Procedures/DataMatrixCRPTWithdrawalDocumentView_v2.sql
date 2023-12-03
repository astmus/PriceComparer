create proc DataMatrixCRPTWithdrawalDocumentView_v2
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
		
		i.DocumentId,

		i.ProductId, 
		i.ProductCost,

		i.DataMatrix, 
		case
			when km.DataMatrix is null then 'None'
			when km.DataMatrix is not null and km.StatusId = 1 then 'Introduced'
			when km.DataMatrix is not null and km.StatusId in (2, 6) then 'Retired'
			when km.DataMatrix is not null and km.StatusId in (0, 7, 9) then 'Undefined'
			else 'Undefined'
		end													as 'DataMatrixState',
		isnull(doc.DocStatus, 1)							as 'EdoDocStatusId'
	from 
		DataMatrixCRPTWithdrawalDocumentItems i
		-- Определяем документ из ЭДО
		left join 
		(
			select 
				d.DocStatus,
				dm.DataMatrix,
				row_number() over (partition by dm.DataMatrix order by d.DocStatus) as 'RowNum'
			from
				DataMatrixCRPTWithdrawalDocumentItems i
					left join EdoInvoiceItemDataMatrixes dm on dm.DataMatrix = i.Datamatrix
					left join EdoInvoiceItems ei on ei.Id = dm.ItemId
					left join EdoInvoices d on d.Id = ei.InvoiceId
			where
				i.DocumentId = @Id
		) doc on doc.DataMatrix = i.DataMatrix and doc.RowNum = 1
		-- Проверяем статусы маркировки
		left join DataMatrixes km on km.DataMatrix = i.DataMatrix
	where
		i.DocumentId = @Id

end
