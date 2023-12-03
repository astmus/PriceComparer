create proc DataMatrixCRPTPuttingDocumentsView
(
	@DocumentId		int,					-- Идентификатор документа
	@PublicId		nvarchar(128),			-- Идентификатор документа
	@StatusId		int,					-- Идентификатор статуса
	@DateFrom		DateTime,				-- Период с 
	@DateTo			DateTime,				-- Период до
	@Limit			int						-- Лимит выводимых документов
)
as
begin

	if @DateFrom is null
		select @DateFrom = '20210401'

	if @DateTo is null
		select @DateTo = '99991212'

	if @Limit is null
		select @Limit = 100
   
	select t.*
	from 
	(
		select
			d.Id					 as 'DocumentId',
			d.PublicId				 as 'PublicId',
			c.Id					 as 'ContractorId',
			c.ShortName				 as 'ContractorName',
			d.StatusId				 as 'Status',	
			d.CRPTStatus			 as 'CRPTStatus',
			d.CRPTType				 as 'CRPTType',

			null					as 'WMSDocumentId',

			d.Error					 as 'Error',
			d.Comments				 as 'Comments',
			row_number() over (order by d.CreatedDate) as 'RowNo'
		from 
			DataMatrixCRPTPuttingDocuments d 
				join Contractors c on d.ContractorId = c.Id
		where
			d.CreatedDate >= @DateFrom		and 
			d.CreatedDate < @DateTo			and 
			(@DocumentId is null	or (@DocumentId is not null and d.Id = @DocumentId))		and 
			(@PublicId is null		or (@PublicId	is not null and d.PublicId = @PublicId))	and 
			(@StatusId is null		or (@StatusId	is not null and d.StatusId = @StatusId))
	) t
	where
		t.RowNo <= @Limit

end
