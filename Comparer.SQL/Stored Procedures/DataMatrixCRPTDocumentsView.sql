create proc DataMatrixCRPTDocumentsView
(
	@DocumentId		int,					-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ РґРѕРєСѓРјРµРЅС‚Р°
	@PublicId		nvarchar(128),			-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ РґРѕРєСѓРјРµРЅС‚Р°
	@StatusId		int,					-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ СЃС‚Р°С‚СѓСЃР°
	@DateFrom		DateTime,				-- РџРµСЂРёРѕРґ СЃ 
	@DateTo			DateTime,				-- РџРµСЂРёРѕРґ РґРѕ
	@Limit			int						-- Р›РёРјРёС‚ РІС‹РІРѕРґРёРјС‹С… РґРѕРєСѓРјРµРЅС‚РѕРІ
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
			cast(iif(r.StatusId is null, 0, 1) as bit)		
									 as 'HasReceiptForOrder',
			d.PrimaryDocumentTypeId	 as 'PrimaryDocumentTypeId',
			d.PrimaryDocumentNumber	 as 'PrimaryDocumentNumber',
			d.RegTryCount			 as 'RegTryCount', 
			d.Error					 as 'Error',
			d.Comments				 as 'Comments',
			row_number() over (order by d.CreatedDate) as 'RowNo'
		from 
			DataMatrixCRPTWithdrawalDocuments d 
				join Contractors c on d.ContractorId = c.Id
				left join OrderReceipts r on r.OrderId = d.OrderId and r.StatusId = 1
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
