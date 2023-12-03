create proc DataMatrixCRPTWithdrawalDocumentEdit
(
    @Id							int,				-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ РґРѕРєСѓРјРµРЅС‚Р°
	@PublicId					nvarchar(128),		-- РРЅРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ РѕР±РјРµРЅР°
	@CRPTStatusId				int,				-- РЎС‚Р°С‚СѓСЃ РґРѕРєСѓРјРµРЅС‚Р° РІ Р¦Р РџРў
	
	@RegTryCount				int,				-- Р§РёСЃР»Рѕ РїРѕРїС‹С‚РѕРє РѕР±СЂР°С‰РµРЅРёСЏ Рє Р¦Р РџРў
	@Comments					nvarchar(255),		-- РљРѕРјРјРµРЅС‚Р°СЂРёР№
	@AuthorId					uniqueidentifier,	-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ Р°РІС‚РѕСЂР°
	@ActionDate					datetime,			-- Р”Р°С‚Р° РІС‹РІРѕРґР° РёР· РѕР±РѕСЂРѕС‚Р°
	@Error						nvarchar(1000),     -- СЃРѕРѕР±С‰РµРЅРёРµ РѕР± РѕС€РёР±РєРµ  
	-- Out-РїР°СЂР°РјРµС‚СЂС‹
	@ErrorMes					nvarchar(4000) out	-- РЎРѕРѕР±С‰РµРЅРёРµ РѕР± РѕС€РёР±РєР°С…
)
as
begin

	set nocount on
	set @ErrorMes = ''
	
	begin try

		update DataMatrixCRPTWithdrawalDocuments
		set 
			PublicId				= isnull(@PublicId, PublicId),
			CRPTStatusId			= isnull(@CRPTStatusId, CRPTStatusId),
			StatusId				= iif(@CRPTStatusId is null, StatusId,
											case @CRPTStatusId
												when 1 then 1
												when 2 then 2
												when 3 then 3
												when 4 then 3
												when 5 then 0
												when 6 then 0
												when 7 then 0
												when 8 then 0
												when 9 then 0
												else 0
											end
										),
			Error					= isnull(@Error, Error),
			RegTryCount				= isnull(@RegTryCount, RegTryCount),
			Comments				= isnull(@Comments, Comments),
			AuthorId				= @AuthorId,
			ActionDate				= @ActionDate,
			ChangedDate				= getdate()	
		where 
			Id = @Id

		return 0
	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

end
