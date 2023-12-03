create function PriorityForExpectedReceipt 
(
	@PurchaseTasksCode int	-- РќРѕРјРµСЂ Р·Р°РґР°РЅРёСЏРЅР° Р·Р°РєСѓРїРєСѓ
) 
returns int 
as 
begin 		

	declare @ExpectedDate datetime  -- РњРёРЅРёРјР°Р»СЊРЅР°СЏ РґР°С‚Р° РїРѕСЃС‚СѓРїР»РµРЅРёСЏ Р·Р°РєР°Р·Р°

	select	@ExpectedDate = min(co.ExpectedDate)  
			--1. РўР°Р±Р»РёС†Р° СЃРѕРґРµСЂР¶РёРјРѕРіРѕ Р·Р°РґР°РЅРёСЏ РЅР° Р·Р°РєСѓРїРєСѓ
			from PurchasesTasksContent pc	
				-- 2. РџР»Р°РЅ РїРѕР·РёС†РёР№ РЅР° Р·Р°РєСѓРїРєСѓ
				join OrdersPlans op on pc.CODE = op.PURCHASESCODE and pc.Code = @PurchaseTasksCode 
																and  op.PLANQUANTITY > 0 and op.ARCHIVE = 0
				-- 3. Р—Р°РєР°Р·С‹ СЃ РЅСѓР¶РЅС‹РјРё РїРѕР·РёС†РёСЏРјРё
				join CLIENTORDERS co on co.NUMBER = op.NUMBER 
				-- 4. РСЃРїРѕР»СЊР·СѓРµРјС‹Рµ РєСѓСЂСЊРµСЂСЃРєРёРµ РґРѕСЃС‚Р°РІРєРё  (РїРѕ РњРѕСЃРєРІРµ Рё РЎР°РЅРєС‚-РџРµС‚РµСЂР±СѓСЂРіСѓ)
				where co.DELIVERYKIND in (1, 2, 3, 4, 6, 7, 8, 12, 18, 19, 24, 30, 31, 32, 33, 34)

	-- РўРµРєСѓС‰Р°СЏ РґР°С‚Р°
	declare @Today date = getdate(),
			@DayInterval int 

		set @DayInterval = case when datepart(weekday, @Today) = 6 then 2
								else 1
							end											

	-- 5. РџСЂРѕРІРµСЂРєР° РѕС‚РіСЂСѓР·РєРё РЅР° СЃРµРіРѕРґРЅСЏ/СЃР»РµРґСѓСЋС‰РёР№ СЂР°Р±РѕС‡РёР№ РґРµРЅСЊ Рё СѓСЃС‚Р°РЅРѕРІРєР° РїСЂРёРѕСЂРёС‚РµС‚Р°
		return 
			case --when cast(@ExpectedDate as date) <= @Today then 2
				 when cast(@ExpectedDate as date) <= dateadd(day, @DayInterval, @Today)  then 2
				else 3
			end
end
