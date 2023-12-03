create proc DataMatrixCRPTWithdrawalDocumentCreate_v2
(
	@OrderId					uniqueidentifier,		-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ Р·Р°РєР°Р·Р° 
	@ContractorId				int,					-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ РєРѕРЅС‚СЂР°РіРµРЅС‚Р°
	
	@AuthorId					uniqueidentifier,		-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ Р°РІС‚РѕСЂР°
	-- Out-РїР°СЂР°РјРµС‚СЂС‹
	@NewId						int out,				-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ СЃРѕР·РґР°РЅРЅРѕРіРѕ РґРѕРєСѓРјРµРЅС‚Р°
	@ErrorMes					nvarchar(4000) out		-- РЎРѕРѕР±С‰РµРЅРёРµ РѕР± РѕС€РёР±РєР°С…
)
as
begin

	set nocount on

	set @ErrorMes = ''
	set @NewId = -1
	
	-- 1. РџРѕРґРіРѕС‚Р°РІР»РёРІР°РµРј Info РґР°РЅРЅС‹Рµ РґРѕРєСѓРјРµРЅС‚Р°
	declare
		@ActionId					int				= 1,		-- РџСЂРёС‡РёРЅР° РІС‹РІРѕРґР° РёР· РѕР±РѕСЂРѕС‚Р° 

		@PrimaryDocumentDate 		datetime,					-- Р”Р°С‚Р° РїРµСЂРІРёС‡РЅРѕРіРѕ РґРѕРєСѓРјРµРЅС‚Р° 
		@PrimaryDocumentNumber		nvarchar(128),				-- РќРѕРјРµСЂ РїРµСЂРІРёС‡РЅРѕРіРѕ РґРѕРєСѓРјРµРЅС‚Р° 
		@PrimaryDocumentTypeId		int,						-- РўРёРї РїРµСЂРІРёС‡РЅРѕРіРѕ РґРѕРєСѓРјРµРЅС‚Р° 
		@PrimaryDocumentName		nvarchar(255)				-- РќР°РёРјРµРЅРѕРІР°РЅРёРµ РїРµСЂРІРёС‡РЅРѕРіРѕ РґРѕРєСѓРјРµРЅС‚Р° !!! РћР±СЏР·Р°С‚РµР»СЊРЅРѕ, РµСЃР»Рё РІ РїРѕР»Рµ В«Р’РёРґ РїРµСЂРІРёС‡РЅРѕРіРѕ РґРѕРєСѓРјРµРЅС‚Р°В» СѓРєР°Р·Р°РЅРѕ "РџСЂРѕС‡РµРµ"(3) !!!

	begin try

		-- РџСЂРѕРІРµСЂСЏРµРј, С‡С‚Рѕ РЅРµС‚ РґРѕРєСѓРјРµРЅС‚РѕРІ, РєРѕС‚РѕСЂС‹Рµ СѓР¶Рµ СЃСЃС‹Р»Р°СЋС‚СЃСЏ РЅР° РґР°РЅРЅС‹Р№ Р·Р°РєР°Р·
		if exists (select 1 from DataMatrixCRPTWithdrawalDocuments d where d.OrderId = @OrderId) begin

			set @ErrorMes = 'Р”РѕРєСѓРјРµРЅС‚ РґР»СЏ СЌС‚РѕРіРѕ Р·Р°РєР°Р·Р° СѓР¶Рµ СЃСѓС‰РµСЃС‚РІСѓРµС‚!'
			return 1

		end

		select
			@PrimaryDocumentDate	= co.DATE,
			@PrimaryDocumentNumber	= iif(co.PUBLICNUMBER = '', cast(co.NUMBER as nvarchar(20)), co.PUBLICNUMBER)
		from 
			CLIENTORDERS co
		where 
			co.ID = @OrderId

		set @PrimaryDocumentTypeId	= 3 
		set @PrimaryDocumentName = 'Р—Р°РєР°Р· ' + @PrimaryDocumentNumber

		-- 1.1  РџСЂРѕРІРµСЂРєР° С‡С‚Рѕ РІСЃСЏ РјР°СЂРєРёСЂРѕРІРєР° РІ Р·Р°РєР°Р·Рµ РЅРµ РјР°СЂРєРёСЂРѕРІРєР° РїРѕ РѕСЃС‚Р°С‚РєР°Рј
		if not exists (
			select 1 
			from 
				OrderContentDataMatrixes dm
					left join SUZOrderItemDataMatrixes sodm on dm.DataMatrix = substring(sodm.DataMatrix, 1, 31)
			where
				dm.OrderId = @OrderId 
				and sodm.Id is null			
		) begin
		
			set @ErrorMes = 'Р’ Р·Р°РєР°Р·Рµ РѕС‚СЃСѓС‚СЃС‚РІСѓСЋС‚ РїРѕР·РёС†РёРё СЃ РјР°СЂРєРёСЂРѕРІРєРѕР№ РёР»Рё СЌС‚Рѕ РјР°СЂРєРёСЂРѕРІРєРё РѕСЃС‚Р°С‚РєРѕРІ! '
			return 1

		end
		
	end try
	begin catch
		set @ErrorMes = error_message()
		return 1
	end catch

	declare @trancount int
	select @trancount = @@trancount

	-- 2. РЎРѕР·РґР°РµРј РґРѕРєСѓРјРµРЅС‚
	begin try

		if @trancount = 0
			begin transaction

		-- 2.1 РЎРѕР·РґР°РµРј РґРѕРєСѓРјРµРЅС‚
		insert DataMatrixCRPTWithdrawalDocuments (
			ActionId, 
			PrimaryDocumentDate, PrimaryDocumentNumber, PrimaryDocumentTypeId, PrimaryDocumentName,
			ContractorId, 
			StatusId,
			AuthorId,
			OrderId
			)
		select
			@ActionId, 
			@PrimaryDocumentDate, @PrimaryDocumentNumber, @PrimaryDocumentTypeId, @PrimaryDocumentName, 
			@ContractorId, 
			2,
			@AuthorId,
			@OrderId
				
		set @NewId = @@identity
	
		-- 2.2 РЎРѕР·РґР°РµРј СЃРѕРґРµСЂР¶РёРјРѕРµ
		insert DataMatrixCRPTWithdrawalDocumentItems 
		(
			DocumentId, 
			DataMatrix, 
			ProductId, 
			ProductCost
		)
		select 
			@NewId, 
			dm.DataMatrix,
			c.PRODUCTID,
			c.FROZENRETAILPRICE
		from OrderContentDataMatrixes dm
				join CLIENTORDERSCONTENT c on c.CLIENTORDERID = dm.OrderId and c.ProductId = dm.ProductId
				--join PRODUCTS p
				left join SUZOrderItemDataMatrixes sodm on dm.DataMatrix = substring(sodm.DataMatrix, 1, 31)
		where
			dm.OrderId = @OrderId
			and isnull(c.IS_GIFT, 0) = 0
			--and isnull(c.FROZENRETAILPRICE, 0) > 0
			and sodm.Id is null

		---- 2.4 РџСЂРѕРІРµСЂСЏРµРј, С‡С‚Рѕ РёРјРµСЋС‚СЃСЏ РЅРµСЃРѕРїРѕСЃС‚Р°РІР»РµРЅРЅС‹Рµ РїРѕР·РёС†РёРё, РїРѕРјРµС‡Р°РµРј РЅР°Р»РёС‡РёРµ С‚Р°РєРёС… РїРѕР·РёС†РёР№
		--if exists 
		--(
		--	select 1 from DataMatrixCRPTWithdrawalDocumentItems i where i.DocumentId = @NewId and i.ProductId is null
		--)
		--begin
			
		--	update d
		--	set 
		--		d.StatusId = 3,
		--		d.Comments = 'РќРµРєРѕС‚РѕСЂС‹Рµ РјР°СЂРєРёСЂРѕРІРєРё РЅРµ СЃРѕРїРѕСЃС‚Р°РІР»РµРЅРЅС‹ СЃ С‚РѕРІР°СЂР°РјРё!'
		--	from 
		--		DataMatrixCRPTWithdrawalDocuments d
		--	where
		--		d.ID = @NewId

		--end

		if @trancount = 0
			commit transaction

		return 0

	end try
	begin catch		

		if @trancount = 0
			rollback transaction
		
		set @ErrorMes = error_message()
		return 1

	end catch

end
