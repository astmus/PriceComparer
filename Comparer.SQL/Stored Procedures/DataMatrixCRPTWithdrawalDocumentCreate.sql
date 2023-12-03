create proc DataMatrixCRPTWithdrawalDocumentCreate
(
	@ActionId					int,					-- РџСЂРёС‡РёРЅР° РІС‹РІРѕРґР° РёР· РѕР±РѕСЂРѕС‚Р° 
	@ActionDate					datetime,				-- Р”Р°С‚Р° РІС‹РІРѕРґР° РёР· РѕР±РѕСЂРѕС‚Р°
	
	@PrimaryDocumentDate 		datetime,				-- Р”Р°С‚Р° РїРµСЂРІРёС‡РЅРѕРіРѕ РґРѕРєСѓРјРµРЅС‚Р° 
	@PrimaryDocumentNumber		nvarchar(128),			-- РќРѕРјРµСЂ РїРµСЂРІРёС‡РЅРѕРіРѕ РґРѕРєСѓРјРµРЅС‚Р° 
	@PrimaryDocumentTypeId		int,					-- РўРёРї РїРµСЂРІРёС‡РЅРѕРіРѕ РґРѕРєСѓРјРµРЅС‚Р° 
	@PrimaryDocumentName		nvarchar(255),			-- РќР°РёРјРµРЅРѕРІР°РЅРёРµ РїРµСЂРІРёС‡РЅРѕРіРѕ РґРѕРєСѓРјРµРЅС‚Р° !!! РћР±СЏР·Р°С‚РµР»СЊРЅРѕ, РµСЃР»Рё РІ РїРѕР»Рµ В«Р’РёРґ РїРµСЂРІРёС‡РЅРѕРіРѕ РґРѕРєСѓРјРµРЅС‚Р°В» СѓРєР°Р·Р°РЅРѕ "РџСЂРѕС‡РµРµ" !!!
	@PdfFile					nvarchar(max),			-- РџСЂРёР»РѕР¶РµРЅРЅС‹Р№ PDF С„Р°Р№Р» РІ Base64

	@ContractorId				int,					-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ РєРѕРЅС‚СЂР°РіРµРЅС‚Р°
	@KKTId						int,					-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ РљРљРў	
	
	@AuthorId					uniqueidentifier,		-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ Р°РІС‚РѕСЂР°

	-- Out-РїР°СЂР°РјРµС‚СЂС‹
	@NewId						int out,				-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ СЃРѕР·РґР°РЅРЅРѕРіРѕ РґРѕРєСѓРјРµРЅС‚Р°
	@ErrorMes					nvarchar(4000) out		-- РЎРѕРѕР±С‰РµРЅРёРµ РѕР± РѕС€РёР±РєР°С…
)
as
begin

	set nocount on

	set @ErrorMes = ''
	set @newId = -1
	
	begin try

		-- РЎРѕР·РґР°РµРј РґРѕРєСѓРјРµРЅС‚
		insert DataMatrixCRPTWithdrawalDocuments (
			ActionId, ActionDate,
			PrimaryDocumentDate, PrimaryDocumentNumber, PrimaryDocumentTypeId, PrimaryDocumentName, PdfFile,
			ContractorId, KKTId, 
			--CRPTStatusId, StatusId, 
			AuthorId
			)
		select
			@ActionId, @ActionDate,	
			@PrimaryDocumentDate, @PrimaryDocumentNumber, @PrimaryDocumentTypeId, @PrimaryDocumentName, @PdfFile,
			@ContractorId, @KKTId, 
			@AuthorId
			
		set @NewId = @@identity

		-- РЎРѕР·РґР°РµРј СЃРѕРґРµСЂР¶РёРјРѕРµ
		insert DataMatrixCRPTWithdrawalDocumentItems (
			DocumentId, 
			DataMatrix, 
			ProductId, ProductCost,
			PrimaryDocumentDate, PrimaryDocumentTypeId, PrimaryDocumentNumber, PrimaryDocumentName
		)
		select 
			@newId, 
			i.DataMatrix,
			i.ProductId, i.ProductCost,
			i.PrimaryDocumentDate, i.PrimaryDocumentTypeId,	i.PrimaryDocumentNumber, i.PrimaryDocumentName
		from
			#Items i

		return 0
	end try
	begin catch		
		set @ErrorMes = error_message()
		return 1
	end catch

end
