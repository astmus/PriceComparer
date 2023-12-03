--
-- Процедура возвращает полностью обеспеченные складом заказы согласно заданным условиям
-- Содержимое ХП формируется динамически в коде
--
--if exists(select 1 from sysobjects where name = N'GetCompleteOrdersForWMSExport' and xtype='P') drop proc GetCompleteOrdersForWMSExport
--go
create proc GetCompleteOrdersForWMSExport_v3 as
begin
	
	select o.ID
	from CLIENTORDERS o
		left join WmsShipmentDocuments d on o.ID = d.PublicId and d.WarehouseId = 1
	where 
		(o.STATUS = 2 or (o.STATUS = 4 and exists (select 1 from ORDERSSTATUSHISTORY h where h.CLIENTORDER = o.ID and h.STATUS = 4 and h.AUTHOR <> 'sa')))
		and o.PACKED = 0 
		and (d.DocStatus is null or (d.DocStatus is not null and d.DocStatus <> 10))
		and o.DELIVERYKIND > 0		
		--and o.CLIENTID not in ('498EF36F-4211-4B72-8A40-BAE4175AEEA5','79CD61D2-988A-471E-B73F-71EBC63BB0AB','BA11349E-5EA0-465D-904A-61D6E381E6DC') -- Не Escentric
		and (o.ExpectedDate < cast(cast(DATEADD(day, 3, getdate()) as date) as datetime) -- Отгрузка день в день 
			or (o.ExpectedDate < cast(cast(DATEADD(day, 4, getdate()) as date) as datetime) and o.DELIVERYKIND in (1, 2, 3, 4, 6, 8, 18/*, 20*/))
			or (o.ExpectedDate >= '20181108 00:00:00.000' and o.DELIVERYKIND in (7,19,25) and o.ExpectedDate < '20181128 00:00:00.000')
			or (o.ExpectedDate >= '20181108 00:00:00.000' and o.DELIVERYKIND in (5,12,14,16,17,21,22,24,26) and o.ExpectedDate < '20181230 00:00:00.000')
			)
		and o.ID not in (						
			select o.ID
			from CLIENTORDERS o
				join CLIENTORDERSCONTENT c on c.CLIENTORDERID = o.ID and c.RETURNED = 0 and c.QUANTITY > isnull(c.STOCK_QUANTITY,0) and c.QUANTITY > 0
			where (o.STATUS = 2 or (o.STATUS = 4 and exists (select 1 from ORDERSSTATUSHISTORY h where h.CLIENTORDER = o.ID and h.STATUS = 4 and h.AUTHOR <> 'sa')))
				and o.PACKED = 0 
				and o.DELIVERYKIND > 0 
				and (o.ExpectedDate < cast(cast(DATEADD(day, 3, getdate()) as date) as datetime) -- Отгрузка день в день 
					or (o.ExpectedDate < cast(cast(DATEADD(day, 4, getdate()) as date) as datetime) and o.DELIVERYKIND in (1, 2, 3, 4, 6, 8, 18/*, 20*/))
					or (o.ExpectedDate >= '20181108 00:00:00.000' and o.DELIVERYKIND in (7,19,25) and o.ExpectedDate < '20181128 00:00:00.000')
					or (o.ExpectedDate >= '20181108 00:00:00.000' and o.DELIVERYKIND in (5,12,14,16,17,21,22,24,26) and o.ExpectedDate < '20181230 00:00:00.000')
					)
				--and o.CREATORID is not null					
		)
				
end
