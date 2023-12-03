create procedure BarcodesPriceRead (@session bigint) as
begin

	set nocount on
	
	begin try  
		declare @BarCodesPrice table 
		(	BarCode			nvarchar(39)		not null,
			SKU				int					not null,
			primary key (BarCode, SKU))

		-- Р’С‹Р±РѕСЂ РґР°РЅРЅС‹С… РїСЂР°Р№СЃРѕРІ
		insert @BarCodesPrice (BarCode, SKU)
		select distinct '', A.SKU
		from PRODUCTS A
			join LINKS B on B.CATALOGPRODUCTID = A.ID 
			join PRICESRECORDS C on C.RECORDINDEX = B.PRICERECORDINDEX
		where C.DELETED = 0

		-- Р’С‹Р±РѕСЂ РґСѓР±Р»РµР№
		insert BarCodesDoubles (SessionID, BatchNo1РЎ, BarCode, SKU)
		select distinct @session, '', A.BarCode, A.SKU
		from @BarCodesPrice A
			join @BarCodesPrice B on A.BarCode=B.BarCode and A.SKU<>B.SKU

		declare @BarCodesPriceWODouble table 
		(	SKU				int					not null,
			BarCode			nvarchar(39)		not null,
			primary key (SKU, BarCode))

		-- Р”Р°РЅРЅС‹Рµ Р±РµР· РґСѓР±Р»РµР№
		insert @BarCodesPriceWODouble (SKU, BarCode)
		select distinct A.SKU, A.BarCode
		from @BarCodesPrice A
		Left join BarCodesDoubles B on B.SessionID=@session and B.BatchNo1РЎ='' and B.BarCode=A.BarCode and B.SKU=A.SKU
		where B.SessionID is null

		-- Р’С‹Р±РѕСЂ РґСѓР±Р»РµР№
		insert BarCodesDoubles (SessionID, BatchNo1РЎ, BarCode, SKU)
		select distinct @session, '', A.BarCode, A.SKU
		from @BarCodesPrice A
		join BarCodes B on B.BarCode=A.BarCode and B.SKU<>A.SKU
		left join BarCodesDoubles C on C.SessionID=@session and C.BatchNo1РЎ='' and C.BarCode=A.BarCode and C.SKU=A.SKU
		where C.SessionID is null

		-- Р—Р°РїРёСЃСЊ РґР°РЅРЅС‹С… Рѕ РїРѕСЃС‹Р»РєРµ РІ РїСЂРѕС‚РѕРєРѕР»
		insert BarCodesSessionBatches (SessionID, BatchNo, BatchBegin, BatchWrite, BatchNull, BatchDuble)
		values(@session, '', getdate(), 
				isnull((select count(1) from @BarCodesPriceWODouble), 0),
				0,
				isnull((select count(1) from BarCodesDoubles where SessionID=@session and BatchNo1РЎ=''), 0))

		-- РР·РјРµРЅРµРЅРёРµ РґР°РЅРЅС‹С… Рѕ С€С‚СЂРёС… РєРѕРґР°С… С‚РѕРІР°СЂРЅС‹С… РїРѕР·РёС†РёР№
		update BarCodes set SessionIDPrice=@session--, ReportDate=getdate()
		from @BarCodesPriceWODouble A
		join BarCodes B on B.SKU=A.SKU and B.BarCode=A.BarCode

		-- Р”РѕР±Р°РІР»РµРЅРёРµ РґР°РЅРЅС‹С… Рѕ С€С‚СЂРёС… РєРѕРґР°С… С‚РѕРІР°СЂРЅС‹С… РїРѕР·РёС†РёР№
		insert BarCodes (SKU, BarCode, CtrlDigit, CtrlDigitCalc, ValidSign, BatchNo1РЎ, SessionIDPrice/*, ReportDate*/)
		select distinct A.SKU, replace(replace(A.BarCode, ' ', ''), '''', ''), null, null, 0, null, @session/*, getdate()*/
		from @BarCodesPriceWODouble A
			left join BarCodes B on B.SKU=A.SKU and B.BarCode=replace(replace(A.BarCode, ' ', ''), '''', '')
			left join BarCodes C on C.BarCode=replace(replace(A.BarCode, ' ', ''), '''', '') and C.SKU<>A.SKU
		where B.SKU is null and C.SKU is null and A.BarCode not like '%[Р°Р±РІРіРґРµС‘Р¶Р·РёР№РєР»РјРЅРѕРїСЂСЃС‚СѓС„С…С†С‡С€С‰СЉС‹СЊСЌСЋСЏРђР‘Р’Р“Р”Р•РЃР–Р—РР™РљР›РњРќРћРџР РЎРўРЈР¤РҐР¦Р§РЁР©РЄР«Р¬Р­Р®РЇ]%'
		
		return 0
	end try
	begin catch 
		
		return 1
	end catch 

end
