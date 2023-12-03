create proc DataMatrixCRPTWithdrawalDocumentsForRegView
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
		select @DateFrom = '20210101'

	if @DateTo is null
		select @DateTo = '99991212'

	if @Limit is null
		select @Limit = 100
   
	-- РЎС‚Р°С‚СѓСЃ "РћР¶РёРґР°РµС‚ СЂРµРіРёСЃС‚СЂР°С†РёРё"
	if (@StatusId = 2) begin

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
				cast(iif(r.OrderId is null, 0, 1) as bit)		
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
					left join 
					(
						select 
							distinct r.OrderId
						from
							OrderReceipts r  
						where
							r.StatusId = 1		-- РЈСЃРїРµС€РЅРѕ Р·Р°СЂРµРіРёСЃС‚СЂРёСЂРѕРІР°РЅ
							and r.TypeId = 1	-- Р§РµРє РїСЂРёС…РѕРґР°
					) r on r.OrderId = d.OrderId
			where
				d.StatusId = 2
				and (d.RegTryCount < 3 and (d.NextTryDate is null or (d.NextTryDate < getdate()) )) 
				/*and
				(
					d.CreatedDate >= @DateFrom		and 
					d.CreatedDate < @DateTo			and 
					(@DocumentId is null	or (@DocumentId is not null and d.Id = @DocumentId))		and 
					(@PublicId is null		or (@PublicId	is not null and d.PublicId = @PublicId))	and 
					(d.StatusId = 2)
				)*/
		) t
		where
			t.RowNo <= @Limit

	end
	-- РЎС‚Р°С‚СѓСЃ "Р’ РѕР±СЂР°Р±РѕС‚РєРµ"
	else begin 
		if (@StatusId = 4) begin

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
					cast(iif(r.OrderId is null, 0, 1) as bit)		
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
						left join 
						(
							select 
								distinct r.OrderId
							from
								OrderReceipts r  
							where
								r.StatusId = 1		-- РЈСЃРїРµС€РЅРѕ Р·Р°СЂРµРіРёСЃС‚СЂРёСЂРѕРІР°РЅ
								and r.TypeId = 1	-- Р§РµРє РїСЂРёС…РѕРґР°
						) r on r.OrderId = d.OrderId
				where
					d.CreatedDate >= @DateFrom		and 
					d.CreatedDate < @DateTo			and 
					(@DocumentId is null	or (@DocumentId is not null and d.Id = @DocumentId))	and 
					(d.PublicId is not null)	and 
					(d.StatusId = 4)
					
			) t
			where
				t.RowNo <= @Limit

		end 
	-- РћСЃС‚Р°Р»СЊРЅС‹Рµ СЃС‚Р°С‚СѓСЃС‹
		else begin

			/*select t.*
				from 
				(*/
					select
						d.Id					 as 'DocumentId',
						d.PublicId				 as 'PublicId',
						c.Id					 as 'ContractorId',
						c.ShortName				 as 'ContractorName',	
						d.StatusId				 as 'Status',	
						d.CRPTStatus			 as 'CRPTStatus',
						cast(iif(r.OrderId is null, 0, 1) as bit)		
												 as 'HasReceiptForOrder',
						d.PrimaryDocumentTypeId	 as 'PrimaryDocumentTypeId',
						d.PrimaryDocumentNumber	 as 'PrimaryDocumentNumber',
						d.RegTryCount			 as 'RegTryCount', 
						d.Error					 as 'Error',
						d.Comments				 as 'Comments'
						--row_number() over (order by d.CreatedDate) as 'RowNo'
					from 
						DataMatrixCRPTWithdrawalDocuments d 
						join Contractors c on d.ContractorId = c.Id
						left join 
						(
							select 
								distinct r.OrderId
							from
								OrderReceipts r  
							where
								r.StatusId = 1		-- РЈСЃРїРµС€РЅРѕ Р·Р°СЂРµРіРёСЃС‚СЂРёСЂРѕРІР°РЅ
								and r.TypeId = 1	-- Р§РµРє РїСЂРёС…РѕРґР°
						) r on r.OrderId = d.OrderId
					where
						d.CreatedDate >= @DateFrom		and 
						d.CreatedDate < @DateTo			and 
						(@DocumentId is null	or (@DocumentId is not null and d.Id = @DocumentId))	and 
						(@PublicId is null  or (@PublicId is not null and d.PublicId = @PublicId))	 	and 
						(@StatusId is null	or (@StatusId is not null and d.StatusId = @StatusId))
					order by 
						d.CreatedDate desc
				/*) t
			where
				t.RowNo <= @Limit*/

		end
	end

end
