create proc DataMatrixCRPTPuttingDocumentView
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
		
		c.Inn, 
		c.Id as		'ContractorId',
				
		d.CRPTStatusId,
		d.CRPTStatus,
		d.StatusId,

		d.CRPTType,
		d.WMSDocumentId,

		d.PrimaryDocumentName,
		d.PrimaryDocumentNumber,
		d.PrimaryDocumentDate,
		d.PrimaryDocumentTypeId,

		d.Error,

		d.Comments, 
		d.AuthorId,	

		d.CreatedDate, 
		d.ChangedDate
	from 
		DataMatrixCRPTPuttingDocuments d 
		join Contractors c on d.ContractorId=c.Id
	where 
		@Id = d.Id 
			
	-- Маркировки
	select
		i.Id,
		i.DocumentId,

		i.ProductId, 
		i.DataMatrix,

		sdm.SUZOrderId							as 'SUZOrderId',
		isnull(sdm.IsActive, 0)					as 'SUZOrderIsActive',
		isnull(sdm.IsPrinted, 0)				as 'IsPrinted'
		
	from 
		DataMatrixCRPTPuttingDocumentItems i
			left join 
			(
				select 
					so.Id				as 'SUZOrderId',
					so.IsActive,
					soidm.DataMatrix,
					soidm.IsPrinted,
					row_number() over (partition by soidm.DataMatrix order by so.IsActive desc) as 'RowNum'
				from
					DataMatrixCRPTPuttingDocumentItems i
						left join SUZOrderItemDataMatrixes soidm on soidm.DataMatrix = i.DataMatrix 
						left join SUZOrderItems soi on soi.Id = soidm.ItemId
						left join SUZOrders so on so.Id = soi.OrderId 
			) sdm on sdm.DataMatrix = i.DataMatrix and sdm.RowNum = 1
	where
		i.DocumentId = @Id

end
