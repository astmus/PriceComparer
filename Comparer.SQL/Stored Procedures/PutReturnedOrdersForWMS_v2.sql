create proc PutReturnedOrdersForWMS_v2 
(
	@OrderId		uniqueidentifier,						-- РРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ Р·Р°РєР°Р·Р°
	@Operation		int,									-- РћРїРµСЂР°С†РёСЏ

	-- Out РїР°СЂР°РјРµС‚СЂС‹
	@ErrorMes		nvarchar(4000)		out							-- РЎРѕРѕР±С‰РµРЅРёРµ РѕР± РѕС€РёР±РєР°С…		
) as
begin

	set @ErrorMes = ''
	set nocount on

	-- РџСЂРѕРІРµСЂСЏРµРј РµСЃР»Рё РћР¶РёРґР°РµРјР°СЏ РїСЂРёРµРјРєР° СѓР¶Рµ СЃРѕР·РґР°РЅР° - РІС‹С…РѕРґРёРј
	if exists (select 1 from WmsExpectedReceiptDocuments w where w.SourceDocumentId =@OrderId)
		return 0

	declare 
		@now		datetime			= getdate(),
		@Source		varchar(10)			= 'rdw-',
		@SiteId		uniqueidentifier	= (select c.SiteId from clientorders c where c.ID = @OrderId)

	-- Р•СЃР»Рё РёРґРµРЅС‚РёС„РёРєР°С‚РѕСЂ СЃР°Р№С‚Р° РѕРїСЂРµРґРµР»РµРЅ
	if @SiteId is not null begin

		set @Source = 
			case @SiteId
				when '14F7D905-31CB-469A-91AC-0E04BC8F7AF3' then 'R-'
				when 'B30E878A-C805-436E-9EAC-7865337DBEA8' then 'yandex-'
				when 'FABE80CF-AC99-4064-8F2E-CFA701C3E59A' then 'sber-'
				when '5D4463C6-EBA6-4DD5-8618-D07AE3A23D9A' then 'ozon-'
				else 'rdw-'
			end
	end

	declare @trancount int
	select @trancount  = @@TRANCOUNT

	begin try
	
		if @trancount = 0
			begin transaction 
			
			--  Р”РѕР±Р°РІР»СЏРµРј Р’РѕР·РІСЂР°С‰РµРЅРЅС‹Рµ Р·Р°РєР°Р·С‹ 
			
			-- Р”РѕР±Р°РІР»СЏРµРј Р’РѕР·РІСЂР°С‰РµРЅРЅС‹Рµ РїРѕ СЃС‚Р°С‚СѓСЃСѓ 'Р’РѕР·РІСЂР°С‰РµРЅ РІ РјР°РіР°Р·РёРЅ' РёР· РўРљ Р·Р°РєР°Р·С‹
			insert WmsExpectedReceiptDocuments (PublicId, Number, WmsCreateDate, ExpectedDate, DocStatus,
												DocSource, IsDeleted, SourceDocumentId, Comments, AuthorId, Operation, CreateDate)
			select newid(), @Source + iif(C.PUBLICNUMBER = '', cast(C.NUMBER as varchar(10)), C.PUBLICNUMBER) + '-r',
				@now, @now, 1, 2, 0, C.ID, 'РђРІС‚РѕРјР°С‚РёС‡РµСЃРєРё СЃРѕР·РґР°РЅРЅР°СЏ РћР¶РёРґР°РµРјР°СЏ РїСЂРёРµРјРєР°', '310FAFF6-9306-44EA-AEA5-44E43C0D5F39', 1, @now
			from CLIENTORDERS C 
			where C.Id = @OrderId and 
				not exists (select 1 from WmsExpectedReceiptDocuments rd where rd.PublicId = @OrderId)
			
			-- Р”РѕР±Р°РІР»СЏРµРј С‚РѕРІР°СЂРЅС‹Рµ РїРѕР·РёС†РёРё Р’РѕР·РІСЂР°С‰РµРЅРЅС‹С… Р·Р°РєР°Р·РѕРІ РІ С‚Р°Р±Р»РёС†Сѓ "РўРѕРІР°СЂС‹ РѕР¶РёРґР°РµРјРѕР№ РїСЂРёРµРјРєРё"
			insert WmsExpectedReceiptDocumentsItems (DocId, TaskId, ProductId, Sku, Quantity, ForOrder, DataMatrixExpected, CreateDate)
			select d.Id, @OrderId, p.ID, p.SKU, OC.QUANTITY, 0, iif(dm.ProductId is null, 0, 1), @now
			from WmsExpectedReceiptDocuments d
				join CLIENTORDERSCONTENT OC on OC.CLIENTORDERID = @OrderId
				join PRODUCTS p on p.ID = OC.PRODUCTID
				left join
				(
					select 
						distinct odm.ProductId
					from
						OrderContentDataMatrixes odm
						join DataMatrixes dm on odm.DataMatrix = dm.DataMatrix
						left join SUZOrderItemDataMatrixes suz on odm.DataMatrix = substring(suz.DataMatrix, 1, 31)
					where
						odm.OrderId = @OrderId and
						odm.ProductId is not null
						and suz.DataMatrix is null
						
				) dm on dm.ProductId = OC.PRODUCTID
			where d.SourceDocumentId = @OrderId and 
				not exists (select 1 from WmsExpectedReceiptDocumentsItems i where i.DocId = d.Id and i.TaskId = @OrderId and i.Sku = P.SKU)
			
			-- Р’СЃС‚Р°РІР»СЏРµРј РЅРѕРІС‹Рµ Р·Р°РїРёСЃРё РІ С‚Р°Р±Р»РёС†Сѓ ExportPurchaseTasks
			insert ExportPurchaseTasks (TaskId, Operation)
			values (@OrderId, @Operation)
		
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
