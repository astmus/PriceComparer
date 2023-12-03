create procedure Barcodes1CBatchRead (@session bigint, @BatchNo char(10)) as
begin

	set nocount on
	
	begin try  

		declare @BarCodes1C table 
		(	
			BarCode			nvarchar(39)		not null,
			SKU				int					not null,
			primary key (BarCode, SKU)
		)

		-- РџРѕР»СѓС‡Р°РµРј РІСЃРµ С€С‚СЂРёС…-РєРѕРґС‹ РёР· СѓРєР°Р·Р°РЅРЅРѕР№ РїР°С‡РєРё
		insert @BarCodes1C (BarCode, SKU)
		select distinct [РЁС‚СЂРёС…РєРѕРґ], [РђСЂС‚РёРєСѓР»]
		from IM..[РўРµРєСѓС‰РёРµРЁС‚СЂРёС…РєРѕРґС‹] 
		where [РќРѕРјРµСЂРџРѕСЃС‹Р»РєРё]=@BatchNo and [РђСЂС‚РёРєСѓР»] is not null and rtrim(isnull([РЁС‚СЂРёС…РєРѕРґ], ''))<>''

		-- РЎРѕС…СЂР°РЅСЏРµРј РґСѓР±Р»Рё РІ РїСЂРѕС‚РѕРєРѕР»
		insert BarCodesDoubles (SessionID, BatchNo1РЎ, BarCode, SKU)
		select distinct @session, @BatchNo, A.BarCode, A.SKU
		from @BarCodes1C A
		join @BarCodes1C B on B.BarCode=A.BarCode and B.SKU<>A.SKU

		declare @BarCodes1CWODouble table 
		(	SKU				int					not null,
			BarCode			nvarchar(39)		not null,
			primary key (SKU, BarCode))

		-- РџРѕР»СѓС‡Р°РµРј С‰С‚СЂРёС…-РєРѕРґС‹ Р±РµР· РґСѓР±Р»РµР№
		insert @BarCodes1CWODouble (SKU, BarCode)
		select distinct A.SKU, A.BarCode
		from @BarCodes1C A
		Left join BarCodesDoubles B on B.SessionID=@session and B.BatchNo1РЎ=@BatchNo and B.BarCode=A.BarCode and B.SKU=A.SKU
		where B.SessionID is null

		-- РЎРѕС…СЂР°РЅСЏРµРј РґР°РЅРЅС‹С… Рѕ РїР°С‡РєРµ РІ РїСЂРѕС‚РѕРєРѕР»
		insert BarCodesSessionBatches (SessionID, BatchNo, BatchBegin, BatchWrite, BatchNull, BatchDuble)
		values(@session, @BatchNo, getdate(), 
				isnull((select count(1) from @BarCodes1CWODouble), 0),
				isnull((select count(1) from IM..[РўРµРєСѓС‰РёРµРЁС‚СЂРёС…РєРѕРґС‹] where [РќРѕРјРµСЂРџРѕСЃС‹Р»РєРё]=@BatchNo and ([РђСЂС‚РёРєСѓР»] is null or [РЁС‚СЂРёС…РєРѕРґ] is null)), 0),
				isnull((select count(1) from BarCodesDoubles where SessionID=@session and BatchNo1РЎ=@BatchNo), 0))

		-- РЈРґР°Р»РµРЅРёРµ С€С‚СЂРёС…-РєРѕРґС‹, РєРѕС‚РѕСЂС‹Рµ СЂР°РЅРµРµ Р±С‹Р»Рё Р·Р°РіСЂСѓР¶РµРЅС‹ РёР· 1РЎ
		delete BarCodes
		from (
			select distinct SKU from @BarCodes1CWODouble
		) A
			join BarCodes B on B.SKU=A.SKU
		where B.BatchNo1РЎ is not null and B.SessionIDPrice is null

		-- РЎРѕС…СЂР°РЅСЏРµРј РґСѓР±Р»Рё, РєРѕС‚РѕСЂС‹Рµ СѓР¶Рµ РµСЃС‚СЊ РІ Р±Р°Р·Рµ РґР°РЅРЅС‹С…, РІ РїСЂРѕС‚РѕРєРѕР»Рµ
		insert BarCodesDoubles (SessionID, BatchNo1РЎ, BarCode, SKU)
		select distinct @session, @BatchNo, A.BarCode, A.SKU
		from @BarCodes1CWODouble A
			join BarCodes B on B.BarCode=A.BarCode and B.SKU<>A.SKU
			left join BarCodesDoubles C on C.SessionID=@session and C.BatchNo1РЎ=@BatchNo and C.BarCode=A.BarCode and C.SKU=A.SKU
		where C.SessionID is null

		-- РћР±РЅРѕРІР»СЏРµРј С€С‚СЂРёС…-РєРѕРґС‹, РєРѕС‚РѕСЂС‹Рµ СЂР°РЅРµРµ Р±С‹Р»Рё Р·Р°РіСЂСѓР¶РµРЅС‹ РёР· 1РЎ
		update BarCodes 
		set BatchNo1РЎ = @BatchNo				--, ReportDate=getdate()
		from @BarCodes1CWODouble A
			join BarCodes B on B.SKU=A.SKU and B.BarCode=A.BarCode

		-- Р’СЃС‚Р°РІР»СЏРµРј РЅРѕРІС‹Рµ С€С‚СЂРёС…-РєРѕРґС‹
		insert BarCodes (SKU, BarCode, CtrlDigit, CtrlDigitCalc, ValidSign, BatchNo1РЎ, SessionIDPrice/*, ReportDate*/)
		select distinct A.SKU, replace(replace(A.BarCode, ' ', ''), '''', ''), null, null, 0, @BatchNo, null/*, getdate()*/
		from @BarCodes1CWODouble A
			left join BarCodes B on B.SKU=A.SKU and B.BarCode=replace(replace(A.BarCode, ' ', ''), '''', '')
			left join BarCodes C on C.BarCode=replace(replace(A.BarCode, ' ', ''), '''', '') and C.SKU<>A.SKU
		where B.SKU is null and C.SKU is null and A.BarCode not like '%[Р°Р±РІРіРґРµС‘Р¶Р·РёР№РєР»РјРЅРѕРїСЂСЃС‚СѓС„С…С†С‡С€С‰СЉС‹СЊСЌСЋСЏРђР‘Р’Р“Р”Р•РЃР–Р—РР™РљР›РњРќРћРџР РЎРўРЈР¤РҐР¦Р§РЁР©РЄР«Р¬Р­Р®РЇ]%'
		
		return 0
	end try
	begin catch 
		
		return 1
	end catch 

end
