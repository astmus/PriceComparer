create proc DeliveryServiceStatusesUpdate
as
begin

	/*
	select cast(o.ID as varchar(36)),901,2,'{"OrderId":"' + cast(o.ID as varchar(36)) + '","TKStatusId":4}', 2, '87123EAD-3F71-4BDA-ACFD-361011C99CEB'
	from #ordersStatuses os 
		join CLIENTORDERS o ON os.DispatchNumber = o.DISPATCHNUMBER --and os.StatusId = 4 and o.STATUS not in (3,5,6)
	*/

	-- 29-01-2019
	-- РЈРґР°Р»СЏРµРј Р·Р°РїРёСЃРё РґР»СЏ Р·Р°РєР°Р·РѕРІ, РєРѕС‚РѕСЂС‹Рµ СѓР¶Рµ РЅР°С…РѕРґСЏС‚СЃСЏ РІ СѓРєР°Р·Р°РЅРЅС‹С… СЃС‚Р°С‚СѓСЃР°С…
	delete ordst
	from #ordersStatuses ordst
		join CLIENTORDERS o ON ordst.DispatchNumber = o.DISPATCHNUMBER
		join ApiDeliveryServiceOrders dso ON dso.InnerId = o.ID
	where
		ordst.StatusId = dso.StatusId 
		and ordst.StatusDate = dso.ChangedDate

	-- РЈРґР°Р»СЏРµРј Р·Р°РїРёСЃРё СЃ РїСѓСЃС‚С‹Рј РќРѕРјРµСЂРѕРј РѕС‚РїСЂР°РІР»РµРЅРёСЏ
	delete #ordersStatuses where DispatchNumber = ''

	-- Р•СЃР»Рё Р·Р°РїРёСЃРµР№ РЅРµ РѕСЃС‚Р°Р»РѕСЃСЊ
	if not exists (select 1 from #ordersStatuses)
		return 0

	-- РђСЂС…РёРІРёСЂСѓСЋ С‚РµРєСѓС‰РёР№ СЃС‚Р°С‚СѓСЃ Р·Р°РєР°Р·РѕРІ
	insert ApiDeliveryServiceOrderStatusesHistory (InnerId, StatusId, StatusDate)
		select
			dso.InnerId, dso.StatusId, dso.ChangedDate
		from
			#ordersStatuses os 
			join CLIENTORDERS o ON os.DispatchNumber = o.DISPATCHNUMBER
			join ApiDeliveryServiceOrders dso ON o.ID = dso.InnerId

	-- РћР±РЅРѕРІР»СЏРµРј СЃС‚Р°С‚СѓСЃС‹
	update dso
	set StatusId	= os.StatusId, 
		ChangedDate = os.StatusDate
	from #ordersStatuses os 			
		join CLIENTORDERS o ON os.DispatchNumber = o.DISPATCHNUMBER
		join ApiDeliveryServiceOrders dso ON o.ID = dso.InnerId


	-- Р”РѕР±Р°РІР»СЏРµРј Р·Р°РїРёСЃРё РІ РѕС‡РµСЂРµРґСЊ РЅР° РѕР±СЂР°Р±РѕС‚РєСѓ

	-- СЃС‚Р°С‚СѓСЃ "РџРѕР»СѓС‡РµРЅ РєР»РёРµРЅС‚РѕРј"
	declare @authorId uniqueidentifier = '4966E5F3-3A47-433D-872C-E525BE1DC096'
	
	insert ActionsProcessingQueue 
		(ObjectId, ObjectTypeId, OperationId, ActionObject, PriorityLevel, AuthorId)
	select
		cast(o.ID as varchar(36)), 901, 2, '{"OrderId":"' + cast(o.ID as varchar(36)) + '","TKStatusId":4}', 2, @authorId
	from
		#ordersStatuses os 
		join CLIENTORDERS o ON os.DispatchNumber = o.DISPATCHNUMBER 
			and os.StatusId = 4 
			and o.STATUS not in (3, 5, 6)
		join ApiDeliveryServiceOrders dso ON o.ID = dso.InnerId

	-- СЃС‚Р°С‚СѓСЃ "Р’РѕР·РІСЂР°С‰РµРЅ РІ РјР°РіР°Р·РёРЅ"
	insert ActionsProcessingQueue 
		(ObjectId, ObjectTypeId, OperationId, ActionObject, PriorityLevel, AuthorId)
	select
		cast(o.ID as varchar(36)), 901, 2, '{"OrderId":"' + cast(o.ID as varchar(36)) + '","TKStatusId":5}', 2, @authorId
	from
		#ordersStatuses os 		
		join CLIENTORDERS o ON os.DispatchNumber = o.DISPATCHNUMBER 
			and os.StatusId = 5
		join ApiDeliveryServiceOrders dso ON o.ID = dso.InnerId

	-- СЃС‚Р°С‚СѓСЃ "РЈС‚РµСЂСЏРЅ"
	insert ActionsProcessingQueue 
		(ObjectId, ObjectTypeId, OperationId, ActionObject, PriorityLevel, AuthorId)
	select
		cast(o.ID as varchar(36)), 901, 2, '{"OrderId":"' + cast(o.ID as varchar(36)) + '","TKStatusId":14}', 2, @authorId
	from
		#ordersStatuses os 		
		join CLIENTORDERS o ON os.DispatchNumber = o.DISPATCHNUMBER 
			and os.StatusId = 14
		join ApiDeliveryServiceOrders dso ON o.ID = dso.InnerId

	return 0
end
