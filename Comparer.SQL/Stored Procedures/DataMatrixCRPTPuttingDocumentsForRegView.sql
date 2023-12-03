create proc DataMatrixCRPTPuttingDocumentsForRegView
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

  -- Выбираем записи для процесса регистрации   
   if (@StatusId is not null and @StatusId = 2)
   begin
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
			d.WMSDocumentId 		 as 'WMSDocumentId',
			d.PrimaryDocumentName 	 as 'PrimaryDocumentName',
			d.PrimaryDocumentNumber	 as 'PrimaryDocumentNumber',	
			d.PrimaryDocumentDate 	 as 'PrimaryDocumentDate',
			d.PrimaryDocumentTypeId	 as 'PrimaryDocumentTypeId', 
			d.Error					 as 'Error',
			d.Comments				 as 'Comments',
			row_number() over (order by d.CreatedDate) as 'RowNo'
		from 
			DataMatrixCRPTPuttingDocuments d 
				join Contractors c on d.ContractorId = c.Id
		where
			(@DateFrom is null or (@DateFrom  is not null and d.CreatedDate >= @DateFrom))		and 
			(@DateTo is null or (@DateTo is not null and  d.CreatedDate < @DateTo))			and 
			(@DocumentId is null or (@DocumentId is not null and d.Id = @DocumentId))		and 
			(PublicId is null)	 and 
			(StatusId=2)	 	 and 
			(RegTryCount <= 3)   and 
			(NextTryDate is null or (NextTryDate is not null and getdate() > NextTryDate))
	) t
	where
		t.RowNo <= @Limit
   end
    -- Выбираем записи для процесса опроса статуса
   else 
   if (@StatusId is not null and @StatusId = 4)
   begin

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
			null			 		 as 'WMSDocumentId',
			d.PrimaryDocumentName 	 as 'PrimaryDocumentName',
			d.PrimaryDocumentNumber	 as 'PrimaryDocumentNumber',	
			d.PrimaryDocumentDate 	 as 'PrimaryDocumentDate',
			d.PrimaryDocumentTypeId	 as 'PrimaryDocumentTypeId', 
			d.Error					 as 'Error',
			d.Comments				 as 'Comments',
			row_number() over (order by d.CreatedDate) as 'RowNo'
		from 
			DataMatrixCRPTPuttingDocuments d 
				join Contractors c on d.ContractorId = c.Id
		where
			(@DateFrom is null or (@DateFrom is not null and d.CreatedDate >= @DateFrom))		and 
			(@DateTo is null or (@DateTo is not null and  d.CreatedDate < @DateTo))			and 
			(@DocumentId is null	or (@DocumentId is not null and d.Id = @DocumentId))		and 
			(PublicId is not null) 	and 
			(StatusId=4) 
	) t
	where
		t.RowNo <= @Limit
	end
	-- выбираем записи для других статусов
	else 
	begin
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
			null			 		 as 'WMSDocumentId',
			d.PrimaryDocumentName 	 as 'PrimaryDocumentName',
			d.PrimaryDocumentNumber	 as 'PrimaryDocumentNumber',	
			d.PrimaryDocumentDate 	 as 'PrimaryDocumentDate',
			d.PrimaryDocumentTypeId	 as 'PrimaryDocumentTypeId', 
			d.Error					 as 'Error',
			d.Comments				 as 'Comments',
			row_number() over (order by d.CreatedDate) as 'RowNo'
		from 
			DataMatrixCRPTPuttingDocuments d 
				join Contractors c on d.ContractorId = c.Id
		where
			(@DateFrom is null or (@DateFrom  is not null and d.CreatedDate >= @DateFrom))		and 
			(@DateTo is null or (@DateTo is not null and  d.CreatedDate < @DateTo))				and 
			(@DocumentId is null	or (@DocumentId is not null and d.Id = @DocumentId))		and 
			(@PublicId is null  or (@PublicId is not null and d.PublicId=@PublicId))	 		and 
			(@StatusId is null	or (@StatusId is not null and d.StatusId = @StatusId))
	) t
	where
		t.RowNo <= @Limit

	end
end
