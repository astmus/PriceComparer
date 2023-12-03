create proc OrderDataMatrixWithdrawValidateContextView
(
	@OrderId	 uniqueidentifier		-- Иденификатор заказа
) as
begin

	declare 
		@HasItemsWithDataMatrix		bit = 0,
		@HasInjected				bit = 0

	-- Если имеется маркировка
	if exists 
	(
		select 1
		from 
			OrderContentDataMatrixes dm 
			left join SUZOrderItemDataMatrixes suz on dm.DataMatrix = substring(suz.DataMatrix, 1, 31)
		where 
			dm.OrderId = @OrderId
			and suz.DataMatrix is null
	) 
	begin
		select @HasItemsWithDataMatrix = 1
	end

	-- Если имеется распределенная маркировка
	if exists 
	(
		select 1
		from 
			OrderContentInjectDataMatrixes dm 
		where 
			dm.OrderId = @OrderId
	) 
	begin
		select @HasInjected = 1
	end
	
	select
		co.ID								as 'OrderId',
		co.PUBLICID							as 'PublicId',
		co.SITEID							as 'SiteId',
		cast(co.STATUS as int)				as 'StatusId',
		cast(co.DELIVERYKIND as int)		as 'DeliveryTypeId',
		isnull(ds.DeliveryServiceId, 0)		as 'DeliveryServiceId',
		cast(co.PAYMENTKIND as int)			as 'PaymentTypeId',
		co.FROZENSUM						as 'FrozenSum',
		co.PAIDSUM							as 'PaidSum',
		@HasItemsWithDataMatrix				as 'HasItemsWithDataMatrix',
		@HasInjected						as 'HasInjected',
		wsd.ShipmentDate					as 'ShipmentDate',
		IsNull(dso.AccountId, 0)			as 'TKAccountId',
		asa.Selector						as 'Selector', 
		cl.ClientType						as 'ClientTypeId',
		IIF(cl.ID in (
			'BA11349E-5EA0-465D-904A-61D6E381E6DC', '5B0F388B-5131-4E50-99AB-EF643F0A8D90', '498EF36F-4211-4B72-8A40-BAE4175AEEA5',
			'79CD61D2-988A-471E-B73F-71EBC63BB0AB', '459723EB-F12A-44C6-85B0-BF0B7765AD21'),
			Cast(1 as bit), Cast(0 as bit))	as 'IsEscentric',
		isnull(DepId, 'NONE')				as 'EposDepId'
	from
		CLIENTORDERS co
		join CLIENTS cl ON co.CLIENTID = cl.ID
		left join WmsShipmentDocuments wsd on wsd.PublicId = co.ID and wsd.DocStatus = 10 -- Отгруженный заказ 
		left join ClientOrdersAdditionalParams a on a.OrderId = co.ID
		left join ApiDeliveryServiceOrders dso ON co.ID = dso.InnerId
		left join ApiDeliveryServicesAccounts asa on asa.Id=dso.AccountId
		left join ClientOrdersDelivery ds on ds.OrderId = co.ID
		
	where 
		co.ID = @OrderId

end
