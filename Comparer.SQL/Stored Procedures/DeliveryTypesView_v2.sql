create proc dbo.DeliveryTypesView_v2 as
begin 

	select 
		dt.ID						as 'Id', 
		dt.TITLE					as 'Title', 
		dt.NAME						as 'Name', 
		dt.DESCRIPTION				as 'Description', 
		dt.ADAPTER					as 'Adapter', 
		dt.PRICE					as 'Price', 
		dt.PRICE_ADDITIONAL			as 'PriceAdditional', 
		dt.PRICE_ORIGINAL			as 'PriceOriginal', 
		dt.MIN_ORDER_SUM			as 'MinOrderSum', 
		dt.SORT_ID					as 'SortId', 
		dt.ADDRESS_REQUIRED			as 'AddressRequired', 
		dt.FULLNAME_REQUIRED		as 'FullNameRequired', 
		dt.DISABLED					as 'Disabled', 
		dt.IS_ACTIVE				as 'IsActive', 
		dt.IsDeleeted				as 'IsDeleted', 
		dt.SourceID					as 'SourceId', 
		dt.IsOld					as 'IsOld'
	from DeliveryTypes dt 
	order by dt.ID
	
	select 
			dt.ID					as 'DeliveryKindId',
			dkc.DeliveryServiceId	as 'ServiceId',
			ads.Name				as 'ServiceName',
			dkc.DefaultService		as 'DefaultService'
	from DeliveryTypes dt
		join DeliveryKindsServices dkc on dt.ID = dkc.DeliveryKindId
		join ApiDeliveryServices ads on dkc.DeliveryServiceId = ads.Id 
	order by dt.ID

end
